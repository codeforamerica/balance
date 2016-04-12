# -*- encoding : utf-8 -*-
require 'spec_helper'
require File.expand_path('../../../lib/balance_log_analyzer', __FILE__)

describe BalanceLogAnalyzer::MessageAnalyzer do
  describe '#contains_balance_response?' do
    it 'returns true for valid English balance responses' do
      helper = BalanceLogAnalyzer::MessageAnalyzer.new

      ex1 = "Hi! Your food stamp balance is $4.23 and your cash balance is $0."
      expect(helper.contains_balance_response?(ex1)).to eq(true)

      ex2 = "I'm sorry! We're having trouble contacting the EBT system right now. Please try again in a few minutes or call this # and press 1 to use the state phone system."
      expect(helper.contains_balance_response?(ex2)).to eq(true)

      ex3 = "I'm sorry, that card number was not found. Please try again."
      expect(helper.contains_balance_response?(ex3)).to eq(true)
    end

    it 'returns false for other app message' do
      helper = BalanceLogAnalyzer::MessageAnalyzer.new

      ex4 = "Thanks! Please wait 1-2 minutes while we check your balance."
      expect(helper.contains_balance_response?(ex4)).to eq(false)

      ex5 = "Sorry! That number doesn't look right. Please reply with your EBT card number."
      expect(helper.contains_balance_response?(ex5)).to eq(false)

      ex6 = "Hi there! Reply to this message with your EBT card number and we'll check your balance for you. For more info, text ABOUT."
      expect(helper.contains_balance_response?(ex6)).to eq(false)

      ex7 = "This is a free text service provided by non-profit Code for America for checking your EBT balance (standard rates apply). For more info go to www.c4a.me/balance"
      expect(helper.contains_balance_response?(ex7)).to eq(false)
    end
  end
end
