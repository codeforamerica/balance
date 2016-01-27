require 'numbers_in_words'

class DollarAmountsProcessor

  TwilioEnglish = NumbersInWords::English.dup
  TwilioEnglish.module_eval do
    def self.canonize(w)
      w = NumbersInWords::English.canonize(w)
      aliases = {
        "boy" => "forty"
      }
      canon = aliases[w]
      return canon ? canon : w
    end
  end

  Words = TwilioEnglish.exceptions_to_i.keys +
    TwilioEnglish.powers_of_ten_to_i.keys +
    # NumbersInWords does weird things with digits, can not specify in the language
    (0..9).map(&:to_s) +
    # aliases in canonize are not exposed
    ['oh', 'boy']
  MatchDigit = /\b(#{TwilioEnglish.exceptions.keys.join('|')})\b/i
  MatchWord = /\b(?:#{Words.join('|')})\b/i
  MatchAmountWithCent = /((?:#{MatchWord}\s+)+)\s*dollars?(?:\.? and)?(?:((?:\s+#{MatchWord}){1,2})\s+cents?)?/si
  InvalidZeros = /the\s+(row|euro)\.?\s*dollars/si

  def process(text_with_words)
    text_with_words.gsub(InvalidZeros, 'zero dollars').gsub(MatchAmountWithCent) do |amount|
      m = Regexp.last_match
      dollars = in_numbers(m[1])
      dollars += 0.01 * in_numbers(m[2]) if m[2]
      '$%.2f' % [ dollars ]
    end
  end

  def digits_to_words(text_with_digits)
    text_with_digits.gsub(MatchDigit) do |digit|
      NumbersInWords::English.exceptions[digit.to_i]
    end
  end

  def in_numbers(text)
    NumbersInWords.in_numbers(digits_to_words(text), TwilioEnglish)
  end

end
