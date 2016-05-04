# -*- encoding : utf-8 -*-
module TranscriptionParsingHelpers
  def clean_trailing_period(amount_string)
    if amount_string[-1] == '.'
      amount_string[0..-2]
    else
      amount_string
    end
  end

  def process_transcription_for_zero_text(text)
    text.gsub("zero dollars", "$0")
  end
end
