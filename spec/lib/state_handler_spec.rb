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
