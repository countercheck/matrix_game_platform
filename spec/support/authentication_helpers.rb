module AuthenticationHelpers
  def sign_in(user)
    session[:user_id] = user.id
  end

  def sign_out
    session[:user_id] = nil
  end

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end
end

RSpec.configure do |config|
  config.include AuthenticationHelpers, type: :controller
  config.include AuthenticationHelpers, type: :request
end
