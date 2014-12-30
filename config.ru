require './app'
require 'rack-timeout'
Rack::Timeout.timeout = 10
$stdout.sync = true
run EbtBalanceSmsApp
