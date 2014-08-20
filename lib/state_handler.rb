module StateHandler
  extend self

  def for(state_abbreviation)
    if constants.include?(state_abbreviation.to_sym)
      eval("StateHandler::#{state_abbreviation}")
    else
      StateHandler::UnhandledState #StateHandler::CA by default, likely
    end
  end
end

module StateHandler::UnhandledState
end

module StateHandler::CA
end
