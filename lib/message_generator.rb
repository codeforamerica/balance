class MessageGenerator
  def initialize(language = :english)
    @language = language
  end

  def thanks_please_wait
    "Thanks! Please wait 1-2 minutes while we check your EBT balance."
  end

  def sorry_try_again
    "Sorry, that EBT number doesn't look right. Please try again."
  end
end
