require 'sinatra'
require 'twilio-ruby'
require 'rack/ssl'
require File.expand_path('../lib/transcription', __FILE__)
require File.expand_path('../lib/debit_card_number', __FILE__)
require File.expand_path('../lib/twilio_service', __FILE__)

class EbtBalanceSmsApp < Sinatra::Base
  use Rack::SSL unless settings.environment == :development or settings.environment == :test
  if settings.environment == :production
    set :url_scheme, 'https'
  else
    set :url_scheme, 'http'
  end

  post '/' do
    puts request.url
    twilio_service = TwilioService.new(Twilio::REST::Client.new(ENV['TWILIO_SID'], ENV['TWILIO_AUTH']))
    texter_phone_number = params["From"]
    inbound_twilio_number = params["To"]
    debit_number = DebitCardNumber.new(params["Body"])
    twiml_url = "#{settings.url_scheme}://#{request.env['HTTP_HOST']}/get_balance?phone_number=#{texter_phone_number}&twilio_phone_number=#{inbound_twilio_number}"
    if debit_number.is_valid?
      twilio_service.make_call(
        url: twiml_url,
        to: "+18773289677",
        send_digits: "ww1ww#{debit_number.to_s}",
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
    puts request.url
    phone_number = params[:phone_number].strip
    twilio_number = params[:twilio_phone_number].strip
    Twilio::TwiML::Response.new do |r|
      r.Record :transcribeCallback => "#{settings.url_scheme}://#{request.env['HTTP_HOST']}/#{phone_number}/#{twilio_number}/send_balance", :maxLength => 18
    end.text
  end

  post '/get_balance' do
    # Twilio posts unused data here; necessary simply to avoid 404 error in logs
  end

  post '/:to_phone_number/:from_phone_number/send_balance' do
    transcription = Transcription.new(params["TranscriptionText"])
    twilio_service = TwilioService.new(Twilio::REST::Client.new(ENV['TWILIO_SID'], ENV['TWILIO_AUTH']))
    if transcription.invalid_ebt_number?
      twilio_service.send_text(
        to: params[:to_phone_number].strip,
        from: params[:from_phone_number],
        body: "I'm sorry, that card number was not found. Please try again. (Note: this service only works in California right now.)"
      )
    else
      twilio_service.send_text(
        to: params[:to_phone_number].strip,
        from: params[:from_phone_number],
        body: "Hi! Your food stamp balance is #{transcription.ebt_amount} and your cash balance is #{transcription.cash_amount}."
      )
    end
  end

  post '/voice_call' do
    puts request.url
    twilio_service = TwilioService.new(Twilio::REST::Client.new(ENV['TWILIO_SID'], ENV['TWILIO_AUTH']))
    caller_phone_number = params["From"]
    inbound_twilio_number = params["To"]
    twilio_service.send_text(
      to: caller_phone_number,
      from: inbound_twilio_number,
      body: 'Hi there! You can check your EBT card balance by text message here. Just reply to this message with your 16-digit EBT card number.'
    )
    response = <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<Response>
  <Gather timeout="10" action="http://twimlets.com/forward?PhoneNumber=877-328-9677" method="GET" numDigits="1">
    <Play>https://s3-us-west-1.amazonaws.com/balance-cfa/balance-splash.mp3</Play>
  </Gather>
  <Redirect method="GET">http://twimlets.com/forward?PhoneNumber=877-328-9677</Redirect>
</Response>
EOF
  end
end
