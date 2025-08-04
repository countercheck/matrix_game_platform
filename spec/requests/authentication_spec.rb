require 'rails_helper'

RSpec.describe 'Authentication', type: :request do
  describe 'User Registration' do
    describe 'GET /signup' do
      it 'returns success' do
        get '/signup'
        expect(response).to have_http_status(:success)
      end

      it 'renders the signup form' do
        get '/signup'
        expect(response.body).to include('Sign Up')
      end
    end

    describe 'POST /signup' do
      let(:valid_params) do
        {
          user: {
            username: 'testuser',
            email: 'test@example.com',
            password: 'password123',
            password_confirmation: 'password123'
          }
        }
      end

      context 'with valid parameters' do
        it 'creates a new user' do
          expect {
            post '/signup', params: valid_params
          }.to change(User, :count).by(1)
        end

        it 'signs in the user' do
          post '/signup', params: valid_params
          expect(session[:user_id]).to eq(User.last.id)
        end

        it 'redirects to root path' do
          post '/signup', params: valid_params
          expect(response).to redirect_to(root_path)
        end
      end

      context 'with invalid parameters' do
        let(:invalid_params) do
          {
            user: {
              username: '',
              email: 'invalid-email',
              password: '123',
              password_confirmation: 'different'
            }
          }
        end

        it 'does not create a user' do
          expect {
            post '/signup', params: invalid_params
          }.not_to change(User, :count)
        end

        it 'returns unprocessable entity' do
          post '/signup', params: invalid_params
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end
  end

  describe 'User Login' do
    let!(:user) { create(:user, email: 'test@example.com', password: 'password123') }

    describe 'GET /login' do
      it 'returns success' do
        get '/login'
        expect(response).to have_http_status(:success)
      end

      it 'renders the login form' do
        get '/login'
        expect(response.body).to include('Log In')
      end
    end

    describe 'POST /login' do
      context 'with valid credentials' do
        it 'signs in the user' do
          post '/login', params: { email: 'test@example.com', password: 'password123' }
          expect(session[:user_id]).to eq(user.id)
        end

        it 'redirects to root path' do
          post '/login', params: { email: 'test@example.com', password: 'password123' }
          expect(response).to redirect_to(root_path)
        end
      end

      context 'with invalid credentials' do
        it 'does not sign in the user' do
          post '/login', params: { email: 'test@example.com', password: 'wrongpassword' }
          expect(session[:user_id]).to be_nil
        end

        it 'returns unprocessable entity' do
          post '/login', params: { email: 'test@example.com', password: 'wrongpassword' }
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end
  end

  describe 'User Logout' do
    let!(:user) { create(:user) }

    before do
      post '/login', params: { email: user.email, password: 'password123' }
    end

    describe 'DELETE /logout' do
      it 'signs out the user' do
        delete '/logout'
        expect(session[:user_id]).to be_nil
      end

      it 'redirects to root path' do
        delete '/logout'
        expect(response).to redirect_to(root_path)
      end
    end
  end
end
