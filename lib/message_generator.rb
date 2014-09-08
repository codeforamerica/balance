class MessageGenerator
  attr_reader :language

  def initialize(language = :english)
    @language = language
  end

  def thanks_please_wait
    if language == :spanish
      "Gracias! Favor de esperar 1-2 minutos mientras verificamos su saldo de EBT."
    else
      "Thanks! Please wait 1-2 minutes while we check your EBT balance."
    end
  end

  def sorry_try_again
    if language == :spanish
      "Perdon, ese número de EBT no esta trabajando. Favor de intentarlo otra vez."
    else
      "Sorry, that EBT number doesn't look right. Please try again."
    end
  end

  def inbound_voice_call_text_message
    if language == :spanish
      'Hola! Usted puede verificar su saldo de EBT por mensaje de texto. Solo responda a este mensaje con su número de tarjeta de EBT.'
    else
      'Hi there! You can check your EBT card balance by text message here. Just reply to this message with your EBT card number.'
    end
  end

  def welcome
    if language == :spanish
      'Hola! Usted puede verificar su saldo de EBT por mensaje de texto. Solo responda a este mensaje con su número de tarjeta de EBT.'
    else
      "Hi there! Reply to this message with your EBT card number and I'll check your balance for you."
    end
  end
end
