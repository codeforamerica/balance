module StateHandler
  extend self

  def for(state_abbreviation)
    if handled_states.include?(state_abbreviation.to_sym)
      eval("StateHandler::#{state_abbreviation}")
    else
      StateHandler::UnhandledState #StateHandler::CA by default, likely
    end
  end

  def handled_states
    constants
  end
end

module StateHandler::GenericMethods
  extend self

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

module StateHandler::CA
  extend self
  extend StateHandler::GenericMethods

  # Phone number formatted with +1, area code, 7-digit number
  def phone_number
    '+18773289677'
  end

  # Sequence of waits (w) and keystrokes (eg, 1)
  # for submitting EBT number to phone service
  def button_sequence(ebt_number)
    "ww1ww#{ebt_number}"
  end

  # Array of integers of allowed digit-length of an EBT card number
  # For example: [16], [16, 19]
  def allowed_number_of_ebt_card_digits
    [16]
  end

  # A method that takes a transcription and returns EITHER:
  # 1. A message with the balance, OR
  # 2. A message that the system could not find the balance
  def transcribe_balance_response(transcription_text)
    regex_matches = transcription_text.scan(/(\$\S+)/)
    if transcription_text.include?("non working card")
      "I'm sorry, that card number was not found. Please try again. (Note: this service only works in California right now.)"
    elsif regex_matches.count > 1
      ebt_amount = regex_matches[0][0]
      cash_amount = regex_matches[1][0]
      "Hi! Your food stamp balance is #{ebt_amount} and your cash balance is #{cash_amount}."
    else
      "I'm really sorry! We're having trouble contacting the EBT system right now. Please text your EBT # again in a few minutes."
    end
  end
end

module StateHandler::IL
  extend self
  extend StateHandler::GenericMethods

  # Phone number formatted with +1, area code, 7-digit number
  def phone_number
    '+18006785465'
  end

  # Sequence of waits (w) and keystrokes (eg, 1)
  # for submitting EBT number to phone service
  def button_sequence(ebt_number)
    "wwwwww1wwwwww#{ebt_number}#"
  end

  # Array of integers of allowed digit-length of an EBT card number
  # For example: [16], [16, 19]
  def allowed_number_of_ebt_card_digits
    [16, 19]
  end

  # A method that takes a transcription and returns EITHER:
  # 1. A message with the balance, OR
  # 2. A message that the system could not find the balance
  def transcribe_balance_response(transcription_text)
    transcription_text
  end
end

module StateHandler::MO
  extend self
  extend StateHandler::GenericMethods

  # Phone number formatted with +1, area code, 7-digit number
  def phone_number
    '+18009977777'
  end

  # Sequence of waits (w) and keystrokes (eg, 1)
  # for submitting EBT number to phone service
  def button_sequence(ebt_number)
    "wwwwwwwwwwwwww1wwwwwwwwwwwwwwwwww2wwwwwwww#{ebt_number}"
  end

  # Array of integers of allowed digit-length of an EBT card number
  # For example: [16], [16, 19]
  def allowed_number_of_ebt_card_digits
    [16]
  end

  # A method that takes a transcription and returns EITHER:
  # 1. A message with the balance, OR
  # 2. A message that the system could not find the balance
  def transcribe_balance_response(transcription_text)
    regex_matches = transcription_text.scan(/(\$\S+)/)
    if transcription_text.include?("say I don't have it")
      "I'm sorry, that card number was not found. Please try again."
    elsif regex_matches.count > 0
      ebt_amount = regex_matches[0][0]
      "Hi! Your food stamp balance is #{ebt_amount}."
    else
      "I'm really sorry! We're having trouble contacting the EBT system right now. Please text your EBT # again in a few minutes."
    end
  end
end

module StateHandler::UnhandledState
  extend StateHandler::CA
end
