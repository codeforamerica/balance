require 'numbers_in_words'
class DollarAmountsProcessor

  Words = NumbersInWords::English.exceptions.values
  MatchWord = /\b(?:#{Words.join('|')})\b/
  MatchAmount = /(?:#{MatchWord}\s+){1,9}dollars?(?: and)?(?:\s+#{MatchWord}){1,2}\s+cents?/s


  def process(text_with_words)
    text_with_words.gsub(MatchAmount) do |amount|
      amount.gsub!(/dollars?/, 'point')
      amount.gsub!(/cents?/, '')

      '$%.2f' % [ NumbersInWords.in_numbers(amount) ]
    end.gsub('the euro', '$0.00')
  end

end
