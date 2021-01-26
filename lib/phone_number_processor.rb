require 'twilio-ruby'

class PhoneNumberProcessor
  SUPPORTED_LANGUAGES = ["spanish","russian","yupik"]
  attr_reader :lookup_hash

  def initialize
    @lookup_hash = Hash.new
    phone_number_list = Twilio::REST::Client.new(ENV['TWILIO_SID'], ENV['TWILIO_AUTH']).account.incoming_phone_numbers.list
    phone_number_list.each do |pn|
      SUPPORTED_LANGUAGES.each do |language|
        if pn.friendly_name.include?(language.to_s)
          @lookup_hash[pn.phone_number] = language.to_sym
		  break
        else
          @lookup_hash[pn.phone_number] = :english
        end
      end
    end
  end

  def twilio_number?(number)
    lookup_hash.keys.include?(number)
  end

  def language_for(phone_number)
    if phone_number.include?('+') == false
      phone_number_with_plus = '+' + phone_number
      lookup_hash[phone_number_with_plus]
    else
      lookup_hash[phone_number]
    end
  end
end
