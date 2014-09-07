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
        desired_message = "Thanks! Please wait 1-2 minutes while we check your EBT balance."
        expect(mg.thanks_please_wait).to eq(desired_message)
      end
    end

    describe '#sorry_try_again' do
      it "says 'sorry, try again...'" do
        desired_message = "Sorry, that EBT number doesn't look right. Please try again."
        expect(mg.sorry_try_again).to eq(desired_message)
      end
    end

    describe '#inbound_voice_call_text_message' do
      it "says 'hi! you can check your balance here...'" do
        desired_message = 'Hi there! You can check your EBT card balance by text message here. Just reply to this message with your EBT card number.'
        expect(mg.inbound_voice_call_text_message).to eq(desired_message)
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

    describe '#sorry_try_again' do
      it "says Spanish version of 'sorry, try again...'" do
        desired_message = "Perdon, ese número de EBT no esta trabajando. Favor de intentarlo otra vez."
        expect(mg.sorry_try_again).to eq(desired_message)
      end
    end

    describe '#inbound_voice_call_text_message' do
      it "says Spanish version of 'hi! you can check your balance here...'" do
        desired_message = 'Hola! Usted puede verificar su saldo de EBT por mensaje de texto. Solo responda a este mensaje con su número de tarjeta de EBT.'
        expect(mg.inbound_voice_call_text_message).to eq(desired_message)
      end
    end
  end
end
