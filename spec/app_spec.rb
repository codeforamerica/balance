require 'spec_helper'

describe EbtBalanceSmsApp do
=begin
  context 'an initial text in' do
    before(:each) do
      post '/', { "Body" => "1111222233334444", "From" => "+12223334444" }
    end

    it 'responds at root to a POST' do
      puts last_response
      expect(last_response.status).to eq(200)
    end

    it 'initiates a Twilio call' do
    end
  end
=end
  context 'twiml for getting balance' do
    params[:phone_number]
  end
end
