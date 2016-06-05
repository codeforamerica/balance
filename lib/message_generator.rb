class MessageGenerator
  attr_reader :language

  def initialize(language = :english)
    @language = language
    case @language
    when :spanish
      I18n.locale = :es
    else
      I18n.locale = :en
    end
  end

  def thanks_please_wait
    I18n.t :thanks_please_wait
  end

  def balance_message(food_stamp_balance, optional_balances = {})
    if optional_balances[:cash]
      I18n.t :optional, scope: [:balance_message], balance: food_stamp_balance, cash: optional_balances[:cash]
    else
      I18n.t :default, scope: [:balance_message], balance: food_stamp_balance
    end
  end

  def sorry_try_again(digits_array = [])
    if digits_array == nil
      I18n.t :default, scope: [:sorry_try_again]
    elsif digits_array.length == 1
      I18n.t :one_number, scope: [:sorry_try_again], default: [:default], digits_one: digits_array[0]
    elsif digits_array.length == 2
      I18n.t :two_numbers, scope: [:sorry_try_again], default: [:default], digits_one: digits_array[0], digits_two: digits_array[1]
    else
      I18n.t :default, scope: [:sorry_try_again]
    end
  end

  def welcome
    I18n.t :welcome
  end

  def having_trouble_try_again_message
    I18n.t :having_trouble_try_again_message
  end

  def card_number_not_found_message
    I18n.t :card_number_not_found_message
  end

  def call_in_voice_file_url
    if language == :spanish
      'https://s3-us-west-1.amazonaws.com/balance-cfa/balance-voice-splash-spanish-v2-012515.mp3'
    else
      'https://s3-us-west-1.amazonaws.com/balance-cfa/balance-voice-splash-v4-012515.mp3'
    end
  end

  def more_info
    I18n.t :more_info
  end
end
