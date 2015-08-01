module BalanceLogAnalyzer
  class DelayedBalanceResponseAnalysis
    attr_reader :most_recent_thanks_msg,
                :time_thanks_message_sent,
                :phone_number_that_should_receive_balance

    def initialize(messages)
      @most_recent_thanks_msg = find_most_recent_thanks_message_more_than_5_mins_old(messages)
      @time_thanks_message_sent = Time.parse(most_recent_thanks_msg.date_sent)
      @phone_number_that_should_receive_balance = most_recent_thanks_msg.to
      balance_responses_to_waiting_person = messages.select do |m|
        m.to == phone_number_that_should_receive_balance &&
          (Time.parse(m.date_sent) - time_thanks_message_sent) > 0 &&
          MessageAnalyzer.new.contains_balance_response?(m.body)
      end
      if balance_responses_to_waiting_person.count > 0
        @are_messages_delayed = false
      else
        @are_messages_delayed = true
        @problem_description = "Missing balance response: User with number ending '#{@phone_number_that_should_receive_balance[-5..-1]}' did not receive a response within 5 minutes to their request at #{@time_thanks_message_sent.in_time_zone('Pacific Time (US & Canada)').strftime("%Y-%m-%d %H:%M:%S")} Pacific. 'Thanks' message SID: #{@most_recent_thanks_msg.sid}"
      end
    end

    def messages_delayed?
      @are_messages_delayed
    end

    def problem_description
      @problem_description || 'No problem'
    end

    private
    def find_most_recent_thanks_message_more_than_5_mins_old(message_array)
      message_array.select do |m|
        (Time.now - Time.parse(m.date_sent)) > 300 && m.body.include?('Thanks! Please wait')
      end.max_by do |m|
        Time.parse(m.date_sent)
      end
    end
  end

  class MessageAnalyzer
    def contains_balance_response?(string)
      string.include?("Hi! Your food") or
        string.include?("I'm sorry! We're having trouble") or
        string.include?("I'm sorry, that card number was not found")
    end
  end
end
