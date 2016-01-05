require 'numbers_in_words'
class DollarAmountsProcessor

  Words = NumbersInWords::English.exceptions.values +
    NumbersInWords::English.powers_of_ten.values
  MatchWord = /\b(?:#{Words.join('|')})\b/
  MatchAmount = /(?:#{MatchWord}\s+){1,9}dollars?/s
  MatchAmountWithCent = /#{MatchAmount}(?: and)?(?:\s+#{MatchWord}){1,2}\s+cents?/s


  def process(text_with_words)
    text_with_words.gsub(MatchAmountWithCent) do |amount|
      amount.gsub!(/dollars?/, 'point')
      amount.gsub!(/cents?/, '')

      '$%.2f' % [ NumbersInWords.in_numbers(amount) ]
    end.gsub(MatchAmount) do |amount|
      amount.gsub!(/dollars?/, '')

      '$%.2f' % [ NumbersInWords.in_numbers(amount) ]
    end.gsub('the euro', '$0.00')
  end

end
