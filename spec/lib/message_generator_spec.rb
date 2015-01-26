require 'spec_helper'
require File.expand_path('../../../lib/message_generator', __FILE__)

describe MessageGenerator do
  it 'initializes with English by default' do
    mg = MessageGenerator.new
    expect(mg.language).to eq(:english)
  end

  context 'for English' do
    let(:mg) { MessageGenerator.new }

    describe '#thanks_please_wait' do
      it "says 'thanks please wait...'" do
        desired_message = "Thanks! Please wait 1-2 minutes while we check your balance."
        expect(mg.thanks_please_wait).to eq(desired_message)
      end
    end

    describe '#balance_message' do
      context 'with single argument' do
        it 'reports just the food stamp balance' do
          balance_message = mg.balance_message("$123.45")
          expect(balance_message).to eq("Hi! Your food stamp balance is $123.45.")
        end
      end

      context 'with a cash balance in second argument' do
        it 'reports both food stamp and cash balances' do
          balance_message = mg.balance_message("$123.45", cash: "$42.11")
          desired_message = "Hi! Your food stamp balance is $123.45 and your cash balance is $42.11."
          expect(balance_message).to eq(desired_message)
        end
      end
    end

    describe '#sorry_try_again' do
      context 'with a single digit length for that state' do
        it "says 'sorry, try again...'" do
          digit_lengths = [16]
          desired_message = "Sorry! That number doesn't look right. Please reply with your 16-digit EBT card number."
          response = mg.sorry_try_again(digit_lengths)
          expect(response).to eq(desired_message)
        end
      end

      context 'with multiple possible digit lengths in the state' do
        it "says 'sorry...' with multiple digits" do
          digit_lengths = [16, 19]
          desired_message = "Sorry! That number doesn't look right. Please reply with your 16- or 19-digit EBT card number."
          response = mg.sorry_try_again([16, 19])
          expect(response).to eq(desired_message)
        end
      end

      context 'with no argument passed in' do
        it "says 'sorry, try again...'" do
          desired_message = "Sorry! That number doesn't look right. Please reply with your EBT card number."
          response = mg.sorry_try_again
          expect(response).to eq(desired_message)
        end
      end

      context 'with nil passed in' do
        it "says 'sorry, try again...'" do
          desired_message = "Sorry! That number doesn't look right. Please reply with your EBT card number."
          response = mg.sorry_try_again(nil)
          expect(response).to eq(desired_message)
        end
      end
    end

    describe '#call_in_voice_file_url' do
      it "gives the English s3 file URL" do
        url = 'https://s3-us-west-1.amazonaws.com/balance-cfa/balance-voice-splash-v4-012515.mp3'
        expect(mg.call_in_voice_file_url).to eq(url)
      end
    end
  end

  context 'for Spanish' do
    let(:mg) { MessageGenerator.new(:spanish) }

    describe '#thanks_please_wait' do
      it "says Spanish version of 'thanks please wait...'" do
        desired_message = "Gracias! Favor de esperar 1-2 minutos mientras verificamos su saldo de EBT."
        expect(mg.thanks_please_wait).to eq(desired_message)
      end
    end

    describe '#balance_message' do
      context 'with single argument' do
        it 'reports just the food stamp balance in Spanish' do
          balance_message = mg.balance_message("$123.45")
          expect(balance_message).to eq("Hola! El saldo de su cuenta de estampillas para comida es $123.45.")
        end
      end

      context 'with a cash balance in second argument' do
        it 'reports both food stamp and cash balances in Spanish' do
          balance_message = mg.balance_message("$123.45", cash: "$42.11")
          desired_message = "Hola! El saldo de su cuenta de estampillas para comida es $123.45 y su balance de dinero en efectivo es $42.11."
          expect(balance_message).to eq(desired_message)
        end
      end
    end

    describe '#sorry_try_again' do
      it "says Spanish version of 'sorry, try again...'" do
        desired_message = "Perdon, ese número de EBT no esta trabajando. Favor de intentarlo otra vez."
        expect(mg.sorry_try_again).to eq(desired_message)
      end
    end

    describe '#call_in_voice_file_url' do
      it "gives the Spanish s3 file URL" do
        url = 'https://s3-us-west-1.amazonaws.com/balance-cfa/balance-voice-splash-spanish-v2-012515.mp3'
        expect(mg.call_in_voice_file_url).to eq(url)
      end
    end
  end
end
