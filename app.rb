require 'sinatra'
require 'twilio-ruby'
require 'rack/ssl'
require File.expand_path('../lib/twilio_service', __FILE__)
require File.expand_path('../lib/state_handler', __FILE__)
require File.expand_path('../lib/phone_number_processor', __FILE__)
require File.expand_path('../lib/message_generator', __FILE__)

class EbtBalanceSmsApp < Sinatra::Base
  use Rack::SSL unless settings.environment == :development or settings.environment == :test
  if settings.environment == :production
    set :url_scheme, 'https'
  else
    set :url_scheme, 'http'
  end
  set :phone_number_processor, PhoneNumberProcessor.new

  before do
    puts "Request details — #{request.request_method} #{request.url}" unless settings.environment == :test
  end

  post '/' do
    twilio_service = TwilioService.new(Twilio::REST::Client.new(ENV['TWILIO_SID'], ENV['TWILIO_AUTH']))
    texter_phone_number = params["From"]
    inbound_twilio_number = params["To"]
    state_abbreviation = params["ToState"] || "no_state_abbreviation_received"
    state_handler = StateHandler.for(state_abbreviation)
    ebt_number = state_handler.extract_valid_ebt_number_from_text(params["Body"])
    twiml_url = "#{settings.url_scheme}://"
    twiml_url << "#{request.env['HTTP_HOST']}/get_balance"
    twiml_url << "?phone_number=#{texter_phone_number}"
    twiml_url << "&twilio_phone_number=#{inbound_twilio_number}"
    twiml_url << "&state=#{state_abbreviation}"
    twiml_url << "&ebt_number=#{ebt_number}"
    language = settings.phone_number_processor.language_for(inbound_twilio_number)
    message_generator = MessageGenerator.new(language)
    if ebt_number != :invalid_number
      twilio_service.make_call(
        url: twiml_url,
        to: state_handler.phone_number,
        from: inbound_twilio_number,
        method: "GET"
      )
      twilio_service.send_text(
        to: texter_phone_number,
        from: inbound_twilio_number,
        body: message_generator.thanks_please_wait
      )
    else
      twilio_service.send_text(
        to: texter_phone_number,
        from: inbound_twilio_number,
        body: message_generator.sorry_try_again
      )
    end
  end

  get '/get_balance' do
    phone_number = params[:phone_number].strip
    twilio_number = params[:twilio_phone_number].strip
    state = params[:state]
    state_handler = StateHandler.for(state)
    Twilio::TwiML::Response.new do |r|
      r.Play digits: state_handler.button_sequence(params['ebt_number'])
      r.Record transcribe: true,
        transcribeCallback: "#{settings.url_scheme}://#{request.env['HTTP_HOST']}/#{state}/#{phone_number}/#{twilio_number}/send_balance",
        maxLength: 18
    end.text
  end

  post '/get_balance' do
    # Twilio posts unused data here; necessary simply to avoid 404 error in logs
    response = <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<Response>
</Response>
EOF
  end

  post '/:state/:to_phone_number/:from_phone_number/send_balance' do
    twilio_phone_number = params[:from_phone_number]
    language = settings.phone_number_processor.language_for(twilio_phone_number)
    transcriber = StateHandler.for(params[:state]).transcriber_for(language)
    processed_balance_response_for_user = transcriber.transcribe_balance_response(params["TranscriptionText"])
    twilio_service = TwilioService.new(Twilio::REST::Client.new(ENV['TWILIO_SID'], ENV['TWILIO_AUTH']))
    twilio_service.send_text(
      to: params[:to_phone_number].strip,
      from: params[:from_phone_number],
      body: processed_balance_response_for_user
    )
  end

  post '/voice_call' do
    twilio_service = TwilioService.new(Twilio::REST::Client.new(ENV['TWILIO_SID'], ENV['TWILIO_AUTH']))
    caller_phone_number = params["From"]
    inbound_twilio_number = params["To"]
    state_handler = StateHandler.for(params["ToState"])
    language = settings.phone_number_processor.language_for(inbound_twilio_number)
    message_generator = MessageGenerator.new(language)
    twilio_service.send_text(
      to: caller_phone_number,
      from: inbound_twilio_number,
      body: message_generator.inbound_voice_call_text_message
    )
    response = <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<Response>
  <Gather timeout="10" action="http://twimlets.com/forward?PhoneNumber=#{state_handler.phone_number}" method="GET" numDigits="1">
    <Play>https://s3-us-west-1.amazonaws.com/balance-cfa/balance-splash.mp3</Play>
  </Gather>
  <Redirect method="GET">http://twimlets.com/forward?PhoneNumber=#{state_handler.phone_number}</Redirect>
</Response>
EOF
  end
end
