require 'spec_helper'

describe EbtBalanceSmsApp do
  describe 'initial text' do
    context 'with valid EBT number' do
      let(:ebt_number) { "1111222233334444" }
      let(:texter_number) { "+12223334444" }
      let(:fake_twilio) { double("FakeTwilioService", :make_call => 'made call', :send_text => 'sent text') }

      before do
        allow(TwilioService).to receive(:new).and_return(fake_twilio)
        post '/', { "Body" => ebt_number, "From" => texter_number }
      end

      it 'initiates an outbound Twilio call to EBT line with correct details' do
        expect(fake_twilio).to have_received(:make_call).with(
          url: "http://example.org/get_balance?phone_number=#{texter_number}",
          to: '+18773289677',
          send_digits: "ww1ww#{ebt_number}",
          from: 'loltwilionumber',
          record: 'true',
          method: 'GET'
        )
      end

      it 'sends a text to the user telling them wait time' do
        expect(fake_twilio).to have_received(:send_text).with(
          to: texter_number,
          from: 'loltwilionumber',
          body: "Thanks! Please wait 1-2 minutes while we check your EBT balance."
        )
      end
    end

    context 'with INVALID EBT number' do
      let(:invalid_ebt_number) { "111122223333" }
      let(:texter_number) { "+12223334444" }
      let(:fake_twilio) { double("FakeTwilioService", :make_call => 'made call', :send_text => 'sent text') }

      before do
        allow(TwilioService).to receive(:new).and_return(fake_twilio)
        post '/', { "Body" => invalid_ebt_number, "From" => texter_number }
      end

      it 'sends a text to the user with error message' do
        expect(fake_twilio).to have_received(:send_text).with(
          to: texter_number,
          from: 'loltwilionumber',
          body: "Sorry, that EBT number doesn't look right. Please try again."
        )
      end
    end
  end

  describe 'GET /get_balance' do
    it 'responds with correct TwiML' do
      get '/get_balance?phone_number=+12223334444'
      parsed_response = Nokogiri::XML(last_response.body)
      record_attributes = parsed_response.children.children[0].attributes
      callback = record_attributes["transcribeCallback"].value
      maxlength = record_attributes["maxLength"].value
      expect(callback).to eq("http://example.org/12223334444/send_balance")
      expect(maxlength).to eq("18")
    end
  end

  describe 'sending the balance to user' do
    let(:phone_number) { "19998887777" }
    let(:fake_twilio) { double("FakeTwilioService", :send_text => 'sent text') }

    it 'sends the correct amounts to user' do
      allow(TwilioService).to receive(:new).and_return(fake_twilio)
      post "/#{phone_number}/send_balance", { "TranscriptionText" => "Your food stamp balance is $123.45 your cash account balance is $0 as a reminder by saving the receipt from your last purchase and your last a cash purchase for Cash Bank Transaction you will always have your current balance at and will also print your balance on the Cash Withdrawal receipt to hear the number of Cash Withdrawal for that a transaction fee (running?) this month press 1 to hear your last 10 transactions report a transaction there file a claim or check the status of a claim press 2 to report your card lost stolen or damaged press 3 for (pin?) replacement press 4 for additional options press 5" }
      expect(fake_twilio).to have_received(:send_text).with(
        to: phone_number,
        from: 'loltwilionumber',
        body: 'Hi! Your food stamp balance is $123.45 and your cash balance is $0.'
      )
    end
  end
end
