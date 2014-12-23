# Fake of lib/phone_number_processor for use in testing web app
# without hitting Twilio

class FoneNumberProcessor
  def initialize
    @language_hash = { '+15556667777' => :english, '+19998887777' => :spanish }
  end

  def twilio_number?(phone_number)
    @language_hash.keys.include?(phone_number)
  end

  def language_for(phone_number)
    @language_hash[phone_number] or :english
  end
end
