module TranscriptionParsingHelpers
  def clean_trailing_period(amount_string)
    if amount_string[-1] == '.'
      amount_string[0..-2]
    else
      amount_string
    end
  end
end
