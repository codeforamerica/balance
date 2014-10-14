class StateHandler::TX < StateHandler::Base
  PHONE_NUMBER = '+18007777328'
  ALLOWED_NUMBER_OF_EBT_CARD_DIGITS = [19]

  def button_sequence(ebt_number)
    "wwww1wwwwww#{ebt_number}ww"
  end

  def transcribe_balance_response(transcription_text, language = :english)
    mg = MessageGenerator.new(language)
    if transcription_text == nil
      return mg.having_trouble_try_again_message
    end
    regex_matches = transcription_text.scan(/(\$\S+)/)
    if transcription_text.include?("please enter the")
      mg.card_number_not_found_message
    elsif regex_matches.count > 0
      ebt_amount = regex_matches[0][0]
      if ebt_amount.match(/(\d{5,10})/)
        ebt_amount.gsub!("0","")
      end
      if language == :spanish
        "Hola! El saldo de su cuenta de estampillas para comida es #{ebt_amount}."
      else
        "Hi! Your food stamp balance is #{ebt_amount}."
      end
    else
      mg.having_trouble_try_again_message
    end
  end
end
