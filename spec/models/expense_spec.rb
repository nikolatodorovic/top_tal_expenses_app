require 'rails_helper'

describe Expense do

  it 'has a valid factory' do
    expect(build(:expense)).to be_valid
  end

  it 'is invalid without an amount' do
    expect(build(:expense, amount: nil)).to_not be_valid
  end

  it 'is invalid without a description' do
    expect(build(:expense, description: nil)).to_not be_valid
  end

  it 'is invalid without a time' do
    expect(build(:expense, for_timeday: nil)).to_not be_valid
  end

  it 'is invalid with a time set in the future' do
    expect(build(:expense_future)).to_not be_valid
  end

  it 'should belong to a user' do
    expense = build(:expense)
    user = build(:user)
    expense.user = user
    expect(expense.user).to be user
  end

  
end