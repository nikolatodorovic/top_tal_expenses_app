require 'rails_helper'

describe User do

  it 'has a valid factory' do
    expect(build(:user)).to be_valid
  end

  it 'is invalid without an email' do
    expect(build(:user, email: nil)).to_not be_valid
  end

  it 'is invalid without a password' do
    expect(build(:user, password: nil)).to_not be_valid
  end
  
  it 'should not be a manager' do
    user = build(:user_admin)
    expect(user.id_role).to_not be 3
  end

  it 'should be a manager' do
    user = build(:user_manager)
    expect(user.id_role).to be 3
  end

end