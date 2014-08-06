require 'spec_helper'

describe EbtBalanceSmsApp do
  it 'responds at root to a POST' do
    post '/', "Body" => "1111222233334444"
    expect(last_response.status).to eq(200)
  end
end
