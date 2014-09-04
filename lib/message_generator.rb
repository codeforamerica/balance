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
end
