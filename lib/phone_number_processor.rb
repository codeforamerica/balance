class PhoneNumberProcessor
  def initialize
    @list = Twilio::REST::Client.new(ENV['TWILIO_SID'], ENV['TWILIO_AUTH']).account.incoming_phone_numbers.list.map { |pn| pn.friendly_name }
  end

  def show
    @list
  end
end
