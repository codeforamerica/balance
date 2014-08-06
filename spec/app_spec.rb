require 'spec_helper'

describe EbtBalanceSmsApp do
  context 'an initial text in' do
    before(:each) do
      @service_double = double("TwilioService")
      post '/', { "Body" => "1111222233334444", "From" => "+12223334444" }
    end

    it 'responds at root to a POST' do
      expect(last_response.status).to eq(200)
    end

    it 'initiates a Twilio call' do
      expect_any_instance_of(@service_double).to receive(:make_call)
    end
  end
=begin
  context 'twiml for getting balance' do
    params[:phone_number]
  end
=end
end
