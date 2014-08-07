class DebitCardNumber
  attr_accessor :number

  def initialize(number)
    @number = number
  end

  def to_s
    @number
  end

  def is_valid?
    if number.length == 16 && number.match(/\D+/) == nil
      return true
    else
      return false
    end
  end
end
