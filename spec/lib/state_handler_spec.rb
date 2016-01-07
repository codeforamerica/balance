require 'spec_helper'
require File.expand_path('../../../lib/state_handler', __FILE__)

describe StateHandler do
  describe '::for' do
    context 'given a state with an existing handler' do
      it "returns the state's handler module" do
        handler = StateHandler.for('CA')
        expect(handler).to be_instance_of(StateHandler::CA)
      end
    end
    context 'given a state WITHOUT an existing handler' do
      it "returns Nil handler" do
        handler = StateHandler.for('PR')
        expect(handler).to be_instance_of(StateHandler::UnhandledState)
      end
    end
  end
end

describe StateHandler::Base do
  let(:subject) { StateHandler::Base.new }

  describe 'default #transcribe_balance_response for a handler' do
    it 'gives back the verbatim input' do
      expect(subject.transcribe_balance_response("hi")).to eq("hi")
    end
  end

  describe 'default #max_message_length for a handler' do
    it 'is 18' do
      expect(subject.max_message_length).to eq(18)
    end
  end
end

describe StateHandler::AK do
  describe 'balance transcription processing' do
    let(:transcription_with_trailing_period) { "1:00 moment please. Okay. I pulled up your account information. Your food stamp balance is $3.48. You are eligible to enroll in (new?) free service called." }

    # DUMMY — not taken from real logs
    let(:successful_transcription_1) { "blah $123.45 blah" }

    # DUMMY — not taken from real logs
    let(:transcription_ebt_not_found) { "blah having trouble locating blah" }

    let(:failed_transcription) { nil }

    context 'for English' do
      context 'with transcription containing balance' do
        it 'sends response with balance amounts' do
          reply_for_user = subject.transcribe_balance_response(successful_transcription_1)
          expect(reply_for_user).to eq("Hi! Your food stamp balance is $123.45.")
        end
      end

      context 'with transcription with trailing period on balance amount' do
        it 'sends balance without trailing period' do
          reply_for_user = subject.transcribe_balance_response(transcription_with_trailing_period)
          expect(reply_for_user).to eq("Hi! Your food stamp balance is $3.48.")
        end
      end

      context 'with EBT card not found in system' do
        it 'sends EBT-not-found message' do
          reply_for_user = subject.transcribe_balance_response(transcription_ebt_not_found)
          expect(reply_for_user).to eq("I'm sorry, that card number was not found. Please try again.")
        end
      end

      context 'with a failed (nil) transcription' do
        it 'sends EBT-not-found message' do
          reply_for_user = subject.transcribe_balance_response(failed_transcription)
          expect(reply_for_user).to eq(MessageGenerator.new.having_trouble_try_again_message)
        end
      end

      context 'with an English-language amount' do
        it 'processes it as a dollar amount successfully' do
          transcription = "One moment please. OK. I've pulled up your account information. Your food stamp balance is seven hundred sixty six dollars and thirty seven cents. You are eligible to enroll in a free service called my own."
          reply_for_user = subject.transcribe_balance_response(transcription)
          expect(reply_for_user).to eq("Hi! Your food stamp balance is $766.37.")
        end
      end
    end

    context 'for Spanish' do
      let(:language) { :spanish }

      context 'with transcription containing balance variation 1' do
        it 'sends response with balance amounts' do
          reply_for_user = subject.transcribe_balance_response(successful_transcription_1, language)
          expect(reply_for_user).to eq("Hola! El saldo de su cuenta de estampillas para comida es $123.45.")
        end
      end

      context 'with EBT card not found in system' do
        it 'sends EBT-not-found message' do
          reply_for_user = subject.transcribe_balance_response(transcription_ebt_not_found, language)
          expect(reply_for_user).to eq("Lo siento, no se encontró el número de tarjeta. Por favor, inténtelo de nuevo.")
        end
      end

      context 'with a failed (nil) transcription' do
        it 'sends EBT-not-found message' do
          reply_for_user = subject.transcribe_balance_response(failed_transcription, language)
          expect(reply_for_user).to eq("Lo siento! Actualmente estamos teniendo problemas comunicándonos con el sistema de EBT. Favor de enviar su # de EBT por texto en unos minutos.")
        end
      end
    end
  end
end

describe StateHandler::CA do
  let(:handler) { StateHandler::CA.new }

  it 'serves the correct phone number' do
    expect(subject.phone_number).to eq('+18773289677')
  end

  it 'gives correct button sequence (ebt # with pauses between digits and pound at end)' do
    fake_ebt_number = '11112222'
    desired_sequence = subject.button_sequence(fake_ebt_number)
    expect(desired_sequence).to eq("wwww1wwwwww1w1w1w1w2w2w2w2w#ww")
  end

  it 'tells the number of digits a CA EBT card has' do
    expect(subject.allowed_number_of_ebt_card_digits).to eq([16])
  end

  describe 'EBT number extraction' do
    it 'extracts a valid EBT number for that state from plain text' do
      ebt_number = '1111222233334444'
      inbound_text = "my ebt is #{ebt_number}"
      extracted_number = subject.extract_valid_ebt_number_from_text(inbound_text)
      expect(extracted_number).to eq(ebt_number)
    end

    it 'processes a valid EBT number with spaces' do
      ebt_number = '1111 2222 3333 4444'
      extracted_number = subject.extract_valid_ebt_number_from_text(ebt_number)
      expect(extracted_number).to eq("1111222233334444")
    end

    it 'processes a valid EBT number with dashes' do
      ebt_number = '1111-2222-3333-4444'
      extracted_number = subject.extract_valid_ebt_number_from_text(ebt_number)
      expect(extracted_number).to eq("1111222233334444")
    end

    it 'returns :invalid_number if not a valid number' do
      inbound_text = 'my ebt is 123'
      extracted_number = subject.extract_valid_ebt_number_from_text(inbound_text)
      expect(extracted_number).to eq(:invalid_number)
    end

    it 'returns a value of 22 for #max_message_length' do
      expect(subject.max_message_length).to eq(22)
    end
  end

  describe 'balance transcriber' do


    context 'for English' do
      let(:language) { :english }

      context 'with transcription containing balance variation 1' do
        it 'sends response with balance amounts' do
          successful_transcription_1 = "Your food stamp balance is $136.33 your cash account balance is $0 as a reminder by saving the receipt from your last purchase and your last a cash purchase for Cash Bank Transaction you will always have your current balance at and will also print your balance on the Cash Withdrawal receipt to hear the number of Cash Withdrawal for that a transaction fee (running?) this month press 1 to hear your last 10 transactions report a transaction there file a claim or check the status of a claim press 2 to report your card lost stolen or damaged press 3 for (pin?) replacement press 4 for additional options press 5"

          reply_for_user = subject.transcribe_balance_response(successful_transcription_1)
          expect(reply_for_user).to eq("Hi! Your food stamp balance is $136.33 and your cash balance is $0.")
        end
      end

      context 'with transcription containing balance variation 2' do
        it 'sends response with balance amounts' do
          successful_transcription_2 = "(Stamp?) balance is $123.11 your cash account balance is $11.32 as a reminder by saving the receipt from your last purchase and your last a cash purchase or cash back transaction you will always have your current balance at and will also print the balance on the Cash Withdrawal receipt to hear the number of Cash Withdrawal for that a transaction fee this month press 1 to hear your last 10 transactions report a transaction there file a claim or check the status of a claim press 2 to report your card lost stolen or damaged press 3 for (pin?) replacement press 4 for additional options press 5"

          reply_for_user = subject.transcribe_balance_response(successful_transcription_2)
          expect(reply_for_user).to eq("Hi! Your food stamp balance is $123.11 and your cash balance is $11.32.")
        end
      end

      context 'with transcription containing balance variation 3' do
        it 'sends response with balance amounts' do
          successful_transcription_3 = "Devon Alan is $156.89 your cash account balance is $4.23 as a reminder by saving the receipt from your last purchase and your last the cash purchase or cash back for (action?) you will always have your current balance. I'm at and will also print the balance on the Cash Withdrawal receipt to hear the number of Cash Withdrawal for that a transaction fee (running?) this month press 1 to hear your last 10 transactions report a transaction there file a claim or check the status of a claim press 2 to report your card lost stolen or damaged press 3 for pain placement press 4 for additional options press 5"

          reply_for_user = subject.transcribe_balance_response(successful_transcription_3)
          expect(reply_for_user).to eq("Hi! Your food stamp balance is $156.89 and your cash balance is $4.23.")
        end
      end

      context 'with English language (not number) dollar amounts' do
        it 'sends a numerical value back to the user' do
          transcription_with_english_amounts = 'Your food stamp balance is six dollars and twenty five cents. Your cash account balance is eleven dollars and sixty nine cents. As a reminder. By saving the receipt from your last purchase and or your last cash purchase or cashback Prinz action. You will always have your.'

          reply_for_user = subject.transcribe_balance_response(transcription_with_english_amounts)
          expect(reply_for_user).to eq("Hi! Your food stamp balance is $6.25 and your cash balance is $11.69.")
        end
      end

      context 'with a transcription with extraneous periods' do
        it 'sends response with balance amounts without extra periods' do
          successful_transcription_extra_periods = "Your food stamp balance is $9.11. Your cash account balance is $13.93. As a reminder. Bye C."

          reply_for_user = subject.transcribe_balance_response(successful_transcription_extra_periods)
          expect(reply_for_user).to eq("Hi! Your food stamp balance is $9.11 and your cash balance is $13.93.")
        end
      end

      context 'with EBT card not found in system' do
        it 'sends EBT-not-found message' do
          transcription_ebt_not_found = "Our records indicate the number you have entered it's for an non working card in case your number was entered incorrectly please reenter your 16 digit card number followed by the pound sign."

          reply_for_user = subject.transcribe_balance_response(transcription_ebt_not_found)
          expect(reply_for_user).to eq("I'm sorry, that card number was not found. Please try again.")
        end
      end

      context 'with a failed (nil) transcription' do
        let(:failed_transcription) { nil }

        it 'sends EBT-not-found message' do
          reply_for_user = subject.transcribe_balance_response(failed_transcription)
          expect(reply_for_user).to eq(MessageGenerator.new.having_trouble_try_again_message)
        end
      end

      context 'with zero dollar values in words' do
        it 'correctly parses the zeroes as values' do
          transcription_with_zero_as_words = "Balance is zero dollars. Your cash account balance is zero dollars. As a reminder by saving the receipt from your last purchase and or your last cash purchase or cash back transaction."

          reply_for_user = subject.transcribe_balance_response(transcription_with_zero_as_words)
          expect(reply_for_user).to eq("Hi! Your food stamp balance is $0.00 and your cash balance is $0.00.")
        end
      end
    end

    context 'for Spanish' do
      let(:language) { :spanish }

      context 'with transcription containing balance variation 1' do
        it 'sends response with balance amounts' do
          successful_transcription_1 = "Your food stamp balance is $136.33 your cash account balance is $0 as a reminder by saving the receipt from your last purchase and your last a cash purchase for Cash Bank Transaction you will always have your current balance at and will also print your balance on the Cash Withdrawal receipt to hear the number of Cash Withdrawal for that a transaction fee (running?) this month press 1 to hear your last 10 transactions report a transaction there file a claim or check the status of a claim press 2 to report your card lost stolen or damaged press 3 for (pin?) replacement press 4 for additional options press 5"

          reply_for_user = subject.transcribe_balance_response(successful_transcription_1, language)
          expect(reply_for_user).to eq("Hola! El saldo de su cuenta de estampillas para comida es $136.33 y su balance de dinero en efectivo es $0.")
        end
      end

      context 'with transcription containing balance variation 2' do
        it 'sends response with balance amounts' do
          successful_transcription_2 = "(Stamp?) balance is $123.11 your cash account balance is $11.32 as a reminder by saving the receipt from your last purchase and your last a cash purchase or cash back transaction you will always have your current balance at and will also print the balance on the Cash Withdrawal receipt to hear the number of Cash Withdrawal for that a transaction fee this month press 1 to hear your last 10 transactions report a transaction there file a claim or check the status of a claim press 2 to report your card lost stolen or damaged press 3 for (pin?) replacement press 4 for additional options press 5"

          reply_for_user = subject.transcribe_balance_response(successful_transcription_2, language)
          expect(reply_for_user).to eq("Hola! El saldo de su cuenta de estampillas para comida es $123.11 y su balance de dinero en efectivo es $11.32.")
        end
      end

      context 'with transcription containing balance variation 3' do
        it 'sends response with balance amounts' do
          successful_transcription_3 = "Devon Alan is $156.89 your cash account balance is $4.23 as a reminder by saving the receipt from your last purchase and your last the cash purchase or cash back for (action?) you will always have your current balance. I'm at and will also print the balance on the Cash Withdrawal receipt to hear the number of Cash Withdrawal for that a transaction fee (running?) this month press 1 to hear your last 10 transactions report a transaction there file a claim or check the status of a claim press 2 to report your card lost stolen or damaged press 3 for pain placement press 4 for additional options press 5"

          reply_for_user = subject.transcribe_balance_response(successful_transcription_3, language)
          expect(reply_for_user).to eq("Hola! El saldo de su cuenta de estampillas para comida es $156.89 y su balance de dinero en efectivo es $4.23.")
        end
      end

      context 'with EBT card not found in system' do
          transcription_ebt_not_found = "Our records indicate the number you have entered it's for an non working card in case your number was entered incorrectly please reenter your 16 digit card number followed by the pound sign."

        it 'sends EBT-not-found message' do
          reply_for_user = subject.transcribe_balance_response(transcription_ebt_not_found, language)
          expect(reply_for_user).to eq("Lo siento, no se encontró el número de tarjeta. Por favor, inténtelo de nuevo.")
        end
      end

      context 'with a failed (nil) transcription' do
        let(:failed_transcription) { nil }

        it 'sends EBT-not-found message' do
          reply_for_user = subject.transcribe_balance_response(failed_transcription, language)
          expect(reply_for_user).to eq("Lo siento! Actualmente estamos teniendo problemas comunicándonos con el sistema de EBT. Favor de enviar su # de EBT por texto en unos minutos.")
        end
      end
    end
  end
end

describe StateHandler::MO do
  it 'serves the correct phone number' do
    expect(subject.phone_number).to eq('+18009977777')
  end

  it 'gives correct button sequence' do
    fake_ebt_number = '11112222'
    desired_sequence = subject.button_sequence(fake_ebt_number)
    expect(desired_sequence).to eq("wwwwwwwwwwwwww1wwwwwwwwwwwwwwwwww2wwwwwwww#{fake_ebt_number}")
  end

  it 'tells the number of digits a CA EBT card has' do
    expect(subject.allowed_number_of_ebt_card_digits).to eq([16])
  end

  describe 'EBT number extraction' do
    it 'extracts a valid EBT number for that state from plain text' do
      ebt_number = '1111222233334444'
      inbound_text = "my ebt is #{ebt_number}"
      extracted_number = subject.extract_valid_ebt_number_from_text(inbound_text)
      expect(extracted_number).to eq(ebt_number)
    end

    it 'returns :invalid_number if not a valid number' do
      inbound_text = 'my ebt is 123'
      extracted_number = subject.extract_valid_ebt_number_from_text(inbound_text)
      expect(extracted_number).to eq(:invalid_number)
    end
  end

  describe 'balance transcription processing' do
    let(:successful_transcription_1) { "That is the balance you have $154.70 for food stamps to hear that again say repeat that or if you're down here just." }
    let(:transcription_ebt_not_found) { "If you don't have a card number say I don't have it otherwise please say or the 16 digit EBT card number now." }
    let(:failed_transcription) { nil }

    context 'for English' do
      context 'with transcription containing balance variation 1' do
        it 'sends response with balance amounts' do
          reply_for_user = subject.transcribe_balance_response(successful_transcription_1)
          expect(reply_for_user).to eq("Hi! Your food stamp balance is $154.70.")
        end
      end

      context 'with an English-language amount' do
        it 'processes it as a dollar amount successfully' do
          # Not taken from logs; just modified above example with English-language dollar amount
          transcription = "That is the balance you have one hundred fifty four dollars and seventy cents for food stamps to hear that again say repeat that or if you're down here just."
          reply_for_user = subject.transcribe_balance_response(transcription)
          expect(reply_for_user).to eq("Hi! Your food stamp balance is $154.70.")
        end
      end

      context 'with EBT card not found in system' do
        it 'sends EBT-not-found message' do
          reply_for_user = subject.transcribe_balance_response(transcription_ebt_not_found)
          expect(reply_for_user).to eq("I'm sorry, that card number was not found. Please try again.")
        end
      end

      context 'with a failed (nil) transcription' do
        it 'sends EBT-not-found message' do
          reply_for_user = subject.transcribe_balance_response(failed_transcription)
          expect(reply_for_user).to eq("I'm really sorry! We're having trouble contacting the EBT system right now. Please text your EBT # again in a few minutes.")
        end
      end
    end

    context 'for Spanish' do
      let(:language) { :spanish }

      context 'with transcription containing balance variation 1' do
        it 'sends response with balance amounts' do
          reply_for_user = subject.transcribe_balance_response(successful_transcription_1, language)
          expect(reply_for_user).to eq("Hola! El saldo de su cuenta de estampillas para comida es $154.70.")
        end
      end

      context 'with EBT card not found in system' do
        it 'sends EBT-not-found message' do
          reply_for_user = subject.transcribe_balance_response(transcription_ebt_not_found, language)
          expect(reply_for_user).to eq("Lo siento, no se encontró el número de tarjeta. Por favor, inténtelo de nuevo.")
        end
      end

      context 'with a failed (nil) transcription' do
        it 'sends EBT-not-found message' do
          reply_for_user = subject.transcribe_balance_response(failed_transcription, language)
          expect(reply_for_user).to eq("Lo siento! Actualmente estamos teniendo problemas comunicándonos con el sistema de EBT. Favor de enviar su # de EBT por texto en unos minutos.")
        end
      end
    end
  end
end

describe StateHandler::NC do
  describe 'balance transcription processing' do

    # DUMMY — not taken from real logs
    let(:successful_transcription_1) { "blah $123.45 blah" }

    # DUMMY — not taken from real logs
    let(:transcription_ebt_not_found) { "blah reenter blah" }

    let(:failed_transcription) { nil }

    context 'with transcription containing balance' do
      it 'sends response with balance amounts in language specific to NC' do
        reply_for_user = subject.transcribe_balance_response(successful_transcription_1)
        expect(reply_for_user).to eq("Hi! Your food and nutrition benefits balance is $123.45.")
      end
    end

    context 'with an English-language amount' do
      it 'processes it as a dollar amount successfully' do
        # Not taken from logs; just modified above example with English-language dollar amount
        transcription = "blah one hundred twenty three dollars and forty five cents blah"
        reply_for_user = subject.transcribe_balance_response(transcription)
        expect(reply_for_user).to eq("Hi! Your food and nutrition benefits balance is $123.45.")
      end
    end

    context 'with EBT card not found in system' do
      it 'sends EBT-not-found message' do
        reply_for_user = subject.transcribe_balance_response(transcription_ebt_not_found)
        expect(reply_for_user).to eq("I'm sorry, that card number was not found. Please try again.")
      end
    end

    context 'with a failed (nil) transcription' do
      it 'sends EBT-not-found message' do
        reply_for_user = subject.transcribe_balance_response(failed_transcription)
        expect(reply_for_user).to eq(MessageGenerator.new.having_trouble_try_again_message)
      end
    end
  end
end

describe StateHandler::OK do
  describe 'balance transcription processing' do

    # DUMMY — not taken from real logs
    let(:successful_transcription_1) { "blah $123.45 blah" }

    # DUMMY — not taken from real logs
    let(:transcription_ebt_not_found) { "blah please try again blah" }

    let(:failed_transcription) { nil }

    context 'for English' do
      context 'with transcription containing balance' do
        it 'sends response with balance amounts' do
          reply_for_user = subject.transcribe_balance_response(successful_transcription_1)
          expect(reply_for_user).to eq("Hi! Your food stamp balance is $123.45.")
        end
      end

      context 'with an English-language amount' do
        it 'processes it as a dollar amount successfully' do
          # Not taken from logs; just modified above example with English-language dollar amount
          transcription = "blah one hundred twenty three dollars and forty five cents blah"
          reply_for_user = subject.transcribe_balance_response(transcription)
          expect(reply_for_user).to eq("Hi! Your food stamp balance is $123.45.")
        end
      end

      context 'with EBT card not found in system' do
        it 'sends EBT-not-found message' do
          reply_for_user = subject.transcribe_balance_response(transcription_ebt_not_found)
          expect(reply_for_user).to eq("I'm sorry, that card number was not found. Please try again.")
        end
      end

      context 'with a failed (nil) transcription' do
        it 'sends EBT-not-found message' do
          reply_for_user = subject.transcribe_balance_response(failed_transcription)
          expect(reply_for_user).to eq(MessageGenerator.new.having_trouble_try_again_message)
        end
      end
    end

    context 'for Spanish' do
      let(:language) { :spanish }

      context 'with transcription containing balance variation 1' do
        it 'sends response with balance amounts' do
          reply_for_user = subject.transcribe_balance_response(successful_transcription_1, language)
          expect(reply_for_user).to eq("Hola! El saldo de su cuenta de estampillas para comida es $123.45.")
        end
      end

      context 'with EBT card not found in system' do
        it 'sends EBT-not-found message' do
          reply_for_user = subject.transcribe_balance_response(transcription_ebt_not_found, language)
          expect(reply_for_user).to eq("Lo siento, no se encontró el número de tarjeta. Por favor, inténtelo de nuevo.")
        end
      end

      context 'with a failed (nil) transcription' do
        it 'sends EBT-not-found message' do
          reply_for_user = subject.transcribe_balance_response(failed_transcription, language)
          expect(reply_for_user).to eq("Lo siento! Actualmente estamos teniendo problemas comunicándonos con el sistema de EBT. Favor de enviar su # de EBT por texto en unos minutos.")
        end
      end
    end
  end
end

describe StateHandler::PA do
  describe 'balance transcription' do
    let(:successful_transcription_with_extraneous_period) { "Your snap balance is $716. Your cash balance is $294.68. to repeat your account balance press 1 To hear your last 10 transactions on your card. Press." }

    # DUMMY — not taken from real logs
    let(:successful_transcription_1) { "blah $136.33 blah $23.87 blah" }

    # DUMMY — not taken from real logs
    let(:transcription_ebt_not_found_1) { "blah Invalid Card Number blah" }
    let(:transcription_ebt_not_found_2) { "blah invalid card number blah" }

    context 'for English' do
      let(:language) { :english }

      context 'with transcription containing balance' do
        it 'sends response with balance amounts' do
          reply_for_user = subject.transcribe_balance_response(successful_transcription_1)
          expect(reply_for_user).to eq("Hi! Your food stamp balance is $136.33 and your cash balance is $23.87.")
        end
      end

      context 'with an English-language amount' do
        it 'processes it as a dollar amount successfully' do
          # Not taken directly from logs; modified the above with a transcription of English language numbers from logs
          transcription = "Your snap balance is ten dollars and twenty two cents. Your cash balance is one dollar. To repeat your account balance press 1 To hear your last 10 transactions on your card. Press."
          reply_for_user = subject.transcribe_balance_response(transcription)
          expect(reply_for_user).to eq("Hi! Your food stamp balance is $10.22 and your cash balance is $1.00.")
        end
      end

      context 'with transcription with balance and extraneous periods' do
        it 'transcribes without extraneous periods in amounts' do
          reply_for_user = subject.transcribe_balance_response(successful_transcription_with_extraneous_period)
          expect(reply_for_user).to eq("Hi! Your food stamp balance is $716 and your cash balance is $294.68.")
        end
      end

      context 'with EBT card not found in system (variation 1 - capitalized)' do
        it 'sends EBT-not-found message' do
          reply_for_user = subject.transcribe_balance_response(transcription_ebt_not_found_1)
          expect(reply_for_user).to eq("I'm sorry, that card number was not found. Please try again.")
        end
      end

      context 'with EBT card not found in system (variation 2 - not capitalized)' do
        it 'sends EBT-not-found message' do
          reply_for_user = subject.transcribe_balance_response(transcription_ebt_not_found_2)
          expect(reply_for_user).to eq("I'm sorry, that card number was not found. Please try again.")
        end
      end

      context 'with a failed (nil) transcription' do
        let(:failed_transcription) { nil }

        it 'sends EBT-not-found message' do
          reply_for_user = subject.transcribe_balance_response(failed_transcription)
          expect(reply_for_user).to eq(MessageGenerator.new.having_trouble_try_again_message)
        end
      end
    end

    context 'for Spanish' do
      let(:language) { :spanish }

      context 'with transcription containing balance' do
        it 'sends response with balance amounts' do
          reply_for_user = subject.transcribe_balance_response(successful_transcription_1, language)
          expect(reply_for_user).to eq("Hola! El saldo de su cuenta de estampillas para comida es $136.33 y su balance de dinero en efectivo es $23.87.")
        end
      end

      context 'with EBT card not found in system' do
        it 'sends EBT-not-found message' do
          reply_for_user = subject.transcribe_balance_response(transcription_ebt_not_found_1, language)
          expect(reply_for_user).to eq("Lo siento, no se encontró el número de tarjeta. Por favor, inténtelo de nuevo.")
        end
      end

      context 'with a failed (nil) transcription' do
        let(:failed_transcription) { nil }

        it 'sends EBT-not-found message' do
          reply_for_user = subject.transcribe_balance_response(failed_transcription, language)
          expect(reply_for_user).to eq("Lo siento! Actualmente estamos teniendo problemas comunicándonos con el sistema de EBT. Favor de enviar su # de EBT por texto en unos minutos.")
        end
      end
    end
  end
end

describe StateHandler::TX do
  it 'serves the correct phone number' do
    expect(subject.phone_number).to eq('+18007777328')
  end

  it 'gives correct button sequence' do
    fake_ebt_number = '11112222'
    desired_sequence = subject.button_sequence(fake_ebt_number)
    expect(desired_sequence).to eq("wwww1wwwwww#{fake_ebt_number}wwww")
  end

  it 'tells the number of digits a CA EBT card has' do
    expect(subject.allowed_number_of_ebt_card_digits).to eq([19])
  end

  describe 'EBT number extraction' do
    it 'extracts a valid EBT number for that state from plain text' do
      ebt_number = '1111222233334444555'
      inbound_text = "my ebt is #{ebt_number}"
      extracted_number = subject.extract_valid_ebt_number_from_text(inbound_text)
      expect(extracted_number).to eq(ebt_number)
    end

    it 'returns :invalid_number if not a valid number' do
      inbound_text = 'my ebt is 123'
      extracted_number = subject.extract_valid_ebt_number_from_text(inbound_text)
      expect(extracted_number).to eq(:invalid_number)
    end
  end

  describe 'balance transcription processing' do
    let(:successful_transcription_1) { "(Who?) the account balance for the card number entered is $154.70 to end this call press 1 to repeat your account balance press 2 to report a lost or still in card press 3 if you would like to select a new pen for your account." }
    let(:successful_transcription_too_many_digits_in_balance) { "For the card number entered is $600802.17 to end this call press 1 to repeat your account balance press 2 to report a lost or (still?) in card press 3 if you would like to select a new pen for you Rick." }
    let(:transcription_ebt_not_found) { "Hey, Dan Invalid Card Number please enter the 16 numbers on the first line of the card and the last 3 numbers in the lower left hand corner on the second line of the card if your card has been lost or stolen and you do not have your card number please hold to disable your card please enter (then?)." }
    let(:failed_transcription) { nil }

    context 'for English' do
      context 'with an English-language amount' do
        it 'processes it as a dollar amount successfully' do
          # Not taken from logs; modified the above with English language numbers
          transcription = "(Who?) the account balance for the card number entered is one hundred fifty four dollars and seventy cents. To end this call press one to repeat your account balance press two to report a lost or still in card press three if you would like to select a new pen for your account."
          reply_for_user = subject.transcribe_balance_response(transcription)
          expect(reply_for_user).to eq("Hi! Your food stamp balance is $154.70.")
        end
      end

      context 'with transcription containing balance variation 1' do
        it 'sends response with balance amounts' do
          reply_for_user = subject.transcribe_balance_response(successful_transcription_1)
          expect(reply_for_user).to eq("Hi! Your food stamp balance is $154.70.")
        end
      end

      context 'with transcription with huge dollar amount' do
        it 'sends response with balance amounts' do
          reply_for_user = subject.transcribe_balance_response(successful_transcription_too_many_digits_in_balance)
          expect(reply_for_user).to eq("Hi! Your food stamp balance is $682.17.")
        end
      end

      context 'with EBT card not found in system' do
        it 'sends EBT-not-found message' do
          reply_for_user = subject.transcribe_balance_response(transcription_ebt_not_found)
          expect(reply_for_user).to eq("I'm sorry, that card number was not found. Please try again.")
        end
      end

      context 'with a failed (nil) transcription' do
        it 'sends EBT-not-found message' do
          reply_for_user = subject.transcribe_balance_response(failed_transcription)
          expect(reply_for_user).to eq(MessageGenerator.new.having_trouble_try_again_message)
        end
      end
    end

    context 'for Spanish' do
      let(:language) { :spanish }

      context 'with transcription containing balance variation 1' do
        it 'sends response with balance amounts' do
          reply_for_user = subject.transcribe_balance_response(successful_transcription_1, language)
          expect(reply_for_user).to eq("Hola! El saldo de su cuenta de estampillas para comida es $154.70.")
        end
      end

      context 'with EBT card not found in system' do
        it 'sends EBT-not-found message' do
          reply_for_user = subject.transcribe_balance_response(transcription_ebt_not_found, language)
          expect(reply_for_user).to eq("Lo siento, no se encontró el número de tarjeta. Por favor, inténtelo de nuevo.")
        end
      end

      context 'with a failed (nil) transcription' do
        it 'sends EBT-not-found message' do
          reply_for_user = subject.transcribe_balance_response(failed_transcription, language)
          expect(reply_for_user).to eq("Lo siento! Actualmente estamos teniendo problemas comunicándonos con el sistema de EBT. Favor de enviar su # de EBT por texto en unos minutos.")
        end
      end
    end
  end
end

describe StateHandler::VA do
  describe 'balance transcription' do
    let(:transcription_with_trailing_period) { "Your snap balance is $221.90. As a reminder by saving to (receive?) from your last purchase you'll know your current balance. You can also access your balance online at www.EBT dot a C at." }

    # DUMMY — not taken from real logs
    let(:successful_transcription_1) { "blah $136.33 blah $23.87 blah" }

    # DUMMY — not taken from real logs
    let(:transcription_ebt_not_found_1) { "blah Invalid Card Number blah" }
    let(:transcription_ebt_not_found_2) { "blah invalid card number blah" }

    context 'for English' do
      let(:language) { :english }

      context 'with an English-language amount' do
        it 'processes it as a dollar amount successfully' do
          # Not taken from logs; modified the above with English language numbers
          transcription = "Your snap balance is two hundred twenty one dollars and ninety cents. As a reminder by saving to (receive?) from your last purchase you'll know your current balance. You can also access your balance online at www.EBT dot a C at."
          reply_for_user = subject.transcribe_balance_response(transcription)
          expect(reply_for_user).to eq("Hi! Your food stamp balance is $221.90.")
        end
      end

      context 'with transcription containing balance' do
        it 'sends response with balance amounts' do
          reply_for_user = subject.transcribe_balance_response(successful_transcription_1)
          expect(reply_for_user).to eq("Hi! Your food stamp balance is $136.33.")
        end
      end

      context 'with transcription with trailing period in amount' do
        it 'sends response with balance without trailing period' do
          reply_for_user = subject.transcribe_balance_response(transcription_with_trailing_period)
          expect(reply_for_user).to eq("Hi! Your food stamp balance is $221.90.")
        end
      end

      context 'with EBT card not found in system (variation 1 - capitalized)' do
        it 'sends EBT-not-found message' do
          reply_for_user = subject.transcribe_balance_response(transcription_ebt_not_found_1)
          expect(reply_for_user).to eq("I'm sorry, that card number was not found. Please try again.")
        end
      end

      context 'with EBT card not found in system (variation 2 - not capitalized)' do
        it 'sends EBT-not-found message' do
          reply_for_user = subject.transcribe_balance_response(transcription_ebt_not_found_2)
          expect(reply_for_user).to eq("I'm sorry, that card number was not found. Please try again.")
        end
      end

      context 'with a failed (nil) transcription' do
        let(:failed_transcription) { nil }

        it 'sends EBT-not-found message' do
          reply_for_user = subject.transcribe_balance_response(failed_transcription)
          expect(reply_for_user).to eq(MessageGenerator.new.having_trouble_try_again_message)
        end
      end
    end

    context 'for Spanish' do
      let(:language) { :spanish }

      context 'with transcription containing balance' do
        it 'sends response with balance amounts' do
          reply_for_user = subject.transcribe_balance_response(successful_transcription_1, language)
          expect(reply_for_user).to eq("Hola! El saldo de su cuenta de estampillas para comida es $136.33.")
        end
      end

      context 'with EBT card not found in system' do
        it 'sends EBT-not-found message' do
          reply_for_user = subject.transcribe_balance_response(transcription_ebt_not_found_1, language)
          expect(reply_for_user).to eq("Lo siento, no se encontró el número de tarjeta. Por favor, inténtelo de nuevo.")
        end
      end

      context 'with a failed (nil) transcription' do
        let(:failed_transcription) { nil }

        it 'sends EBT-not-found message' do
          reply_for_user = subject.transcribe_balance_response(failed_transcription, language)
          expect(reply_for_user).to eq("Lo siento! Actualmente estamos teniendo problemas comunicándonos con el sistema de EBT. Favor de enviar su # de EBT por texto en unos minutos.")
        end
      end
    end
  end
end

describe StateHandler::UnhandledState do
  let(:subject) { StateHandler::UnhandledState.new }

  it 'uses CA handler methods' do
    expect(subject.phone_number).to eq(StateHandler::CA.new.phone_number)
    expect(subject.button_sequence('123')).to eq(StateHandler::CA.new.button_sequence('123'))
  end
end
