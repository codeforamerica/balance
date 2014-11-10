# Step 0. Change "::Example" below to a state abbreviation
# For example, "::PA" for Pennsylvania
class StateHandler::PA < StateHandler::Base

  # Step 1. EXAMPLE — Edit for your state!
  PHONE_NUMBER = '+18883287366'

  # Step 2. EXAMPLE — Edit for your state!
  ALLOWED_NUMBER_OF_EBT_CARD_DIGITS = [19]

  def button_sequence(ebt_number)
    # Step 3. EXAMPLE — Edit for your state!
    "wwww1wwww#{ebt_number}ww"
  end

  def transcribe_balance_response(transcription_text, language = :english)
    mg = MessageGenerator.new(language)

    # Deal with a failed transcription
    # You do not need to change this. :D
    if transcription_text == nil
      return mg.having_trouble_try_again_message
    end

    # Deal with an invalid card number
    ### Step 4. EXAMPLE — Edit for your state! ###
    phrase_indicating_invalid_card_number = "Invalid Card Number"

    if transcription_text.include?(phrase_indicating_invalid_card_number)
      return mg.card_number_not_found_message
    end

    # Deal with a successful balance transcription
    ### Step 5. EXAMPLE — Edit for your state! ###
    regex_matches = transcription_text.scan(/(\$\S+)/)
    if regex_matches.count > 1
      ebt_amount = regex_matches[0][0]
      cash_amount = regex_matches[1][0]
      return mg.balance_message(ebt_amount, cash: cash_amount)
    end

    # Deal with any other transcription (catching weird errors)
    # You do not need to change this. :D
    return mg.having_trouble_try_again_message
  end
end
