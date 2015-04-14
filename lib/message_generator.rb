class MessageGenerator
  attr_reader :language

  def initialize(language = :english)
    @language = language
  end

  def thanks_please_wait
    if language == :spanish
      "Gracias! Favor de esperar 1-2 minutos mientras verificamos su saldo de EBT."
    else
      "Thanks! Please wait 1-2 minutes while we check your balance."
    end
  end

  def balance_message(food_stamp_balance, optional_balances = {})
    if language == :spanish
      if optional_balances[:cash]
        balance_message = "Hola! El saldo de su cuenta de estampillas para comida es #{food_stamp_balance} y su balance de dinero en efectivo es #{optional_balances[:cash]}."
      else
        balance_message = "Hola! El saldo de su cuenta de estampillas para comida es #{food_stamp_balance}."
      end
    else
      if optional_balances[:cash]
        balance_message = "Hi! Your food stamp balance is #{food_stamp_balance} and your cash balance is #{optional_balances[:cash]}."
      else
        balance_message = "Hi! Your food stamp balance is #{food_stamp_balance}."
      end
    end
    balance_message
  end

  def sorry_try_again(digits_array = [])
    if language == :spanish
      "Perdon, ese número de EBT no esta trabajando. Favor de intentarlo otra vez."
    else
      if digits_array == nil
        "Sorry! That number doesn't look right. Please reply with your EBT card number."
      elsif digits_array.length == 1
        "Sorry! That number doesn't look right. Please reply with your #{digits_array[0]}-digit EBT card number."
      elsif digits_array.length == 2
        "Sorry! That number doesn't look right. Please reply with your #{digits_array[0]}- or #{digits_array[1]}-digit EBT card number."
      else
        "Sorry! That number doesn't look right. Please reply with your EBT card number."
      end
    end
  end

  def welcome
    if language == :spanish
      'Hola! Usted puede verificar su saldo de EBT por mensaje de texto. Solo responda a este mensaje con su número de tarjeta de EBT.'
    else
      "Hi there! Reply to this message with your EBT card number and we'll check your balance for you. For more info, text ABOUT."
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
      'https://s3-us-west-1.amazonaws.com/balance-cfa/balance-voice-splash-spanish-v2-012515.mp3'
    else
      'https://s3-us-west-1.amazonaws.com/balance-cfa/balance-voice-splash-v4-012515.mp3'
    end
  end

  def more_info
    "This is a free text service provided by non-profit Code for America for checking your EBT balance (standard rates apply). For more info go to www.c4a.me/balance"
  end
end
