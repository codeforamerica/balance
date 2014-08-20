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
end

describe StateHandler::UnhandledState do
  it 'uses CA handler methods' do
    expect(subject.phone_number).to eq(StateHandler::CA.phone_number)
    expect(subject.button_sequence('123')).to eq(StateHandler::CA.button_sequence('123'))
  end
end
