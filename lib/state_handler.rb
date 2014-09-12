require File.expand_path('../message_generator', __FILE__)

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

require 'require_all'
require_all File.expand_path('../state_handler', __FILE__)

class StateHandler::UnhandledState < StateHandler::CA
end
