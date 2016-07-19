# -*- encoding : utf-8 -*-
class StateHandler::Base
  include TranscriptionParsingHelpers

  def phone_number
    self.class.const_get(:PHONE_NUMBER)
  end

  def allowed_number_of_ebt_card_digits
    self.class.const_get(:ALLOWED_NUMBER_OF_EBT_CARD_DIGITS)
  end

  def extract_valid_ebt_number_from_text(text)
    whitespace_free_text = text.gsub(" ", "")
    dash_and_whitespace_free_text = whitespace_free_text.gsub("-", "")
    number_matches = dash_and_whitespace_free_text.match(/\d+/)
    number = number_matches.to_s
    if allowed_number_of_ebt_card_digits.include?(number.length) && number.match(/\D+/) == nil
      return number
    else
      return :invalid_number
    end
  end

  def transcribe_balance_response(transcription_text, language = :english)
    transcription_text
  end

  def max_message_length
    18
  end
end
