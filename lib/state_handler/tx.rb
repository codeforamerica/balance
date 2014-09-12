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
