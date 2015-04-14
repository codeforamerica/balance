require 'app_spec_helper'

describe EbtBalanceSmsApp, :type => :feature do
  describe 'initial text' do
    let(:texter_number) { "+12223334444" }
    let(:inbound_twilio_number) { "+15556667777" }
    let(:fake_twilio) { double("FakeTwilioService", :make_call => 'made call', :send_text => 'sent text') }
    let(:to_state) { 'CA' }
    let(:fake_message_generator) { double("MessageGenerator", :thanks_please_wait => "fake thanks please wait msg") }

    context 'with valid EBT number' do
      let(:ebt_number) { "1111222233334444" }
      let(:fake_state_handler) { double('FakeStateHandler', :phone_number => 'fake_state_phone_number', :button_sequence => "fake_button_sequence", :extract_valid_ebt_number_from_text => ebt_number) }

      before do
        allow(TwilioService).to receive(:new).and_return(fake_twilio)
        allow(MessageGenerator).to receive(:new).and_return(fake_message_generator)
        allow(StateHandler).to receive(:for).with(to_state).and_return(fake_state_handler)
        post '/', { "Body" => ebt_number, "From" => texter_number, "To" => inbound_twilio_number, "ToState" => to_state }
      end

      it 'initializes a new state handler' do
        expect(StateHandler).to have_received(:for).with(to_state)
      end

      it 'initiates an outbound Twilio call to EBT line with correct details' do
        expect(fake_twilio).to have_received(:make_call).with(
          url: "http://example.org/get_balance?phone_number=#{texter_number}&twilio_phone_number=#{inbound_twilio_number}&state=#{to_state}&ebt_number=#{ebt_number}",
          to: fake_state_handler.phone_number,
          from: inbound_twilio_number,
          method: 'GET'
        )
      end

      it 'sends a text to the user telling them wait time' do
        expect(fake_twilio).to have_received(:send_text).with(
          to: texter_number,
          from: inbound_twilio_number,
          body: fake_message_generator.thanks_please_wait
        )
      end

      it 'responds with 200 status' do
        expect(last_response.status).to eq(200)
      end
    end

    context 'with INVALID EBT number' do
      let(:invalid_ebt_number) { "111122223333" }
      let(:fake_state_handler) { double('FakeStateHandler', :phone_number => 'fake_state_phone_number', :button_sequence => "fake_button_sequence", :extract_valid_ebt_number_from_text => :invalid_number, :allowed_number_of_ebt_card_digits => [14] ) }

      before do
        allow(TwilioService).to receive(:new).and_return(fake_twilio)
        allow(StateHandler).to receive(:for).with(to_state).and_return(fake_state_handler)
        post '/', { "Body" => invalid_ebt_number, "From" => texter_number, "To" => inbound_twilio_number, "ToState" => to_state }
      end

      it 'asks the state handler for the EBT card number of digits (to produce sorry msg)' do
        expect(fake_state_handler).to have_received(:allowed_number_of_ebt_card_digits)
      end

      it 'sends a text to the user with error message' do
        expect(fake_twilio).to have_received(:send_text).with(
          to: texter_number,
          from: inbound_twilio_number,
          body: "Sorry! That number doesn't look right. Please reply with your 14-digit EBT card number."
        )
      end

      it 'responds with 200 status' do
        expect(last_response.status).to eq(200)
      end
    end

    context 'asking for more info (about)' do
      let(:fake_state_handler) { double('FakeStateHandler', :phone_number => 'fake_state_phone_number', :button_sequence => "fake_button_sequence", :extract_valid_ebt_number_from_text => :invalid_number, :allowed_number_of_ebt_card_digits => [14] ) }
      let(:more_info_content) { "This is a free text service provided by non-profit Code for America for checking your EBT balance (standard rates apply). For more info go to www.c4a.me/balance" }

      before do
        allow(TwilioService).to receive(:new).and_return(fake_twilio)
        allow(StateHandler).to receive(:for).with(to_state).and_return(fake_state_handler)
      end

      context 'with all caps' do
        let(:body) { "ABOUT" }

        before do
          post '/', { "Body" => body, "From" => texter_number, "To" => inbound_twilio_number, "ToState" => to_state }
        end

        it 'sends a text to the user with more info' do
          expect(fake_twilio).to have_received(:send_text).with(
            to: texter_number,
            from: inbound_twilio_number,
            body: more_info_content
          )
        end

        it 'responds with 200 status' do
          expect(last_response.status).to eq(200)
        end
      end

      context 'with lower case' do
        let(:body) { "about" }

        before do
          post '/', { "Body" => body, "From" => texter_number, "To" => inbound_twilio_number, "ToState" => to_state }
        end

        it 'sends a text to the user with more info' do
          expect(fake_twilio).to have_received(:send_text).with(
            to: texter_number,
            from: inbound_twilio_number,
            body: more_info_content
          )
        end

        it 'responds with 200 status' do
          expect(last_response.status).to eq(200)
        end
      end

      context 'with camel case' do
        let(:body) { "About" }

        before do
          post '/', { "Body" => body, "From" => texter_number, "To" => inbound_twilio_number, "ToState" => to_state }
        end

        it 'sends a text to the user with more info' do
          expect(fake_twilio).to have_received(:send_text).with(
            to: texter_number,
            from: inbound_twilio_number,
            body: more_info_content
          )
        end

        it 'responds with 200 status' do
          expect(last_response.status).to eq(200)
        end
      end

      context 'with about embedded inside another string' do
        let(:body) { "akjhsasfhaboutaskjh ashjd PHEEa23" }

        before do
          post '/', { "Body" => body, "From" => texter_number, "To" => inbound_twilio_number, "ToState" => to_state }
        end

        it 'sends a text to the user with more info' do
          expect(fake_twilio).to have_received(:send_text).with(
            to: texter_number,
            from: inbound_twilio_number,
            body: more_info_content
          )
        end

        it 'responds with 200 status' do
          expect(last_response.status).to eq(200)
        end
      end
    end

    context 'with blocked phone number' do
      let(:fake_state_handler) { double('FakeStateHandler', :phone_number => 'fake_state_phone_number', :button_sequence => "fake_button_sequence", :extract_valid_ebt_number_from_text => :invalid_number, :allowed_number_of_ebt_card_digits => [14] ) }
      let(:fake_twilio_with_blacklist_raise) { double("FakeTwilioService") }

      before do
        allow(fake_twilio_with_blacklist_raise).to receive(:send_text).and_raise(Twilio::REST::RequestError.new("The message From/To pair violates a blacklist rule."))
        allow(TwilioService).to receive(:new).and_return(fake_twilio_with_blacklist_raise)
        allow(StateHandler).to receive(:for).with(to_state).and_return(fake_state_handler)
      end

      context 'with an EBT # that passes validation in the body' do
        before do
          post '/', { "Body" => "11112222333344", "From" => texter_number, "To" => inbound_twilio_number, "ToState" => to_state }
        end

        it 'does NOT initiate a call via Twilio' do
          expect(fake_twilio).to_not have_received(:make_call)
        end

        it 'does not blow up (ie, it responds with 200 status)' do
          expect(last_response.status).to eq(200)
        end
      end

      context 'with text in the body' do
        before do
          post '/', { "Body" => "Stop", "From" => texter_number, "To" => inbound_twilio_number, "ToState" => to_state }
        end

        it 'does NOT initiate a call via Twilio' do
          expect(fake_twilio).to_not have_received(:make_call)
        end

        it 'does not blow up (ie, it responds with 200 status)' do
          expect(last_response.status).to eq(200)
        end
      end
    end

    context 'using Spanish-language Twilio phone number' do
      let(:ebt_number) { "1111222233334444" }
      let(:spanish_twilio_number) { "+19998887777" }
      let(:inbound_twilio_number) { spanish_twilio_number }
      let(:fake_state_handler) { double('FakeStateHandler', :phone_number => 'fake_state_phone_number', :button_sequence => "fake_button_sequence", :extract_valid_ebt_number_from_text => ebt_number ) }
      let(:spanish_message_generator) { double('SpanishMessageGenerator', :thanks_please_wait => 'spanish thankspleasewait') }

      before do
        allow(TwilioService).to receive(:new).and_return(fake_twilio)
        allow(StateHandler).to receive(:for).with(to_state).and_return(fake_state_handler)
        allow(MessageGenerator).to receive(:new).with(:spanish).and_return(spanish_message_generator)
        post '/', { "Body" => ebt_number, "From" => texter_number, "To" => inbound_twilio_number, "ToState" => to_state }
      end

      it 'sends a text IN SPANISH to the user telling them wait time' do
        expect(fake_twilio).to have_received(:send_text).with(
          to: texter_number,
          from: inbound_twilio_number,
          body: spanish_message_generator.thanks_please_wait
        )
      end

      it 'responds with 200 status' do
        expect(last_response.status).to eq(200)
      end
    end
  end

  describe 'GET /get_balance' do
    let(:texter_number) { "+12223334444" }
    let(:ebt_number) { "5555444433332222" }
    let(:inbound_twilio_number) { "+15556667777" }
    let(:state) { 'CA' }
    let(:ebt_number) { "1111222233334444" }
    let(:fake_state_handler) { double('FakeStateHandler', :button_sequence => "fake_button_sequence", :max_message_length => 22) }

    before do
      allow(StateHandler).to receive(:for).and_return(fake_state_handler)
      get "/get_balance?phone_number=#{texter_number}&twilio_phone_number=#{inbound_twilio_number}&state=#{state}&ebt_number=#{ebt_number}"
      parsed_response = Nokogiri::XML(last_response.body)
      @play_digits = parsed_response.children.children[0].get_attribute("digits")
      @callback_url = parsed_response.children.children[1].get_attribute("transcribeCallback")
      @maxlength = parsed_response.children.children[1].get_attribute("maxLength")
    end

    it "passes the EBT number to the state handler's button sequence method" do
      expect(fake_state_handler).to have_received(:button_sequence).with(ebt_number)
    end

    it 'plays the button sequence for the state' do
      expect(@play_digits).to eq('fake_button_sequence')
    end

    it 'responds with callback to correct URL (ie, correct phone number)' do
      expect(@callback_url).to eq("http://example.org/CA/12223334444/15556667777/send_balance")
    end

    it 'has max recording length set correctly' do
      expect(@maxlength).to eq("22")
    end

    it 'responds with 200 status' do
      expect(last_response.status).to eq(200)
    end
  end

  describe 'sending the balance to user' do
    let(:to_phone_number) { "19998887777" }
    let(:twilio_number) { "+15556667777" }
    let(:fake_twilio) { double("FakeTwilioService", :send_text => 'sent text') }
    let(:state) { 'CA' }

    before do
      allow(TwilioService).to receive(:new).and_return(fake_twilio)
    end

    context 'when EBT number is valid' do
      let(:transcription_text)  { 'fake raw transcription containing balance' }
      let(:handler_balance_response) { 'Hi! Your balance is...' }
      let(:fake_state_handler) { double('FakeStateHandler', :transcribe_balance_response => handler_balance_response) }

      before do
        allow(StateHandler).to receive(:for).with(state).and_return(fake_state_handler)
        post "/#{state}/#{to_phone_number}/#{twilio_number}/send_balance", { "TranscriptionText" => transcription_text }
      end

      it 'sends transcription text and language to the handler' do
        expect(fake_state_handler).to have_received(:transcribe_balance_response).with(transcription_text, :english)
      end

      it 'sends the correct amounts to user' do
        expect(fake_twilio).to have_received(:send_text).with(
          to: to_phone_number,
          from: twilio_number,
          body: handler_balance_response
        )
      end

      it 'returns status 200' do
        expect(last_response.status).to eq(200)
      end
    end

    context 'when EBT number is NOT valid' do
      let(:handler_balance_response) { 'Sorry...' }
      let(:fake_state_handler) { double('FakeStateHandler', :transcribe_balance_response => handler_balance_response) }

      before do
        allow(StateHandler).to receive(:for).with(state).and_return(fake_state_handler)
        post "/#{state}/#{to_phone_number}/#{twilio_number}/send_balance", { "TranscriptionText" => 'fake raw transcription for EBT number not found' }
      end

      it 'sends the user an error message' do
        expect(fake_twilio).to have_received(:send_text).with(
          to: to_phone_number,
          from: twilio_number,
          body: handler_balance_response
        )
      end

      it 'returns status 200' do
        expect(last_response.status).to eq(200)
      end
    end
  end

  describe 'POST /get_balance' do
    before do
      post '/get_balance'
    end

    it 'responds with 200 status' do
      expect(last_response.status).to eq(200)
    end

    it 'responds with valid Twiml that does nothing' do
      desired_response = <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<Response>
</Response>
EOF
      expect(last_response.body).to eq(desired_response)
    end
  end

  describe 'inbound voice call' do
    let(:caller_number) { "+12223334444" }
    let(:inbound_twilio_number) { "+14156667777" }
    let(:to_state) { 'CA' }
    let(:fake_state_phone_number) { '+18882223333' }
    let(:fake_state_handler) { double('FakeStateHandler', :phone_number => fake_state_phone_number) }
    let(:fake_twilio) { double("FakeTwilioService", :send_text => 'sent text') }
    let(:fake_message_generator) { double('MessageGenerator', :inbound_voice_call_text_message => 'voice call text message', :call_in_voice_file_url => 'fakeurl') }

    before do
      allow(TwilioService).to receive(:new).and_return(fake_twilio)
      allow(StateHandler).to receive(:for).with(to_state).and_return(fake_state_handler)
      allow(MessageGenerator).to receive(:new).and_return(fake_message_generator)
      post '/voice_call', { "From" => caller_number, "To" => inbound_twilio_number, "ToState" => to_state }
    end

    it 'responds with 200 status' do
      expect(last_response.status).to eq(200)
    end

    it 'does NOT send an outbound text to the number' do
      expect(fake_twilio).to_not have_received(:send_text)
    end

    it 'plays welcome message to caller and allows them to go to state line' do
      desired_response = <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<Response>
  <Gather timeout="10" action="http://twimlets.com/forward?PhoneNumber=#{fake_state_phone_number}" method="GET" numDigits="1">
    <Play>#{fake_message_generator.call_in_voice_file_url}</Play>
  </Gather>
  <Redirect method="GET">http://twimlets.com/forward?PhoneNumber=#{fake_state_phone_number}</Redirect>
</Response>
EOF
      expect(last_response.body).to eq(desired_response)
    end
  end

  describe 'welcome text message' do
    let(:body) { "Hi there! Reply to this message with your EBT card number and we'll check your balance for you. For more info, text ABOUT." }
    let(:fake_twilio) { double("FakeTwilioService", :send_text => 'sent text') }
    let(:inbound_twilio_number) { "+15556667777" }
    let(:invalid_number_message_text) { "Sorry! That number doesn't look right. Please go back and try again." }

    before(:each) do
      allow(TwilioService).to receive(:new).and_return(fake_twilio)
      post '/welcome', { "inbound_twilio_number" => inbound_twilio_number, "texter_phone_number" => texter_phone_number }
    end

    context 'with a valid phone number' do
      let(:texter_phone_number) { "+12223334444" }

      it 'sends a text to the user with instructions' do
        expect(fake_twilio).to have_received(:send_text).with(
          to: texter_phone_number,
          from: inbound_twilio_number,
          body: body
        )
      end

      it 'responds with 200 status' do
        expect(last_response.status).to eq(200)
      end
    end

    context "with a valid (with formatting) phone number" do
      let(:texter_phone_number) { "(510) 111-2222" }

      it 'sends a text' do
        expect(fake_twilio).to have_received(:send_text).with(
          to: '+15101112222',
          from: inbound_twilio_number,
          body: body
        )
      end

      it 'responds with 200 status' do
        expect(last_response.status).to eq(200)
      end
    end

    context "with garbage input" do
      let(:texter_phone_number) { "asfljhasgkjshgkj" }

      it 'does NOT send a text' do
        expect(fake_twilio).to_not have_received(:send_text)
      end

      it 'responds with 200 status' do
        expect(last_response.status).to eq(200)
      end

      it 'gives error message telling you to try again' do
        expect(last_response.body).to include(invalid_number_message_text)
      end
    end

    context "with an invalid (too long) phone number" do
      let(:texter_phone_number) { "41522233334" }

      it 'does NOT send a text' do
        expect(fake_twilio).to_not have_received(:send_text)
      end

      it 'responds with 200 status' do
        expect(last_response.status).to eq(200)
      end

      it 'gives error message telling you to try again' do
        expect(last_response.body).to include(invalid_number_message_text)
      end
    end

    context "with an invalid (too short) phone number" do
      let(:texter_phone_number) { "415222333" }

      it 'does NOT send a text' do
        expect(fake_twilio).to_not have_received(:send_text)
      end

      it 'responds with 200 status' do
        expect(last_response.status).to eq(200)
      end

      it 'gives error message telling you to try again' do
        expect(last_response.body).to include(invalid_number_message_text)
      end
    end

    context "with a user inputting one of the app's Twilio phone numbers" do
      let(:texter_phone_number) { "555 666 7777" }

      it 'does NOT send a text' do
        expect(fake_twilio).to_not have_received(:send_text)
      end

      it 'responds with 200 status' do
        expect(last_response.status).to eq(200)
      end

      it 'gives error message telling you to try again' do
        expect(last_response.body).to include(invalid_number_message_text)
      end
    end

    context '7 digit phone number' do
      let(:texter_phone_number) { "2223333" }

      it 'does NOT send a text' do
        expect(fake_twilio).to_not have_received(:send_text)
      end

      it 'responds with 200 status' do
        expect(last_response.status).to eq(200)
      end

      it 'gives error message telling you to try again' do
        expect(last_response.body).to include(invalid_number_message_text)
      end
    end
  end
end
