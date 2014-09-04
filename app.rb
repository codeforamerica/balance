require 'sinatra'
require 'twilio-ruby'
require 'rack/ssl'
require File.expand_path('../lib/twilio_service', __FILE__)
require File.expand_path('../lib/state_handler', __FILE__)
require File.expand_path('../lib/phone_number_processor', __FILE__)

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
    debit_number = state_handler.extract_valid_ebt_number_from_text(params["Body"])
    twiml_url = "#{settings.url_scheme}://#{request.env['HTTP_HOST']}/get_balance?phone_number=#{texter_phone_number}&twilio_phone_number=#{inbound_twilio_number}&state=#{state_abbreviation}"
    if debit_number != :invalid_number
      twilio_service.make_call(
        url: twiml_url,
        to: state_handler.phone_number,
        send_digits: state_handler.button_sequence(debit_number),
        from: inbound_twilio_number,
        method: "GET"
      )
      twilio_service.send_text(
        to: texter_phone_number,
        from: inbound_twilio_number,
        body: "Thanks! Please wait 1-2 minutes while we check your EBT balance."
      )
    else
      twilio_service.send_text(
        to: texter_phone_number,
        from: inbound_twilio_number,
        body: "Sorry, that EBT number doesn't look right. Please try again."
      )
    end
  end

  get '/get_balance' do
    phone_number = params[:phone_number].strip
    twilio_number = params[:twilio_phone_number].strip
    state = params[:state]
    Twilio::TwiML::Response.new do |r|
      r.Record :transcribeCallback => "#{settings.url_scheme}://#{request.env['HTTP_HOST']}/#{state}/#{phone_number}/#{twilio_number}/send_balance", :maxLength => 18
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
    state_handler = StateHandler.for(params[:state])
    processed_balance_response_for_user = state_handler.transcribe_balance_response(params["TranscriptionText"])
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
    twilio_service.send_text(
      to: caller_phone_number,
      from: inbound_twilio_number,
      body: 'Hi there! You can check your EBT card balance by text message here. Just reply to this message with your EBT card number.'
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
