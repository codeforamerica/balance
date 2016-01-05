require File.expand_path('../../dollar_amounts_processor_spec_helper', __FILE__)

describe DollarAmountsProcessor do

  describe "requested test data" do
    it "replaces words with numbers" do
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
  end

end
