require 'spec_helper'
require File.expand_path('../../../lib/debit_card_number', __FILE__)

describe DebitCardNumber do
  it 'validates a correct-length number' do
    debit_number = DebitCardNumber.new('1234567890123456')
    expect(debit_number.is_valid?).to eq(true)
  end

  it 'invalidates a wrong-length number' do
    debit_number = DebitCardNumber.new('12345678901234')
    expect(debit_number.is_valid?).to eq(false)
  end

  it 'invalidates a string with any letters' do
    debit_number = DebitCardNumber.new('123456789012345a')
    expect(debit_number.is_valid?).to eq(false)
  end

  it 'invalidates all-letter input of 16 characters' do
    debit_number = DebitCardNumber.new('aaaaaaaaaaaaaaaa')
    expect(debit_number.is_valid?).to eq(false)
  end
end
