class UserController < ActionController::API
  def sign_up
    permitted_params = params.permit(:email, :password)
    user = User.new(permitted_params)
    if user.save
      # If your User model has a `to_token_payload` method, you should use that here
      auth_token = Knock::AuthToken.new payload: { sub: user.id }
      render json: auth_token, status: :created
    else
      render json: { error: user.errors.full_messages }, status: :unprocessable_entity
    end
  end
end
