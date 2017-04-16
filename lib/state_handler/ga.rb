class StateHandler::GA < StateHandler::Base
  PHONE_NUMBER = '+18884213281'
  ALLOWED_NUMBER_OF_EBT_CARD_DIGITS = [16]

  def button_sequence(ebt_number)
    "wwww1wwww#{ebt_number}ww"
  end

  def transcribe_balance_response(transcription_text, language = :english)
    mg = MessageGenerator.new(language)

    # Deal with a failed transcription
    if transcription_text == nil
      return mg.having_trouble_try_again_message
    end

    # Deal with an invalid card number
    if transcription_text.downcase.include?("invalid card number")
      return mg.card_number_not_found_message
    end

    # Deal with a successful balance transcription
    regex_matches = transcription_text.scan(/(\$\S+)/)
    if regex_matches.count > 0
      ebt_amount = regex_matches[0][0]
      return "Hi! Your food stamp balance is #{ebt_amount}."
    end

    # Deal with any other transcription (catching weird errors)
    mg.having_trouble_try_again_message
  end
end
