# -*- encoding : utf-8 -*-
class TwilioService
  attr_reader :client

  def initialize(twilio_client)
    @client = twilio_client
  end

  def make_call(params)
    @client.account.calls.create(params)
  end

  def send_text(params)
    @client.account.messages.create(params)
  end
end
