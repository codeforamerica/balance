class StateHandler::OK < StateHandler::Base
  PHONE_NUMBER = '+18883286551'
  ALLOWED_NUMBER_OF_EBT_CARD_DIGITS = [16]

  def button_sequence(ebt_number)
    "11#{ebt_number}"
  end

  def transcribe_balance_response(transcription_text, language = :english)
    mg = MessageGenerator.new(language)

    # Deal with a failed transcription
    if transcription_text == nil
      return mg.having_trouble_try_again_message
    end

    # Deal with an invalid card number
    phrase_indicating_invalid_card_number = "please try again"

    if transcription_text.include?(phrase_indicating_invalid_card_number)
      return mg.card_number_not_found_message
    end

    # Deal with a successful balance transcription
    regex_matches = transcription_text.scan(/(\$[0-9]+.[0-9]+)/)
        
    if regex_matches.count == 1
      ebt_amount = regex_matches[0][0]+""
      return "Hi! Your food stamp balance is #{ebt_amount}."
    end

    # Deal with any other transcription (catching weird errors)
    # You do not need to change this. :D
    return mg.having_trouble_try_again_message
  end
end