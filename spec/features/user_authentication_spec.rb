require 'rails_helper'

RSpec.feature 'User Authentication', type: :feature do
  feature 'User Registration' do
    scenario 'User successfully signs up with valid information' do
      visit '/signup'
      
      expect(page).to have_content('Sign Up for Matrix Game Platform')
      
      fill_in 'Username', with: 'testuser'
      fill_in 'Email', with: 'test@example.com'
      fill_in 'Password', with: 'password123'
      fill_in 'Password confirmation', with: 'password123'
      
      expect {
        click_button 'Sign Up'
      }.to change(User, :count).by(1)
      
      expect(page).to have_content('Account created successfully!')
      # Note: This test may fail if there's no root route defined
      expect(current_path).to eq(root_path)
    end

    scenario 'User fails to sign up with invalid information' do
      visit '/signup'
      
      fill_in 'Username', with: 'ab' # Too short
      fill_in 'Email', with: 'invalid-email'
      fill_in 'Password', with: '123' # Too short
      fill_in 'Password confirmation', with: 'different'
      
      expect {
        click_button 'Sign Up'
      }.not_to change(User, :count)
      
      expect(page).to have_content('Username is too short')
      expect(page).to have_content('Email is invalid')
      expect(page).to have_content('Password is too short')
      expect(page).to have_content("Password confirmation doesn't match")
    end

    scenario 'User cannot sign up with duplicate username' do
      create(:user, username: 'existinguser')
      
      visit '/signup'
      
      fill_in 'Username', with: 'existinguser'
      fill_in 'Email', with: 'new@example.com'
      fill_in 'Password', with: 'password123'
      fill_in 'Password confirmation', with: 'password123'
      
      click_button 'Sign Up'
      
      expect(page).to have_content('Username has already been taken')
    end

    scenario 'User cannot sign up with duplicate email' do
      create(:user, email: 'existing@example.com')
      
      visit '/signup'
      
      fill_in 'Username', with: 'newuser'
      fill_in 'Email', with: 'existing@example.com'
      fill_in 'Password', with: 'password123'
      fill_in 'Password confirmation', with: 'password123'
      
      click_button 'Sign Up'
      
      expect(page).to have_content('Email has already been taken')
    end
  end

  feature 'User Login' do
    let!(:user) { create(:user, email: 'test@example.com', password: 'password123') }

    scenario 'User successfully logs in with valid credentials' do
      visit '/login'
      
      expect(page).to have_content('Login to Matrix Game Platform')
      
      fill_in 'Email', with: 'test@example.com'
      fill_in 'Password', with: 'password123'
      
      click_button 'Log In'
      
      expect(page).to have_content('Logged in successfully!')
      expect(current_path).to eq(root_path)
    end

    scenario 'User fails to log in with invalid email' do
      visit '/login'
      
      fill_in 'Email', with: 'wrong@example.com'
      fill_in 'Password', with: 'password123'
      
      click_button 'Log In'
      
      expect(page).to have_content('Invalid email or password')
      expect(current_path).to eq('/login')
    end

    scenario 'User fails to log in with invalid password' do
      visit '/login'
      
      fill_in 'Email', with: 'test@example.com'
      fill_in 'Password', with: 'wrongpassword'
      
      click_button 'Log In'
      
      expect(page).to have_content('Invalid email or password')
      expect(current_path).to eq('/login')
    end

    scenario 'User login is case insensitive for email' do
      visit '/login'
      
      fill_in 'Email', with: 'TEST@EXAMPLE.COM'
      fill_in 'Password', with: 'password123'
      
      click_button 'Log In'
      
      expect(page).to have_content('Logged in successfully!')
      expect(current_path).to eq(root_path)
    end
  end

  feature 'User Logout' do
    let!(:user) { create(:user, email: 'test@example.com', password: 'password123') }

    scenario 'User successfully logs out' do
      # First log in
      visit '/login'
      fill_in 'Email', with: 'test@example.com'
      fill_in 'Password', with: 'password123'
      click_button 'Log In'
      
      expect(page).to have_content('Logged in successfully!')
      
      # Then log out (using direct request since logout link may not exist)
      page.driver.submit :delete, '/logout', {}
      
      expect(page).to have_content('Logged out successfully!')
      expect(current_path).to eq(root_path)
    end
  end

  feature 'Navigation between forms' do
    scenario 'User can navigate from login to signup' do
      visit '/login'
      
      click_link 'Sign up'
      
      expect(current_path).to eq('/signup')
      expect(page).to have_content('Sign Up for Matrix Game Platform')
    end

    scenario 'User can navigate from signup to login' do
      visit '/signup'
      
      click_link 'Log in'
      
      expect(current_path).to eq('/login')
      expect(page).to have_content('Login to Matrix Game Platform')
    end
  end
end
