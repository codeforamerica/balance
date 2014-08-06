require 'sinatra'
require 'twilio-ruby'
require File.expand_path('../lib/transcription', __FILE__)

class EbtBalanceSmsApp < Sinatra::Base
  TWILIO_CLIENT = Twilio::REST::Client.new(ENV['TWILIO_SID'], ENV['TWILIO_AUTH'])

  post '/' do
    @texter_phone_number = params["From"]
    @debit_number = DebitCardNumber.new(params["Body"])
    @twiml_url = "#{request.env['rack.url_scheme']}://#{request.env['HTTP_HOST']}/get_balance?phone_number=#{@texter_phone_number}"
    if @debit_number.is_valid?
      call = TWILIO_CLIENT.account.calls.create( \
        url: @twiml_url, \
        to: "+18773289677", \
        send_digits: "ww1ww#{@debit_number.to_s}", \
        from: ENV['TWILIO_NUMBER'], \
        record: "true", \
        method: "GET" \
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

  post '/:phone_number/send_balance' do
    transcription = Transcription.new(params["TranscriptionText"])
    TWILIO_CLIENT.account.messages.create( \
      to: params[:phone_number].strip, \
      from: ENV['TWILIO_NUMBER'], \
      body: "Hi! Your food stamp balance is #{transcription.ebt_amount} and your cash balance is #{transcription.cash_amount}." \
    )
  end
end

class DebitCardNumber
  attr_accessor :number

  def initialize(number)
    @number = number
  end

  def to_s
    @number
  end

  def is_valid?
    return true
  end
end
