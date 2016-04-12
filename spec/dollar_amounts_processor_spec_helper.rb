require File.expand_path('../spec_helper', __FILE__)
require File.expand_path('../../lib/dollar_amounts_processor', __FILE__)

RSpec::Matchers.define :eq_text do |expected|
  def compr(text)
    text.gsub(/[\s\n\r]+/s,' ')
  end
  match do |actual|
    @expected = compr(expected)
    @actual   = compr(actual)
    @expected == @actual
  end
  failure_message do
    "\nexpected: #{expected_formatted}\n     got: #{actual_formatted}\n\n(compared using ==)\n"
  end

  def expected_formatted
    RSpec::Support::ObjectFormatter.format(@expected)
  end

  # @private
  def actual_formatted
    RSpec::Support::ObjectFormatter.format(@actual)
  end
end
