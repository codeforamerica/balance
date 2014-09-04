require 'phone_number_processor_spec_helper'
require File.expand_path('../../../lib/phone_number_processor', __FILE__)

describe PhoneNumberProcessor do
  describe '#language_for' do
    before(:each) do
      VCR.use_cassette('phone_number_api_call') do
        @pnp = PhoneNumberProcessor.new
      end
    end

    context "given a phone number with 'spanish' in its friendly name" do
      let(:twilio_phone_number) { '+14151112222' }

      it 'returns :spanish' do
        result = @pnp.language_for(twilio_phone_number)
        expect(result).to eq(:spanish)
      end
    end

    context "given a phone number with no language in its friendly name" do
      let(:twilio_phone_number) { '+15103334444' }

      it 'returns :english' do
        result = @pnp.language_for(twilio_phone_number)
        expect(result).to eq(:english)
      end
    end
  end
end
