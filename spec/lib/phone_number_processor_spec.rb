# -*- encoding : utf-8 -*-
require File.expand_path('../../phone_number_processor_spec_helper', __FILE__)

describe PhoneNumberProcessor do
  before(:each) do
    VCR.use_cassette('phone_number_api_call') do
      @pnp = PhoneNumberProcessor.new
    end
  end

  describe '#twilio_number?' do
    context 'given a phone number that is a known Twilio number' do
      let(:twilio_phone_number) { '+14151112222' }

      it 'returns true' do
        result = @pnp.twilio_number?(twilio_phone_number)
        expect(result).to eq(true)
      end
    end

    context 'given a phone number that is a known Twilio number' do
      let(:not_a_twilio_phone_number) { '+10009998888' }

      it 'returns true' do
        result = @pnp.twilio_number?(not_a_twilio_phone_number)
        expect(result).to eq(false)
      end
    end
  end

  describe '#language_for' do
    context "given a phone number with 'spanish' in its friendly name" do
      let(:twilio_phone_number) { '+14151112222' }

      it 'returns :spanish' do
        result = @pnp.language_for(twilio_phone_number)
        expect(result).to eq(:spanish)
      end
    end

    context "given a phone number missing a + sign" do
      let(:twilio_phone_number) { '14151112222' }

      it 'returns the correct language' do
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
