require 'numbers_in_words'
class DollarAmountsProcessor

  Words = NumbersInWords::English.exceptions.values +
    NumbersInWords::English.powers_of_ten.values
  MatchWord = /\b(?:#{Words.join('|')})\b/
  MatchAmountWithCent = /((?:#{MatchWord}\s+)+)\s*dollars?(?: and)?(?:((?:\s+#{MatchWord}){1,2})\s+cents?)?/s
  InvalidZeros = /the\s+(row|euro)\.?\s*dollars/si


  def process(text_with_words)
    text_with_words.gsub(InvalidZeros, 'zero dollars').gsub(MatchAmountWithCent) do |amount|
      m = Regexp.last_match
      dollars = NumbersInWords.in_numbers(m[1])
      dollars += 0.01 * NumbersInWords.in_numbers(m[2]) if m[2]
      '$%.2f' % [ dollars ]
    end
  end

end
