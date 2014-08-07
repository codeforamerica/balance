require 'sinatra'
require 'twilio-ruby'
require File.expand_path('../lib/transcription', __FILE__)
require File.expand_path('../lib/debit_card_number', __FILE__)
require File.expand_path('../lib/twilio_service', __FILE__)

class EbtBalanceSmsApp < Sinatra::Base
  post '/' do
    @twilio_service = TwilioService.new(Twilio::REST::Client.new(ENV['TWILIO_SID'], ENV['TWILIO_AUTH']))
    @texter_phone_number = params["From"]
    @debit_number = DebitCardNumber.new(params["Body"])
    @twiml_url = "#{request.env['rack.url_scheme']}://#{request.env['HTTP_HOST']}/get_balance?phone_number=#{@texter_phone_number}"
    if @debit_number.is_valid?
      call = @twilio_service.make_call(
        url: @twiml_url,
        to: "+18773289677",
        send_digits: "ww1ww#{@debit_number.to_s}",
        from: ENV['TWILIO_NUMBER'],
        method: "GET"
      )
      text_message = @twilio_service.send_text(
        to: @texter_phone_number,
        from: ENV['TWILIO_NUMBER'],
        body: "Thanks! Please wait 1-2 minutes while we check your EBT balance."
      )
    else
      text_message = @twilio_service.send_text(
        to: @texter_phone_number,
        from: ENV['TWILIO_NUMBER'],
        body: "Sorry, that EBT number doesn't look right. Please try again."
      )
    end
  end

  get '/get_balance' do
    @phone_number = params[:phone_number].strip
    @my_response = Twilio::TwiML::Response.new do |r|
      r.Record :transcribeCallback => "#{request.env['rack.url_scheme']}://#{request.env['HTTP_HOST']}/#{@phone_number}/send_balance", :maxLength => 18 #:transcribe => true
    end
    @my_response.text
  end

  post '/get_balance' do
    # Twilio posts unused data here; necessary simply to avoid 404 error in logs
  end

  post '/:phone_number/send_balance' do
    transcription = Transcription.new(params["TranscriptionText"])
    @twilio_service = TwilioService.new(Twilio::REST::Client.new(ENV['TWILIO_SID'], ENV['TWILIO_AUTH']))
    @twilio_service.send_text(
      to: params[:phone_number].strip,
      from: ENV['TWILIO_NUMBER'],
      body: "Hi! Your food stamp balance is #{transcription.ebt_amount} and your cash balance is #{transcription.cash_amount}."
    )
  end
end
