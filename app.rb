require 'sinatra'
require 'twilio-ruby'

class EbtBalanceSmsApp < Sinatra::Base
  TWILIO_CLIENT = Twilio::REST::Client.new(ENV['TWILIO_SID'], ENV['TWILIO_AUTH'])

  post '/' do
    @texter_phone_number = params["From"].match(/[\d+]/)[0]
    @debit_number = DebitCardNumber.new(params["Body"])
    @twiml_url = "#{request.env['rack.url_scheme']}://#{request.env['HTTP_HOST']}/get_balance?phone_number=#{@texter_phone_number}"
    puts @debit_number.to_s
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
    puts params
    @my_response = Twilio::TwiML::Response.new do |r|
      r.Record :transcribe => true
    end
    puts @my_response.text
    @my_response.text
  end

  post '/send_balance' do
    puts params
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
