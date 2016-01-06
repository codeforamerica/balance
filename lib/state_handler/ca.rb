class StateHandler::CA < StateHandler::Base
  PHONE_NUMBER = '+18773289677'
  ALLOWED_NUMBER_OF_EBT_CARD_DIGITS = [16]

  def button_sequence(ebt_number)
    waiting_ebt_number = ebt_number.split('').join('w')
    "wwww1wwwwww#{waiting_ebt_number}w#ww"
  end

  def transcribe_balance_response(transcription_text, language = :english)
    mg = MessageGenerator.new(language)
    if transcription_text == nil
      return mg.having_trouble_try_again_message
    end
    text_with_dollar_amounts = DollarAmountsProcessor.new.process(transcription_text)
    processed_transcription = process_transcription_for_zero_text(text_with_dollar_amounts)
    regex_matches = processed_transcription.scan(/(\$\S+)/)
    if processed_transcription.include?("non working card")
      mg.card_number_not_found_message
    elsif regex_matches.count > 1
      ebt_amount = clean_trailing_period(regex_matches[0][0])
      cash_amount = clean_trailing_period(regex_matches[1][0])
      return mg.balance_message(ebt_amount, cash: cash_amount)
    else
      mg.having_trouble_try_again_message
    end
  end

  def max_message_length
    22
  end
end
