require 'spec_helper'
require File.expand_path('../../../lib/transcription', __FILE__)

describe Transcription do
  context 'when the transcription begins with Your food stamp' do
    let(:raw_text) { "Your food stamp balance is $136.33 your cash account balance is $0 as a reminder by saving the receipt from your last purchase and your last a cash purchase for Cash Bank Transaction you will always have your current balance at and will also print your balance on the Cash Withdrawal receipt to hear the number of Cash Withdrawal for that a transaction fee (running?) this month press 1 to hear your last 10 transactions report a transaction there file a claim or check the status of a claim press 2 to report your card lost stolen or damaged press 3 for (pin?) replacement press 4 for additional options press 5" }
    let(:transcription) { Transcription.new(raw_text) }

    it 'processes the ebt amount' do
      expect(transcription.ebt_amount).to eq("$136.33")
    end

    it 'process the cash amount' do
      expect(transcription.cash_amount).to eq("$0")
    end
  end

  context 'when the transcription begins with (Stamp?)' do
    let(:raw_text) { "(Stamp?) balance is $136.33 your cash account balance is $0 as a reminder by saving the receipt from your last purchase and your last a cash purchase or cash back transaction you will always have your current balance at and will also print the balance on the Cash Withdrawal receipt to hear the number of Cash Withdrawal for that a transaction fee this month press 1 to hear your last 10 transactions report a transaction there file a claim or check the status of a claim press 2 to report your card lost stolen or damaged press 3 for (pin?) replacement press 4 for additional options press 5" }
    let(:transcription) { Transcription.new(raw_text) }

    it 'processes the ebt amount' do
      expect(transcription.ebt_amount).to eq("$136.33")
    end

    it 'process the cash amount' do
      expect(transcription.cash_amount).to eq("$0")
    end
  end

  context 'when the transcription begins with Devon Alan' do
    let(:raw_text) { "Devon Alan is $136.33 your cash account balance is $0 as a reminder by saving the receipt from your last purchase and your last the cash purchase or cash back for (action?) you will always have your current balance. I'm at and will also print the balance on the Cash Withdrawal receipt to hear the number of Cash Withdrawal for that a transaction fee (running?) this month press 1 to hear your last 10 transactions report a transaction there file a claim or check the status of a claim press 2 to report your card lost stolen or damaged press 3 for pain placement press 4 for additional options press 5" }
    let(:transcription) { Transcription.new(raw_text) }

    it 'processes the ebt amount' do
      expect(transcription.ebt_amount).to eq("$136.33")
    end

    it 'process the cash amount' do
      expect(transcription.cash_amount).to eq("$0")
    end
  end

  context 'when the transcription is for an invalid EBT number' do
    let(:raw_text) { "Our records indicate the number you have entered it's for an non working card in case your number was entered incorrectly please reenter your 16 digit card number followed by the pound sign." }
    let(:transcription) { Transcription.new(raw_text) }

    it 'is declared invalid' do
      expect(transcription.invalid_ebt_number?).to eq(true)
    end
  end
end
