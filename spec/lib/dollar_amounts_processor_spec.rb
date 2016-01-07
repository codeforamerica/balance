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
      )).to eq_text <<-EOOUT
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
      )).to eq_text <<-EOOUT
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
      )).to eq_text <<-EOOUT
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
      )).to eq_text <<-EOOUT
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
      )).to eq_text <<-EOOUT
        Balance is $171.68. Your cash
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
      )).to eq_text <<-EOOUT
        Balance is $401.23. Your cash account
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
      )).to eq_text <<-EOOUT
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
      )).to eq_text <<-EOOUT
        Balance is $0.00. Your cash account balance is $541.00
        as a reminder. By saving the receipt from your last purchase and or
        your last cash purchase or cashback transaction.  You will always have your
        current balance. Some A.T.M.'s will also print your balance on a cash with the.
      EOOUT
    end

    it "replaces words with numbers in sample text #09" do
      expect(subject.process(<<-EOIN
        Balance is twenty two dollars and eight cents. Your cash account balance
        is zero dollars and sixty eight cents. As a reminder...
      EOIN
      )).to eq_text <<-EOOUT
        Balance is $22.08. Your cash account balance
        is $0.68. As a reminder...
      EOOUT
    end

    it "replaces words with numbers in sample text #10" do
      expect(subject.process(<<-EOIN
        One moment please. OK. I've pulled up your account information.
        Your food stamp balance is the row. Dollars and forty two cents. You are
      EOIN
      )).to eq_text <<-EOOUT
        One moment please. OK. I've pulled up your account information.
        Your food stamp balance is $0.42. You are
      EOOUT
    end

    it "replaces words with numbers in euro case #2" do
      expect(subject.process(
        "That balance is one hundred seventy one dollars and sixty eight cents.  Your cash account balance is the euro.  Dollars and ninety cents.  As a reminder.  By saving the receipt from your last purchase and or your last cash purchase or cashback transaction.  You will always have."
      )).to eq_text(
        "That balance is $171.68.  Your cash account balance is $0.90.  As a reminder.  By saving the receipt from your last purchase and or your last cash purchase or cashback transaction.  You will always have."
      )
    end

    it "handles 'the row' zero problem" do
      expect(subject.process(
        "One moment please.  OK.  I've pulled up your account information.  Your food stamp balance is the row.  Dollars and forty two cents.  You are"
      )).to eq_text(
        "One moment please.  OK.  I've pulled up your account information.  Your food stamp balance is $0.42.  You are"
      )
    end

    it "handles case #9" do
      expect(subject.process(
        "They were snapped balances.  Ten dollars and twenty two cents.  Your cash balance is one dollar to repeat your account balance.  Press one.  To hear your last ten transactions on your card.  Press two to change European press three. To report."
      )).to eq_text(
        "They were snapped balances.  $10.22.  Your cash balance is $1.00 to repeat your account balance.  Press one.  To hear your last ten transactions on your card.  Press two to change European press three. To report."
      )
    end

    it "handles case #10" do
      expect(subject.process(
        "Balance is twenty two dollars and eight cents.  Your cash account balance is zero dollars and sixty eight cents.  As a reminder.  By saving the receipt from your last purchase and or your last cash purchase or cash back Prinz action. You will always have your current balance."
      )).to eq_text(
        "Balance is $22.08.  Your cash account balance is $0.68.  As a reminder.  By saving the receipt from your last purchase and or your last cash purchase or cash back Prinz action. You will always have your current balance."
      )
    end

    it "handles case #11" do
      expect(subject.process(
        "Step.  Balance is nineteen dollars and five cents.  Your cash account balance is eight dollars and thirty one cents.  As a reminder.  By saving the receipt from your last purchase and or your last cash purchase or cashback transaction.  You will always have your current balance."
      )).to eq_text(
        "Step.  Balance is $19.05.  Your cash account balance is $8.31.  As a reminder.  By saving the receipt from your last purchase and or your last cash purchase or cashback transaction.  You will always have your current balance."
      )
    end

    it 'handles this case' do
      expect(subject.process(
        "Balance is the euro.  Dollars and seven cents.  Your cash account balance is sixty five dollars and thirty nine cents.  As a reminder.  By saving the receipt from your last purchase and or your last cash purchase or cashback transaction.  You will always have your current balance."
      )).to eq_text(
        "Balance is $0.07.  Your cash account balance is $65.39.  As a reminder.  By saving the receipt from your last purchase and or your last cash purchase or cashback transaction.  You will always have your current balance."
      )
    end

    it "handles some other" do
      expect(subject.process(
        "Nap balances.  Six hundred forty nine dollars.  Your cash balance is zero dollars.  As a reminder by saving the receipt from your last purchase you will know your current balance.  Remember you can also access your account information on."
      )).to eq_text(
        "Nap balances.  $649.00.  Your cash balance is $0.00.  As a reminder by saving the receipt from your last purchase you will know your current balance.  Remember you can also access your account information on."
      )
    end
  end
end
