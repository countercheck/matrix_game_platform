require 'rails_helper'

RSpec.describe SessionsController, type: :controller do
  describe 'GET #new' do
    it 'returns a success response' do
      get :new
      expect(response).to be_successful
    end

    it 'renders the new template' do
      get :new
      expect(response).to render_template(:new)
    end
  end

  describe 'POST #create' do
    let!(:user) { create(:user, email: 'test@example.com', password: 'password123') }

    context 'with valid credentials' do
      it 'signs in the user' do
        post :create, params: { email: 'test@example.com', password: 'password123' }
        expect(session[:user_id]).to eq(user.id)
      end

      it 'redirects to root path' do
        post :create, params: { email: 'test@example.com', password: 'password123' }
        expect(response).to redirect_to(root_path)
      end

      it 'sets a success notice' do
        post :create, params: { email: 'test@example.com', password: 'password123' }
        expect(flash[:notice]).to eq('Logged in successfully!')
      end

      it 'handles case insensitive email' do
        post :create, params: { email: 'TEST@EXAMPLE.COM', password: 'password123' }
        expect(session[:user_id]).to eq(user.id)
      end
    end

    context 'with invalid email' do
      it 'does not sign in the user' do
        post :create, params: { email: 'wrong@example.com', password: 'password123' }
        expect(session[:user_id]).to be_nil
      end

      it 'renders the new template' do
        post :create, params: { email: 'wrong@example.com', password: 'password123' }
        expect(response).to render_template(:new)
      end

      it 'returns unprocessable content status' do
        post :create, params: { email: 'wrong@example.com', password: 'password123' }
        expect(response).to have_http_status(:unprocessable_content)
      end

      it 'sets an error flash message' do
        post :create, params: { email: 'wrong@example.com', password: 'password123' }
        expect(flash.now[:alert]).to eq('Invalid email or password')
      end
    end

    context 'with invalid password' do
      it 'does not sign in the user' do
        post :create, params: { email: 'test@example.com', password: 'wrongpassword' }
        expect(session[:user_id]).to be_nil
      end

      it 'renders the new template' do
        post :create, params: { email: 'test@example.com', password: 'wrongpassword' }
        expect(response).to render_template(:new)
      end

      it 'returns unprocessable content status' do
        post :create, params: { email: 'test@example.com', password: 'wrongpassword' }
        expect(response).to have_http_status(:unprocessable_content)
      end

      it 'sets an error flash message' do
        post :create, params: { email: 'test@example.com', password: 'wrongpassword' }
        expect(flash.now[:alert]).to eq('Invalid email or password')
      end
    end

    context 'with missing parameters' do
      it 'handles missing email' do
        post :create, params: { password: 'password123' }
        expect(session[:user_id]).to be_nil
        expect(flash.now[:alert]).to eq('Invalid email or password')
      end

      it 'handles missing password' do
        post :create, params: { email: 'test@example.com' }
        expect(session[:user_id]).to be_nil
        expect(flash.now[:alert]).to eq('Invalid email or password')
      end
    end
  end

  describe 'DELETE #destroy' do
    let(:user) { create(:user) }

    before do
      sign_in(user)
    end

    it 'signs out the user' do
      delete :destroy
      expect(session[:user_id]).to be_nil
    end

    it 'redirects to root path' do
      delete :destroy
      expect(response).to redirect_to(root_path)
    end

    it 'sets a success notice' do
      delete :destroy
      expect(flash[:notice]).to eq('Logged out successfully!')
    end
  end

  describe 'when user is not signed in' do
    it 'allows logout even when not signed in' do
      delete :destroy
      expect(response).to redirect_to(root_path)
      expect(flash[:notice]).to eq('Logged out successfully!')
    end
  end
end
