# -*- encoding : utf-8 -*-
module RackSpecHelpers
  include Rack::Test::Methods
  attr_accessor :app
end
