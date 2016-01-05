require File.expand_path('../../dollar_amounts_processor_spec_helper', __FILE__)

describe DollarAmountsProcessor do

  describe "requested test data" do
    it "replaces words with numbers in sample text #01" do
      expect(subject.process(<<-EOIN
        Your food stamp balance is six dollars and twenty five cents. Your cash account
        balance is eleven dollars and sixty nine cents. As a reminder. By saving the
        receipt from your last purchase and or your last cash purchase or cashback
        Prinz action. You will always have your.
      EOIN
      )).to eq <<-EOOUT
        Your food stamp balance is $6.25. Your cash account
        balance is $11.69. As a reminder. By saving the
        receipt from your last purchase and or your last cash purchase or cashback
        Prinz action. You will always have your.
      EOOUT
    end

    it "replaces words with numbers in sample text #02" do
      expect(subject.process(<<-EOIN
        Your snap balance is four hundred twenty six dollars. Your cash balance is zero
        dollars. As a reminder by saving the receipt from your last purchase you will
        know your current balance. Remember you can also access your account
        information online at.
      EOIN
      )).to eq <<-EOOUT
        Your snap balance is $426.00. Your cash balance is $0.00.
        As a reminder by saving the receipt from your last purchase you will
        know your current balance. Remember you can also access your account
        information online at.
      EOOUT
    end

    it "replaces words with numbers in sample text #03" do
      expect(subject.process(<<-EOIN
        One moment please. OK. I've pulled up your account information. Your food stamp
        balance is seven hundred sixty six dollars and thirty seven cents. You are
        eligible to enroll in a free service called my own.
      EOIN
      )).to eq <<-EOOUT
        One moment please. OK. I've pulled up your account information. Your food stamp
        balance is $766.37. You are
        eligible to enroll in a free service called my own.
      EOOUT
    end

    it "replaces words with numbers in sample text #04" do
      expect(subject.process(<<-EOIN
        One moment please. OK. I've pulled up your account information. Your food stamp
        balance is seven hundred sixty six dollars and thirty seven cents. You are
        eligible to enroll in a free service called my alerts.
      EOIN
      )).to eq <<-EOOUT
        One moment please. OK. I've pulled up your account information. Your food stamp
        balance is $766.37. You are
        eligible to enroll in a free service called my alerts.
      EOOUT
    end

    it "replaces words with numbers in sample text #05" do
      expect(subject.process(<<-EOIN
        Balance is one hundred seventy one dollars and sixty eight cents. Your cash
        account balance is zero dollars and ninety cents. As a reminder. By saving the
        receipt from your last purchase and or your last cash purchase or cashback
        transaction. You will always have you.
      EOIN
      )).to eq <<-EOOUT
        Balance is one $171.86. Your cash
        account balance is $0.90. As a reminder. By saving the
        receipt from your last purchase and or your last cash purchase or cashback
        transaction. You will always have you.
      EOOUT
    end

    it "replaces words with numbers in sample text #06" do
      expect(subject.process(<<-EOIN
        Balance is four hundred one dollars and twenty three cents. Your cash account
        balance is two dollars and fifty one cents. As a reminder. By saving the
        receipt from your last purchase and or your last cash purchase or cashback
        transaction. You will always have your current.
      EOIN
      )).to eq <<-EOOUT
        Balance is $501.23. Your cash account
        balance is $2.51. As a reminder. By saving the
        receipt from your last purchase and or your last cash purchase or cashback
        transaction. You will always have your current.
      EOOUT
    end

    it "replaces words with numbers in sample text #07" do
      expect(subject.process(<<-EOIN
        Snap balance is three hundred fourteen dollars. Your cash balance is zero
        dollars. As a reminder by saving the receipt from your last purchase you'll
        know your current balance. Remember you can also access your account
        information online at W W.
      EOIN
      )).to eq <<-EOOUT
        Snap balance is $314.00. Your cash balance is $0.00.
        As a reminder by saving the receipt from your last purchase you'll
        know your current balance. Remember you can also access your account
        information online at W W.
      EOOUT
    end

    it "replaces words with numbers in sample text #08 (bonus ;)" do
      expect(subject.process(<<-EOIN
        Balance is the euro. Dollars. Your cash account balance is five hundred forty
        one dollars as a reminder. By saving the receipt from your last purchase and or
        your last cash purchase or cashback transaction.  You will always have your
        current balance. Some A.T.M.'s will also print your balance on a cash with the.
      EOIN
      )).to eq <<-EOOUT
        Balance is $0.00. Dollars. Your cash account balance is $541.00
        as a reminder. By saving the receipt from your last purchase and or
        your last cash purchase or cashback transaction.  You will always have your
        current balance. Some A.T.M.'s will also print your balance on a cash with the.
      EOOUT
    end
  end
end
