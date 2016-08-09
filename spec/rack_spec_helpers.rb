module RackSpecHelpers
  include Rack::Test::Methods
  attr_accessor :app
end
