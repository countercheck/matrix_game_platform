require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    subject { build(:user) }

    it { should validate_presence_of(:username) }
    it { should validate_uniqueness_of(:username).case_insensitive }
    it { should validate_length_of(:username).is_at_least(3).is_at_most(30) }

    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email).case_insensitive }
    it { should allow_value('user@example.com').for(:email) }
    it { should_not allow_value('invalid-email').for(:email) }

    it { should validate_length_of(:password).is_at_least(6) }
    it { should have_secure_password }
  end

  describe 'username validation' do
    it 'is invalid with a username shorter than 3 characters' do
      user = build(:user, :with_short_username)
      expect(user).not_to be_valid
      expect(user.errors[:username]).to include('is too short (minimum is 3 characters)')
    end

    it 'is invalid with a username longer than 30 characters' do
      user = build(:user, :with_long_username)
      expect(user).not_to be_valid
      expect(user.errors[:username]).to include('is too long (maximum is 30 characters)')
    end

    it 'is invalid with a duplicate username (case insensitive)' do
      create(:user, username: 'testuser')
      user = build(:user, username: 'TESTUSER')
      expect(user).not_to be_valid
      expect(user.errors[:username]).to include('has already been taken')
    end
  end

  describe 'email validation' do
    it 'is invalid with an invalid email format' do
      user = build(:user, :with_invalid_email)
      expect(user).not_to be_valid
      expect(user.errors[:email]).to include('is invalid')
    end

    it 'is invalid with a duplicate email (case insensitive)' do
      create(:user, email: 'test@example.com')
      user = build(:user, email: 'TEST@EXAMPLE.COM')
      expect(user).not_to be_valid
      expect(user.errors[:email]).to include('has already been taken')
    end
  end

  describe 'password validation' do
    it 'is invalid with a password shorter than 6 characters' do
      user = build(:user, :with_short_password)
      expect(user).not_to be_valid
      expect(user.errors[:password]).to include('is too short (minimum is 6 characters)')
    end

    it 'requires password confirmation to match' do
      user = build(:user, password: 'password123', password_confirmation: 'different')
      expect(user).not_to be_valid
      expect(user.errors[:password_confirmation]).to include("doesn't match Password")
    end
  end

  describe 'before_save callbacks' do
    it 'converts email to lowercase before saving' do
      user = create(:user, email: 'TEST@EXAMPLE.COM')
      expect(user.email).to eq('test@example.com')
    end

    it 'converts username to lowercase before saving' do
      user = create(:user, username: 'TESTUSER')
      expect(user.username).to eq('testuser')
    end
  end

  describe 'authentication' do
    let(:user) { create(:user, password: 'password123') }

    it 'authenticates with correct password' do
      expect(user.authenticate('password123')).to eq(user)
    end

    it 'does not authenticate with incorrect password' do
      expect(user.authenticate('wrongpassword')).to be_falsey
    end
  end

  describe 'factory' do
    it 'creates a valid user' do
      user = build(:user)
      expect(user).to be_valid
    end

    it 'creates a user with unique attributes' do
      user1 = create(:user)
      user2 = create(:user)
      
      expect(user1.username).not_to eq(user2.username)
      expect(user1.email).not_to eq(user2.email)
    end
  end
end
