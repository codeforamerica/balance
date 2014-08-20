require 'spec_helper'
require File.expand_path('../../../lib/state_handler', __FILE__)

describe StateHandler do
  describe '::for' do
    context 'given a state with an existing handler' do
      it "returns the state's handler module" do
        handler = StateHandler.for('CA')
        expect(handler).to eq(StateHandler::CA)
      end
    end
    context 'given a state WITHOUT an existing handler' do
      it "returns Nil handler" do
        handler = StateHandler.for('PR')
        expect(handler).to eq(StateHandler::UnhandledState)
      end
    end
  end
end

describe StateHandler::CA do
  it 'serves the correct phone number' do
    expect(subject.phone_number).to eq('+18773289677')
  end

  it 'gives correct button sequence' do
    fake_ebt_number = '11112222'
    desired_sequence = subject.button_sequence(fake_ebt_number)
    expect(desired_sequence).to eq("ww1ww#{fake_ebt_number}")
  end

  it 'tells the number of digits a CA EBT card has' do
    expect(subject.allowed_number_of_ebt_card_digits).to eq([16])
  end

  describe 'EBT number extraction' do
    it 'extracts a valid EBT number for that state from plain text' do
      ebt_number = '1111222233334444'
      inbound_text = "my ebt is #{ebt_number}"
      extracted_number = subject.extract_valid_ebt_number_from_text(inbound_text)
      expect(extracted_number).to eq(ebt_number)
    end

    it 'returns :invalid_number if not a valid number' do
      inbound_text = 'my ebt is 123'
      extracted_number = subject.extract_valid_ebt_number_from_text(inbound_text)
      expect(extracted_number).to eq(:invalid_number)
    end
  end
end

describe StateHandler::UnhandledState do
  it 'uses CA handler methods' do
    expect(subject.phone_number).to eq(StateHandler::CA.phone_number)
    expect(subject.button_sequence('123')).to eq(StateHandler::CA.button_sequence('123'))
  end
end
