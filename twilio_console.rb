require 'twilio-ruby'
require 'pry'

staging_client = Twilio::REST::Client.new(ENV['TWILIO_BALANCE_STAGING_SID'], ENV['TWILIO_BALANCE_STAGING_AUTH'])

binding.pry

