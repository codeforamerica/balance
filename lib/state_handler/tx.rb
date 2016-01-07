class StateHandler::TX < StateHandler::Base
  PHONE_NUMBER = '+18007777328'
  ALLOWED_NUMBER_OF_EBT_CARD_DIGITS = [19]

  def button_sequence(ebt_number)
    "wwww1wwwwww#{ebt_number}wwww"
  end

  def transcribe_balance_response(transcription_text, language = :english)
    mg = MessageGenerator.new(language)
    if transcription_text == nil
      return mg.having_trouble_try_again_message
    end
    text_with_dollar_amounts = DollarAmountsProcessor.new.process(transcription_text)
    regex_matches = text_with_dollar_amounts.scan(/(\$\S+)/)
    if transcription_text.include?("please enter the")
      mg.card_number_not_found_message
    elsif regex_matches.count > 0
      ebt_amount = clean_trailing_period(regex_matches[0][0])
      if ebt_amount.match(/(\d{5,10})/)
        ebt_amount.gsub!("0","")
      end
      return mg.balance_message(ebt_amount)
    else
      mg.having_trouble_try_again_message
    end
  end
end
