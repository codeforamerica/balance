require './app'
Rack::Timeout.timeout = 10
$stdout.sync = true
run EbtBalanceSmsApp
