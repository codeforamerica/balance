class StatusCheckHelper
  def contains_balance_response?(string)
    string.include?("Hi! Your food") or
      string.include?("I'm really sorry! We're having trouble") or
      string.include?("I'm sorry, that card number was not found")
  end
end
