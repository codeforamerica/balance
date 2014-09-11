module StateHandler
  extend self

  def for(state_abbreviation)
    if handled_states.include?(state_abbreviation.to_sym)
      eval("StateHandler::#{state_abbreviation}.new")
    else
      StateHandler::UnhandledState.new #StateHandler::CA by default, likely
    end
  end

  def handled_states
    constants
  end
end

class StateHandler::Base
  def phone_number
    self.class.const_get(:PHONE_NUMBER)
  end

  def allowed_number_of_ebt_card_digits
    self.class.const_get(:ALLOWED_NUMBER_OF_EBT_CARD_DIGITS)
  end

  def extract_valid_ebt_number_from_text(text)
    whitespace_free_text = text.gsub(" ", "")
    dash_and_whitespace_free_text = whitespace_free_text.gsub("-", "")
    number_matches = dash_and_whitespace_free_text.match(/\d+/)
    number = number_matches.to_s
    if allowed_number_of_ebt_card_digits.include?(number.length) && number.match(/\D+/) == nil
      return number
    else
      return :invalid_number
    end
  end
end

class StateHandler::CA < StateHandler::Base
  PHONE_NUMBER = '+18773289677'
  ALLOWED_NUMBER_OF_EBT_CARD_DIGITS = [16]

  def button_sequence(ebt_number)
    "wwww1wwwwww#{ebt_number}ww"
  end

  def transcribe_balance_response(transcription_text, language = :english)
    BalanceTranscriber.new(language).transcribe_balance_response(transcription_text)
  end

  class BalanceTranscriber
    attr_reader :language

    def initialize(language)
      @language = language
      if @language == :spanish
        extend SpanishTranscriptionMessages
      else
        extend EnglishTranscriptionMessages
      end
    end

    def transcribe_balance_response(transcription_text)
      if transcription_text == nil
        return having_trouble_try_again_message
      end
      regex_matches = transcription_text.scan(/(\$\S+)/)
      if transcription_text.include?("non working card")
        card_number_not_found_message
      elsif regex_matches.count > 1
        ebt_amount = regex_matches[0][0]
        cash_amount = regex_matches[1][0]
        balance_message_for(ebt_amount, cash_amount)
      else
        having_trouble_try_again_message
      end
    end

    module EnglishTranscriptionMessages
      def having_trouble_try_again_message
        "I'm really sorry! We're having trouble contacting the EBT system right now. Please text your EBT # again in a few minutes."
      end

      def card_number_not_found_message
        "I'm sorry, that card number was not found. Please try again. (Note: this service only works in California right now.)"
      end

      def balance_message_for(ebt_amount, cash_amount)
        "Hi! Your food stamp balance is #{ebt_amount} and your cash balance is #{cash_amount}."
      end
    end

    module SpanishTranscriptionMessages
      def having_trouble_try_again_message
        "Lo siento! Actualmente estamos teniendo problemas comunicándonos con el sistema de EBT. Favor de enviar su # de EBT por texto en unos minutos."
      end

      def card_number_not_found_message
        "Lo siento, no se encontró el número de tarjeta. Por favor, inténtelo de nuevo. (Nota: este servicio sólo funciona en California en este momento.)"
      end

      def balance_message_for(ebt_amount, cash_amount)
        "Hola! El saldo de su cuenta de estampillas para comida es #{ebt_amount} y su balance de dinero en efectivo es #{cash_amount}."
      end
    end
  end
end

class StateHandler::MO < StateHandler::Base
  PHONE_NUMBER = '+18009977777'
  ALLOWED_NUMBER_OF_EBT_CARD_DIGITS = [16]

  def button_sequence(ebt_number)
    "wwwwwwwwwwwwww1wwwwwwwwwwwwwwwwww2wwwwwwww#{ebt_number}"
  end

  def transcribe_balance_response(transcription_text, language = :english)
    BalanceTranscriber.new(language).transcribe_balance_response(transcription_text)
  end

  class BalanceTranscriber
    attr_reader :language

    def initialize(language)
      @language = language
      if language == :spanish
        extend SpanishTranscriptionMessages
      else
        extend EnglishTranscriptionMessages
      end
    end

    def transcribe_balance_response(transcription_text)
      if transcription_text == nil
        return having_trouble_try_again_message
      end
      regex_matches = transcription_text.scan(/(\$\S+)/)
      if transcription_text.include?("say I don't have it")
        card_number_not_found_message
      elsif regex_matches.count > 0
        ebt_amount = regex_matches[0][0]
        balance_message_for(ebt_amount)
      else
        having_trouble_try_again_message
      end
    end

    module EnglishTranscriptionMessages
      def having_trouble_try_again_message
        "I'm really sorry! We're having trouble contacting the EBT system right now. Please text your EBT # again in a few minutes."
      end

      def card_number_not_found_message
        "I'm sorry, that card number was not found. Please try again."
      end

      def balance_message_for(ebt_amount)
        "Hi! Your food stamp balance is #{ebt_amount}."
      end
    end

    module SpanishTranscriptionMessages
      def having_trouble_try_again_message
        "Lo siento! Actualmente estamos teniendo problemas comunicándonos con el sistema de EBT. Favor de enviar su # de EBT por texto en unos minutos."
      end

      def card_number_not_found_message
        "Lo siento, no se encontró el número de tarjeta. Por favor, inténtelo de nuevo."
      end

      def balance_message_for(ebt_amount)
        "Hola! El saldo de su cuenta de estampillas para comida es #{ebt_amount}."
      end
    end
  end
end

class StateHandler::TX < StateHandler::Base
  PHONE_NUMBER = '+18007777328'
  ALLOWED_NUMBER_OF_EBT_CARD_DIGITS = [19]

  def button_sequence(ebt_number)
    "wwww1wwwwww#{ebt_number}ww"
  end

  def transcribe_balance_response(transcription_text, language = :english)
    BalanceTranscriber.new(language).transcribe_balance_response(transcription_text)
  end

  class BalanceTranscriber
    attr_reader :language

    def initialize(language)
      @language = language
      if language == :spanish
        extend SpanishTranscriptionMessages
      else
        extend EnglishTranscriptionMessages
      end
    end

    def transcribe_balance_response(transcription_text)
      if transcription_text == nil
        return having_trouble_try_again_message
      end
      regex_matches = transcription_text.scan(/(\$\S+)/)
      if transcription_text.include?("please enter the")
        card_number_not_found_message
      elsif regex_matches.count > 0
        ebt_amount = regex_matches[0][0]
        balance_message_for(ebt_amount)
      else
        having_trouble_try_again_message
      end
    end

    module EnglishTranscriptionMessages
      def having_trouble_try_again_message
        "I'm really sorry! We're having trouble contacting the EBT system right now. Please text your EBT # again in a few minutes."
      end

      def card_number_not_found_message
        "I'm sorry, that card number was not found. Please try again."
      end

      def balance_message_for(ebt_amount)
        "Hi! Your food stamp balance is #{ebt_amount}."
      end
    end

    module SpanishTranscriptionMessages
      def having_trouble_try_again_message
        "Lo siento! Actualmente estamos teniendo problemas comunicándonos con el sistema de EBT. Favor de enviar su # de EBT por texto en unos minutos."
      end

      def card_number_not_found_message
        "Lo siento, no se encontró el número de tarjeta. Por favor, inténtelo de nuevo."
      end

      def balance_message_for(ebt_amount)
        "Hola! El saldo de su cuenta de estampillas para comida es #{ebt_amount}."
      end
    end
  end
end

class StateHandler::UnhandledState < StateHandler::CA
end
