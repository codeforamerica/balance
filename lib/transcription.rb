class Transcription
  attr_reader :raw_text, :ebt_amount, :cash_amount

  def initialize(raw_text)
    @raw_text = raw_text
    if !invalid_ebt_number?
      regex_matches = @raw_text.scan(/(\$\S+)/)
      @ebt_amount = regex_matches[0][0]
      @cash_amount = regex_matches[1][0]
    end
  end

  def invalid_ebt_number?
    if raw_text.include?("non working card")
      true
    else
      false
    end
  end
end
