require File.expand_path('../spec_helper', __FILE__)
require File.expand_path('../../lib/phone_number_processor', __FILE__)
require 'twilio-ruby'
require 'vcr'

VCR.configure do |c|
  c.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  c.hook_into :webmock
end
