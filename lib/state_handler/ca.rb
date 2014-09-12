class StateHandler::CA < StateHandler::Base
  PHONE_NUMBER = '+18773289677'
  ALLOWED_NUMBER_OF_EBT_CARD_DIGITS = [16]

  def button_sequence(ebt_number)
    "wwww1wwwwww#{ebt_number}ww"
  end

  def transcribe_balance_response(transcription_text, language = :english)
    mg = MessageGenerator.new(language)
    if transcription_text == nil
      return mg.having_trouble_try_again_message
    end
    regex_matches = transcription_text.scan(/(\$\S+)/)
    if transcription_text.include?("non working card")
      mg.card_number_not_found_message
    elsif regex_matches.count > 1
      ebt_amount = regex_matches[0][0]
      cash_amount = regex_matches[1][0]
      if language == :spanish
        "Hola! El saldo de su cuenta de estampillas para comida es #{ebt_amount} y su balance de dinero en efectivo es #{cash_amount}."
      else
        "Hi! Your food stamp balance is #{ebt_amount} and your cash balance is #{cash_amount}."
      end
    else
      mg.having_trouble_try_again_message
    end
  end
end
