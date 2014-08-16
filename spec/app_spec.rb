require 'spec_helper'

describe EbtBalanceSmsApp do
  describe 'initial text' do
    context 'with valid EBT number' do
      let(:ebt_number) { "1111222233334444" }
      let(:texter_number) { "+12223334444" }
      let(:inbound_twilio_number) { "+15556667777" }
      let(:fake_twilio) { double("FakeTwilioService", :make_call => 'made call', :send_text => 'sent text') }

      before do
        allow(TwilioService).to receive(:new).and_return(fake_twilio)
        post '/', { "Body" => ebt_number, "From" => texter_number, "To" => inbound_twilio_number }
      end

      it 'initiates an outbound Twilio call to EBT line with correct details' do
        expect(fake_twilio).to have_received(:make_call).with(
          url: "http://example.org/get_balance?phone_number=#{texter_number}&twilio_phone_number=#{inbound_twilio_number}",
          to: '+18773289677',
          send_digits: "ww1ww#{ebt_number}",
          from: inbound_twilio_number,
          method: 'GET'
        )
      end

      it 'sends a text to the user telling them wait time' do
        expect(fake_twilio).to have_received(:send_text).with(
          to: texter_number,
          from: inbound_twilio_number,
          body: "Thanks! Please wait 1-2 minutes while we check your EBT balance."
        )
      end

      it 'responds with 200 status' do
        expect(last_response.status).to eq(200)
      end
    end

    context 'with INVALID EBT number' do
      let(:invalid_ebt_number) { "111122223333" }
      let(:texter_number) { "+12223334444" }
      let(:inbound_twilio_number) { "+15556667777" }
      let(:fake_twilio) { double("FakeTwilioService", :make_call => 'made call', :send_text => 'sent text') }

      before do
        allow(TwilioService).to receive(:new).and_return(fake_twilio)
        post '/', { "Body" => invalid_ebt_number, "From" => texter_number, "To" => inbound_twilio_number }
      end

      it 'sends a text to the user with error message' do
        expect(fake_twilio).to have_received(:send_text).with(
          to: texter_number,
          from: inbound_twilio_number,
          body: "Sorry, that EBT number doesn't look right. Please try again."
        )
      end

      it 'responds with 200 status' do
        expect(last_response.status).to eq(200)
      end
    end
  end

  describe 'GET /get_balance' do
    let(:texter_number) { "+12223334444" }
    let(:inbound_twilio_number) { "+15556667777" }

    before do
      get "/get_balance?phone_number=#{texter_number}&twilio_phone_number=#{inbound_twilio_number}"
      parsed_response = Nokogiri::XML(last_response.body)
      record_attributes = parsed_response.children.children[0].attributes
      @callback_url = record_attributes["transcribeCallback"].value
      @maxlength = record_attributes["maxLength"].value
    end

    it 'responds with callback to correct URL (ie, correct phone number)' do
      expect(@callback_url).to eq("http://example.org/12223334444/15556667777/send_balance")
    end

    it 'has max recording length set correctly' do
      expect(@maxlength).to eq("18")
    end

    it 'responds with 200 status' do
      expect(last_response.status).to eq(200)
    end
  end

  describe 'sending the balance to user' do
    let(:to_phone_number) { "19998887777" }
    let(:twilio_number) { "+15556667777" }
    let(:fake_twilio) { double("FakeTwilioService", :send_text => 'sent text') }

    context 'when EBT number is valid' do
      before do
        allow(TwilioService).to receive(:new).and_return(fake_twilio)
        post "/#{to_phone_number}/#{twilio_number}/send_balance", { "TranscriptionText" => "Your food stamp balance is $123.45 your cash account balance is $0 as a reminder by saving the receipt from your last purchase and your last a cash purchase for Cash Bank Transaction you will always have your current balance at and will also print your balance on the Cash Withdrawal receipt to hear the number of Cash Withdrawal for that a transaction fee (running?) this month press 1 to hear your last 10 transactions report a transaction there file a claim or check the status of a claim press 2 to report your card lost stolen or damaged press 3 for (pin?) replacement press 4 for additional options press 5" }
      end

      it 'sends the correct amounts to user' do
        expect(fake_twilio).to have_received(:send_text).with(
          to: to_phone_number,
          from: twilio_number,
          body: 'Hi! Your food stamp balance is $123.45 and your cash balance is $0.'
        )
      end

      it 'returns status 200' do
        expect(last_response.status).to eq(200)
      end
    end

    context 'when EBT number is NOT valid' do
      before do
        allow(TwilioService).to receive(:new).and_return(fake_twilio)
        post "/#{to_phone_number}/#{twilio_number}/send_balance", { "TranscriptionText" => "Our records indicate the number you have entered it's for an non working card in case your number was entered incorrectly please reenter your 16 digit card number followed by the pound sign."}
      end

      it 'sends the user an error message' do
        expect(fake_twilio).to have_received(:send_text).with(
          to: to_phone_number,
          from: twilio_number,
          body: "I'm sorry, that card number was not found. Please try again. (Note: this service only works in California right now.)"
        )
      end

      it 'returns status 200' do
        expect(last_response.status).to eq(200)
      end
    end
  end

  describe 'POST /get_balance' do
    it 'responds with 200 status' do
      post '/get_balance'
      expect(last_response.status).to eq(200)
    end
  end

  describe 'inbound voice call' do
    let(:caller_number) { "+12223334444" }
    let(:inbound_twilio_number) { "+15556667777" }
    let(:fake_twilio) { double("FakeTwilioService", :make_call => 'made call', :send_text => 'sent text') }

    before do
      allow(TwilioService).to receive(:new).and_return(fake_twilio)
      post '/voice_call', { "From" => caller_number, "To" => inbound_twilio_number }
    end

    it 'responds with 200 status' do
      expect(last_response.status).to eq(200)
    end

    it 'sends an outbound text to the number' do
      expect(fake_twilio).to have_received(:send_text).with(
        to: caller_number,
        from: inbound_twilio_number,
        body: 'Hi there! You can check your EBT card balance by text message here. Just reply to this message with your 16-digit EBT card number.'
      )
    end

    it 'plays welcome message to caller and allows them to go to state line' do
      desired_response = <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<Response>
  <Gather timeout="10" action="http://twimlets.com/forward?PhoneNumber=877-328-9677" method="GET" numDigits="1">
    <Play>https://s3-us-west-1.amazonaws.com/balance-cfa/balance-splash.mp3</Play>
  </Gather>
  <Redirect method="GET">http://twimlets.com/forward?PhoneNumber=877-328-9677</Redirect>
</Response>
EOF
      expect(last_response.body).to eq(desired_response)
    end
  end
end
