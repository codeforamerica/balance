class Transcription
  attr_reader :raw_text, :ebt_amount, :cash_amount

  def initialize(raw_text)
    @raw_text = raw_text
    regex_matches = @raw_text.scan(/(\$\S+)/)
    @ebt_amount = regex_matches[0][0]
    @cash_amount = regex_matches[1][0]
  end
end
