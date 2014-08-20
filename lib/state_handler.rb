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
    number_matches = whitespace_free_text.match(/\d+/)
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
end

module StateHandler::UnhandledState
  extend StateHandler::CA
end
