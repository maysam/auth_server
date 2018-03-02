class ApplicationController < ActionController::API
  include Knock::Authenticable
  before_action :authenticate_user

  def profile
    render json: {user: current_user}
  end
end
