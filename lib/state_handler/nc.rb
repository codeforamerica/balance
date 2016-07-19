# -*- encoding : utf-8 -*-
# Step 1. Change "::Example" below to a state abbreviation
# For example, "::PA" for Pennsylvania
class StateHandler::NC < StateHandler::Base

  # Step 2. EXAMPLE — Edit for your state!
  PHONE_NUMBER = '+18886227328'

  # Step 3. EXAMPLE — Edit for your state!
  ALLOWED_NUMBER_OF_EBT_CARD_DIGITS = [16]

  def button_sequence(ebt_number)
    # Step 4. EXAMPLE — Edit for your state!
    "wwww1wwwwww#{ebt_number}ww"
  end

  def transcribe_balance_response(transcription_text, language = :english)
    mg = MessageGenerator.new(language)

    # Deal with a failed transcription
    # You do not need to change this. :D
    if transcription_text == nil
      return mg.having_trouble_try_again_message
    end

    # Deal with an invalid card number
    if transcription_text.include?("re enter") || transcription_text.include?("reenter")
      return mg.card_number_not_found_message
    end

    # Deal with a successful balance transcription
    ### Step 6. EXAMPLE — Edit for your state! ###
    text_with_dollar_amounts = DollarAmountsProcessor.new.process(transcription_text)
    regex_matches = text_with_dollar_amounts.scan(/(\$\S+)/)
    if regex_matches.count == 1
      ebt_amount = regex_matches[0][0]
      return "Hi! Your food and nutrition benefits balance is #{ebt_amount}."
    end

    puts "[DEBUG] #{transcription_text.inspect}"

    # Deal with any other transcription (catching weird errors)
    # You do not need to change this. :D
    return mg.having_trouble_try_again_message
  end
end
