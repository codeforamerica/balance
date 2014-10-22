class MessageGenerator
  attr_reader :language

  def initialize(language = :english)
    @language = language
  end

  def thanks_please_wait
    if language == :spanish
      "Gracias! Favor de esperar 1-2 minutos mientras verificamos su saldo de EBT."
    else
      "Thanks! Please wait 1-2 minutes while we check your EBT balance. Want to help us make this better? Send a text to (415) 877-4154 and answer 3 quick questions."
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
      'Hola! Para obtener su saldo, responda a este mensaje con el numero de su tarjeta EBT.'
    else
      'Hi! Please reply with your EBT card number to get your balance.'
    end
  end

  def welcome
    if language == :spanish
      'Hola! Usted puede verificar su saldo de EBT por mensaje de texto. Solo responda a este mensaje con su número de tarjeta de EBT.'
    else
      "Hi there! Reply to this message with your EBT card number and I'll check your balance for you."
    end
  end

  def having_trouble_try_again_message
    if language == :spanish
      "Lo siento! Actualmente estamos teniendo problemas comunicándonos con el sistema de EBT. Favor de enviar su # de EBT por texto en unos minutos."
    else
      "I'm really sorry! We're having trouble contacting the EBT system right now. Please text your EBT # again in a few minutes."
    end
  end

  def card_number_not_found_message
    if language == :spanish
      "Lo siento, no se encontró el número de tarjeta. Por favor, inténtelo de nuevo."
    else
      "I'm sorry, that card number was not found. Please try again."
    end
  end

  def call_in_voice_file_url
    if language == :spanish
      'https://s3-us-west-1.amazonaws.com/balance-cfa/balance-voice-splash-spanish-v1-091214.mp3'
    else
      'https://s3-us-west-1.amazonaws.com/balance-cfa/balance-voice-splash-v3-091214.mp3'
    end
  end
end
