require 'spec_helper'
require 'rack/test'
require 'nokogiri'
require 'sinatra'
require File.expand_path('../rack_spec_helpers', __FILE__)

class EbtBalanceSmsApp < Sinatra::Base
  set :environment, :test
end

RSpec.configure do |config|
  config.include RackSpecHelpers
  config.before(:example, :type => :feature) do
    require File.expand_path('../../lib/phone_number_processor', __FILE__)
    require File.expand_path('../support/fone_number_processor', __FILE__)
    allow(PhoneNumberProcessor).to receive(:new).and_return(FoneNumberProcessor.new)
    require File.expand_path('../../app', __FILE__)
    self.app = EbtBalanceSmsApp
  end
end
