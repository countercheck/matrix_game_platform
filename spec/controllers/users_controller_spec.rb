require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  describe 'GET #new' do
    it 'returns a success response' do
      get :new
      expect(response).to be_successful
    end

    it 'assigns a new user to @user' do
      get :new
      expect(assigns(:user)).to be_a_new(User)
    end
  end

  describe 'POST #create' do
    context 'with valid parameters' do
      let(:valid_attributes) do
        {
          username: 'testuser',
          email: 'test@example.com',
          password: 'password123',
          password_confirmation: 'password123'
        }
      end

      it 'creates a new user' do
        expect {
          post :create, params: { user: valid_attributes }
        }.to change(User, :count).by(1)
      end

      it 'signs in the user' do
        post :create, params: { user: valid_attributes }
        expect(session[:user_id]).to eq(User.last.id)
      end

      it 'redirects to root path' do
        post :create, params: { user: valid_attributes }
        expect(response).to redirect_to(root_path)
      end

      it 'sets a success notice' do
        post :create, params: { user: valid_attributes }
        expect(flash[:notice]).to eq('Account created successfully!')
      end
    end

    context 'with invalid parameters' do
      let(:invalid_attributes) do
        {
          username: '',
          email: 'invalid-email',
          password: '123',
          password_confirmation: 'different'
        }
      end

      it 'does not create a new user' do
        expect {
          post :create, params: { user: invalid_attributes }
        }.not_to change(User, :count)
      end

      it 'does not sign in the user' do
        post :create, params: { user: invalid_attributes }
        expect(session[:user_id]).to be_nil
      end

      it 'renders the new template' do
        post :create, params: { user: invalid_attributes }
        expect(response).to render_template(:new)
      end

      it 'returns unprocessable entity status' do
        post :create, params: { user: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'assigns the user with errors to @user' do
        post :create, params: { user: invalid_attributes }
        expect(assigns(:user)).to be_a(User)
        expect(assigns(:user).errors).not_to be_empty
      end
    end

    context 'with missing parameters' do
      it 'raises parameter missing error when user params are missing' do
        expect {
          post :create, params: {}
        }.to raise_error(ActionController::ParameterMissing)
      end
    end
  end

  describe 'strong parameters' do
    it 'permits the correct parameters' do
      params = ActionController::Parameters.new(
        user: {
          username: 'testuser',
          email: 'test@example.com',
          password: 'password123',
          password_confirmation: 'password123',
          admin: true # This should not be permitted
        }
      )
      
      controller_instance = UsersController.new
      controller_instance.params = params
      
      permitted_params = controller_instance.send(:user_params)
      
      expect(permitted_params.keys).to contain_exactly('username', 'email', 'password', 'password_confirmation')
      expect(permitted_params.keys).not_to include('admin')
    end
  end
end
