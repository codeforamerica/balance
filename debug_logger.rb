if ARGV.include?('--with-server')
  start_sinatra_app(:port => 7777) do
    get('/') { "Hello World" }
  end
end

require 'vcr'

VCR.configure do |c|
  c.hook_into :fakeweb
  c.cassette_library_dir = 'cassettes'
  c.debug_logger = File.open(ARGV.first, 'w')
end

VCR.use_cassette('example') do
  Net::HTTP.get_response(URI("http://localhost:7777/"))
end
