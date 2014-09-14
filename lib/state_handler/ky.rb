# Step 0. Change "::Example" below to a state abbreviation
# For example, "::PA" for Pennsylvania
class StateHandler::Example < StateHandler::Base

  # Step 1. EXAMPLE — Edit for your state!
  PHONE_NUMBER = '+18889799949'

  # Step 2. EXAMPLE — Edit for your state!
  ALLOWED_NUMBER_OF_EBT_CARD_DIGITS = [16]

  def button_sequence(ebt_number)
    # Step 3. EXAMPLE — Edit for your state!
    "wwwwwwww1wwww#{ebt_number}wwwwwwwwwwww"
  end

=begin # Delete this line when ready to transcribe!
  def transcribe_balance_response(transcription_text, language = :english)
    mg = MessageGenerator.new(language)

    # Deal with a failed transcription
    # You do not need to change this. :D
    if transcription_text == nil
      return mg.having_trouble_try_again_message
    end

    # Deal with an invalid card number
    ### Step 4. EXAMPLE — Edit for your state! ###
    phrase_indicating_invalid_card_number = "CHANGE ME"

    if transcription_text.include?(phrase_indicating_invalid_card_number)
      return mg.card_number_not_found_message
    end

    # Deal with a successful balance transcription
    ### Step 5. EXAMPLE — Edit for your state! ###
    regex_matches = transcription_text.scan(/(\$\S+)/)
    if regex_matches.count > 1
      ebt_amount = regex_matches[0][0]
      return "Hi! Your food stamp balance is #{ebt_amount}."
    end

    # Deal with any other transcription (catching weird errors)
    # You do not need to change this. :D
    return mg.having_trouble_try_again_message
  end
=end # Delete this line when ready to transcribe
end
