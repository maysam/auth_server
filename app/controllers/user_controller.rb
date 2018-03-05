require 'securerandom'
require 'koala'
require 'net/http'
require 'json'

class UserController < ActionController::API
  include Knock::Authenticable
  before_action :authenticate_user, except: [:fb_login, :sign_up, :login_on_fb, :fb_return]

  def profile
    render json: {user: current_user}
  end

  def login_on_fb
    oauth = Koala::Facebook::OAuth.new nil, nil, fb_return_url
    redirect_to oauth.url_for_oauth_code(permissions: 'email')
  end

  def fb_return
    oauth = Koala::Facebook::OAuth.new nil, nil, fb_return_url
    url = oauth.url_for_access_token(params[:code])
    uri = URI(url)
    response = Net::HTTP.get(uri)
    params = JSON.parse(response)
    create_user_on_facebook params['access_token']
  end

  def fb_login
    facebook_token = params[:auth][:accessToken]
    create_user_on_facebook facebook_token
  end

  def sign_up
    permitted_params = params.require(:user).permit(:name, :email, :password, :password_confirmation)
    user = User.new(permitted_params)
    if user.save
      # If your User model has a `to_token_payload` method, you should use that here
      render json: {user: user}, status: :created
    else
      render json: { errors: user.errors.full_messages.map { |e| {detail: e} } }, status: :unprocessable_entity
    end
  end

  private

  def new_password
     SecureRandom.urlsafe_base64(15).tr('lIO0', 'sxyz')
  end

  def create_user_on_facebook(facebook_token)
    graph = Koala::Facebook::API.new facebook_token
    if profile = graph.get_object("me?fields=email,name")
      email = profile['email']
      name = profile['name']
      facebook_id = profile['id']

      user = User.find_by email: email
      if !user && facebook_token
        user = User.find_by facebook_token: facebook_token
      end
      if !user && facebook_id
        user = User.find_by facebook_id: facebook_id
      end
      if user
        user.update_attributes facebook_token: facebook_token, facebook_id: facebook_id, name: name, email: email
      else
        user = User.create! email: email, name: name, facebook_id: facebook_id, facebook_token: facebook_token, password: new_password
      end

      if user.errors.messages.empty?
        render json: { jwt: user.token }
      else
        render json: user.errors.messages, status: :bad_request
      end
    end
  rescue => e
    Rails.logger.warn "Error during processing: #{$!}"
    Rails.logger.warn "Backtrace:\n\t#{e.backtrace.join("\n\t")}"

    render json: e, status: :bad_request
  end
end
