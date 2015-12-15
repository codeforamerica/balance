<<<<<<< HEAD
# -*- encoding : utf-8 -*-
=======
>>>>>>> added FL handler.
# Step 1. Change "::Example" below to a state abbreviation
# For example, "::PA" for Pennsylvania
class StateHandler::FL < StateHandler::Base

  # Step 2. EXAMPLE — Edit for your state!
  PHONE_NUMBER = '+18883563281'

  # Step 3. EXAMPLE — Edit for your state!
  ALLOWED_NUMBER_OF_EBT_CARD_DIGITS = [16]

  def button_sequence(ebt_number)
    # Step 4. EXAMPLE — Edit for your state!
    "wwww1wwww#{ebt_number}"
  end

<<<<<<< HEAD
=begin # Delete this line when ready to transcribe!
=======

>>>>>>> added FL handler.
  def transcribe_balance_response(transcription_text, language = :english)
    mg = MessageGenerator.new(language)

    # Deal with a failed transcription
    # You do not need to change this. :D
    if transcription_text == nil
      return mg.having_trouble_try_again_message
    end

    # Deal with an invalid card number
<<<<<<< HEAD
    ### Step 5. EXAMPLE — Edit for your state! ###
    phrase_indicating_invalid_card_number = "CHANGE ME"

=======

    ### Step 5. EXAMPLE — Edit for your state! ###
    phrase_indicating_invalid_card_number = "CHANGE ME"


>>>>>>> added FL handler.
    if transcription_text.include?(phrase_indicating_invalid_card_number)
      return mg.card_number_not_found_message
    end

<<<<<<< HEAD
    # Deal with a successful balance transcription
    ### Step 6. EXAMPLE — Edit for your state! ###
=======
      ### Step 6. EXAMPLE — Edit for your state! ###
>>>>>>> added FL handler.
    regex_matches = transcription_text.scan(/(\$\S+)/)
    if regex_matches.count > 0
      ebt_amount = regex_matches[0][0]
      return "Hi! Your food stamp balance is #{ebt_amount}."
    end

    # Deal with any other transcription (catching weird errors)
    # You do not need to change this. :D
    return mg.having_trouble_try_again_message
  end
<<<<<<< HEAD
=end # Delete this line when ready to transcribe
=======
>>>>>>> added FL handler.
end
