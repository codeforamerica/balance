require 'spec_helper'
require File.expand_path('../../../lib/state_handler', __FILE__)

describe StateHandler do
  describe '::for' do
    context 'given a state with an existing handler' do
      it "returns the state's handler module" do
        handler = StateHandler.for('CA')
        expect(handler).to eq(StateHandler::CA)
      end
    end
    context 'given a state WITHOUT an existing handler' do
      it "returns Nil handler" do
        handler = StateHandler.for('PR')
        expect(handler).to eq(StateHandler::UnhandledState)
      end
    end
  end
end

describe StateHandler::CA do
  it 'serves the correct phone number' do
    expect(subject.phone_number).to eq('+18773289677')
  end

  it 'gives correct button sequence' do
    fake_ebt_number = '11112222'
    desired_sequence = subject.button_sequence(fake_ebt_number)
    expect(desired_sequence).to eq("wwww1wwwwww#{fake_ebt_number}ww")
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
  end

  describe 'balance transcriber' do
      let(:successful_transcription_1) { "Your food stamp balance is $136.33 your cash account balance is $0 as a reminder by saving the receipt from your last purchase and your last a cash purchase for Cash Bank Transaction you will always have your current balance at and will also print your balance on the Cash Withdrawal receipt to hear the number of Cash Withdrawal for that a transaction fee (running?) this month press 1 to hear your last 10 transactions report a transaction there file a claim or check the status of a claim press 2 to report your card lost stolen or damaged press 3 for (pin?) replacement press 4 for additional options press 5" }
    let(:successful_transcription_2) { "(Stamp?) balance is $123.11 your cash account balance is $11.32 as a reminder by saving the receipt from your last purchase and your last a cash purchase or cash back transaction you will always have your current balance at and will also print the balance on the Cash Withdrawal receipt to hear the number of Cash Withdrawal for that a transaction fee this month press 1 to hear your last 10 transactions report a transaction there file a claim or check the status of a claim press 2 to report your card lost stolen or damaged press 3 for (pin?) replacement press 4 for additional options press 5" }
      let(:successful_transcription_3) { "Devon Alan is $156.89 your cash account balance is $4.23 as a reminder by saving the receipt from your last purchase and your last the cash purchase or cash back for (action?) you will always have your current balance. I'm at and will also print the balance on the Cash Withdrawal receipt to hear the number of Cash Withdrawal for that a transaction fee (running?) this month press 1 to hear your last 10 transactions report a transaction there file a claim or check the status of a claim press 2 to report your card lost stolen or damaged press 3 for pain placement press 4 for additional options press 5" }
      let(:transcription_ebt_not_found) { "Our records indicate the number you have entered it's for an non working card in case your number was entered incorrectly please reenter your 16 digit card number followed by the pound sign." }


    context 'for English' do
      let(:transcriber) { subject.transcriber_for(:english) }

      it 'sets the language to :english' do
        expect(transcriber.language).to eq(:english)
      end

      context 'with transcription containing balance variation 1' do
        it 'sends response with balance amounts' do
          reply_for_user = transcriber.transcribe_balance_response(successful_transcription_1)
          expect(reply_for_user).to eq("Hi! Your food stamp balance is $136.33 and your cash balance is $0.")
        end
      end

      context 'with transcription containing balance variation 2' do
        it 'sends response with balance amounts' do
          reply_for_user = transcriber.transcribe_balance_response(successful_transcription_2)
          expect(reply_for_user).to eq("Hi! Your food stamp balance is $123.11 and your cash balance is $11.32.")
        end
      end

      context 'with transcription containing balance variation 3' do
        it 'sends response with balance amounts' do
          reply_for_user = transcriber.transcribe_balance_response(successful_transcription_3)
          expect(reply_for_user).to eq("Hi! Your food stamp balance is $156.89 and your cash balance is $4.23.")
        end
      end

      context 'with EBT card not found in system' do
        it 'sends EBT-not-found message' do
          reply_for_user = transcriber.transcribe_balance_response(transcription_ebt_not_found)
          expect(reply_for_user).to eq("I'm sorry, that card number was not found. Please try again. (Note: this service only works in California right now.)")
        end
      end

      context 'with a failed (nil) transcription' do
        let(:failed_transcription) { nil }

        it 'sends EBT-not-found message' do
          reply_for_user = transcriber.transcribe_balance_response(failed_transcription)
          expect(reply_for_user).to eq("I'm really sorry! We're having trouble contacting the EBT system right now. Please text your EBT # again in a few minutes.")
        end
      end
    end

    context 'for Spanish' do
      let(:transcriber) { subject.transcriber_for(:spanish) }

      it 'sets the language to :spanish' do
        expect(transcriber.language).to eq(:spanish)
      end

      context 'with transcription containing balance variation 1' do
        it 'sends response with balance amounts' do
          reply_for_user = transcriber.transcribe_balance_response(successful_transcription_1)
          expect(reply_for_user).to eq("Hola! El saldo de su cuenta de estampillas para comida es $136.33 y su balance de dinero en efectivo es $0.")
        end
      end

      context 'with transcription containing balance variation 2' do
        it 'sends response with balance amounts' do
          reply_for_user = transcriber.transcribe_balance_response(successful_transcription_2)
          expect(reply_for_user).to eq("Hola! El saldo de su cuenta de estampillas para comida es $123.11 y su balance de dinero en efectivo es $11.32.")
        end
      end

      context 'with transcription containing balance variation 3' do
        it 'sends response with balance amounts' do
          reply_for_user = transcriber.transcribe_balance_response(successful_transcription_3)
          expect(reply_for_user).to eq("Hola! El saldo de su cuenta de estampillas para comida es $156.89 y su balance de dinero en efectivo es $4.23.")
        end
      end

      context 'with EBT card not found in system' do
        it 'sends EBT-not-found message' do
          reply_for_user = transcriber.transcribe_balance_response(transcription_ebt_not_found)
          expect(reply_for_user).to eq("Lo siento, no se encontró el número de tarjeta. Por favor, inténtelo de nuevo. (Nota: este servicio sólo funciona en California en este momento.)")
        end
      end

      context 'with a failed (nil) transcription' do
        let(:failed_transcription) { nil }

        it 'sends EBT-not-found message' do
          reply_for_user = transcriber.transcribe_balance_response(failed_transcription)
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
      let(:transcriber) { subject.transcriber_for(:english) }

      it 'sets the language to :english' do
        expect(transcriber.language).to eq(:english)
      end

      context 'with transcription containing balance variation 1' do
        it 'sends response with balance amounts' do
          reply_for_user = transcriber.transcribe_balance_response(successful_transcription_1)
          expect(reply_for_user).to eq("Hi! Your food stamp balance is $154.70.")
        end
      end

      context 'with EBT card not found in system' do
        it 'sends EBT-not-found message' do
          reply_for_user = transcriber.transcribe_balance_response(transcription_ebt_not_found)
          expect(reply_for_user).to eq("I'm sorry, that card number was not found. Please try again.")
        end
      end

      context 'with a failed (nil) transcription' do
        it 'sends EBT-not-found message' do
          reply_for_user = transcriber.transcribe_balance_response(failed_transcription)
          expect(reply_for_user).to eq("I'm really sorry! We're having trouble contacting the EBT system right now. Please text your EBT # again in a few minutes.")
        end
      end
    end

    context 'for Spanish' do
      let(:transcriber) { subject.transcriber_for(:spanish) }

      it 'sets the language to :spanish' do
        expect(transcriber.language).to eq(:spanish)
      end

      context 'with transcription containing balance variation 1' do
        it 'sends response with balance amounts' do
          reply_for_user = transcriber.transcribe_balance_response(successful_transcription_1)
          expect(reply_for_user).to eq("Hola! El saldo de su cuenta de estampillas para comida es $154.70.")
        end
      end

      context 'with EBT card not found in system' do
        it 'sends EBT-not-found message' do
          reply_for_user = transcriber.transcribe_balance_response(transcription_ebt_not_found)
          expect(reply_for_user).to eq("Lo siento, no se encontró el número de tarjeta. Por favor, inténtelo de nuevo.")
        end
      end

      context 'with a failed (nil) transcription' do
        it 'sends EBT-not-found message' do
          reply_for_user = transcriber.transcribe_balance_response(failed_transcription)
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
    expect(desired_sequence).to eq("wwww1wwwwww#{fake_ebt_number}ww")
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
    let(:transcription_ebt_not_found) { "Hey, Dan Invalid Card Number please enter the 16 numbers on the first line of the card and the last 3 numbers in the lower left hand corner on the second line of the card if your card has been lost or stolen and you do not have your card number please hold to disable your card please enter (then?)." }
    let(:failed_transcription) { nil }

    context 'for English' do
      let(:transcriber) { subject.transcriber_for(:english) }

      it 'sets the language to :english' do
        expect(transcriber.language).to eq(:english)
      end

      context 'with transcription containing balance variation 1' do
        it 'sends response with balance amounts' do
          reply_for_user = transcriber.transcribe_balance_response(successful_transcription_1)
          expect(reply_for_user).to eq("Hi! Your food stamp balance is $154.70.")
        end
      end

      context 'with EBT card not found in system' do
        it 'sends EBT-not-found message' do
          reply_for_user = transcriber.transcribe_balance_response(transcription_ebt_not_found)
          expect(reply_for_user).to eq("I'm sorry, that card number was not found. Please try again.")
        end
      end

      context 'with a failed (nil) transcription' do
        it 'sends EBT-not-found message' do
          reply_for_user = transcriber.transcribe_balance_response(failed_transcription)
          expect(reply_for_user).to eq("I'm really sorry! We're having trouble contacting the EBT system right now. Please text your EBT # again in a few minutes.")
        end
      end
    end

    context 'for Spanish' do
      let(:transcriber) { subject.transcriber_for(:spanish) }

      it 'sets the language to :spanish' do
        expect(transcriber.language).to eq(:spanish)
      end

      context 'with transcription containing balance variation 1' do
        it 'sends response with balance amounts' do
          reply_for_user = transcriber.transcribe_balance_response(successful_transcription_1)
          expect(reply_for_user).to eq("Hola! El saldo de su cuenta de estampillas para comida es $154.70.")
        end
      end

      context 'with EBT card not found in system' do
        it 'sends EBT-not-found message' do
          reply_for_user = transcriber.transcribe_balance_response(transcription_ebt_not_found)
          expect(reply_for_user).to eq("Lo siento, no se encontró el número de tarjeta. Por favor, inténtelo de nuevo.")
        end
      end

      context 'with a failed (nil) transcription' do
        it 'sends EBT-not-found message' do
          reply_for_user = transcriber.transcribe_balance_response(failed_transcription)
          expect(reply_for_user).to eq("Lo siento! Actualmente estamos teniendo problemas comunicándonos con el sistema de EBT. Favor de enviar su # de EBT por texto en unos minutos.")
        end
      end
    end
  end
end

describe StateHandler::UnhandledState do
  it 'uses CA handler methods' do
    expect(subject.phone_number).to eq(StateHandler::CA.phone_number)
    expect(subject.button_sequence('123')).to eq(StateHandler::CA.button_sequence('123'))
  end
end
