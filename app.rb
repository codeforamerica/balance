require 'sinatra'
require 'twilio-ruby'

class EbtBalanceSmsApp < Sinatra::Base
  post '/' do
    puts params
  end
end
