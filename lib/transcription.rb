class Transcription
  attr_reader :raw_text, :ebt_amount, :cash_amount

  def initialize(raw_text)
    @raw_text = raw_text
    @ebt_amount = extract_ebt_amount
    @cash_amount = extract_cash_amount
  end

  private
  def extract_ebt_amount
    @raw_text.match(/balance is (.+) your cash/)[1]
  end

  def extract_cash_amount
    @raw_text.match(/cash account balance is (.+) as/)[1]
  end
end
