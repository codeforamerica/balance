class DebitCardNumber
  attr_accessor :number

  def initialize(input)
    @number = extract_number_from_text(input)
  end

  def to_s
    @number
  end

  def extract_number_from_text(text)
    number_matches = text.match(/\d+/)
    number_matches.to_s
  end

  def is_valid?
    if number.length == 16 && number.match(/\D+/) == nil
      return true
    else
      return false
    end
  end
end
