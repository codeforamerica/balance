class BalanceLogAnalyzer < Struct.new(:messages)
  def balance_messages_being_sent?
    most_recent_thanks_msg = find_most_recent_thanks_message_more_than_5_mins_old
    time_thanks_message_sent = Time.parse(most_recent_thanks_msg.date_sent)
    phone_number_that_should_receive_balance = most_recent_thanks_msg.to
    target_balance_responses = messages.select do |m|
      m.to == phone_number_that_should_receive_balance &&
        (Time.parse(m.date_sent) - time_thanks_message_sent) > 0 &&
        contains_balance_response?(m.body)
    end
    if target_balance_responses.count > 0
      true
    else
      false
    end
  end

  def find_most_recent_thanks_message_more_than_5_mins_old
    messages.select do |m|
      (Time.now - Time.parse(m.date_sent)) > 300 && m.body.include?('Thanks! Please wait')
    end.max_by do |m|
      Time.parse(m.date_sent)
    end
  end

  def contains_balance_response?(string)
    string.include?("Hi! Your food") or
      string.include?("I'm really sorry! We're having trouble") or
      string.include?("I'm sorry, that card number was not found")
  end
end
