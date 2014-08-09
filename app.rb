require 'sinatra'
require 'twilio-ruby'
require File.expand_path('../lib/transcription', __FILE__)
require File.expand_path('../lib/debit_card_number', __FILE__)
require File.expand_path('../lib/twilio_service', __FILE__)

class EbtBalanceSmsApp < Sinatra::Base
  post '/' do
    twilio_service = TwilioService.new(Twilio::REST::Client.new(ENV['TWILIO_SID'], ENV['TWILIO_AUTH']))
    texter_phone_number = params["From"]
    inbound_twilio_number = params["To"]
    debit_number = DebitCardNumber.new(params["Body"])
    twiml_url = "#{request.env['rack.url_scheme']}://#{request.env['HTTP_HOST']}/get_balance?phone_number=#{texter_phone_number}&twilio_phone_number=#{inbound_twilio_number}"
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
    phone_number = params[:phone_number].strip
    twilio_number = params[:twilio_phone_number].strip
    Twilio::TwiML::Response.new do |r|
      r.Record :transcribeCallback => "#{request.env['rack.url_scheme']}://#{request.env['HTTP_HOST']}/#{phone_number}/#{twilio_number}/send_balance", :maxLength => 18
    end.text
  end

  post '/get_balance' do
    # Twilio posts unused data here; necessary simply to avoid 404 error in logs
  end

  post '/:to_phone_number/:from_phone_number/send_balance' do
    transcription = Transcription.new(params["TranscriptionText"])
    twilio_service = TwilioService.new(Twilio::REST::Client.new(ENV['TWILIO_SID'], ENV['TWILIO_AUTH']))
    twilio_service.send_text(
      to: params[:to_phone_number].strip,
      from: params[:from_phone_number],
      body: "Hi! Your food stamp balance is #{transcription.ebt_amount} and your cash balance is #{transcription.cash_amount}."
    )
  end
end
