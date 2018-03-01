require 'koala'

class UserController < ActionController::API
  def new_password
    "#{Devise.friendly_token}1_Mm#{Devise.friendly_token}"
  end

  def fb_login
    begin
      # params
      # accessToken: "vEx13Rn7L0GAvxICTWzRLDR85XsylmKQyZA70IEnM2Au5CQR9ZASpURKIydQcQPtoeJtlvQZDZD"
      # expiresIn: 5456
      # id: "10160340817255227"
      # signedRequest: "kQ2VLeUZGN05sOUZtQlpVYyIsImlzc3VlZF9hdCI6MTUxOTc0NTM0NCwidXNlcl9pZCI6IjEwMTYwMzQwODE3MjU1MjI3In0"
      # userID: "10160340817255227"

      # @oauth = Koala::Facebook::OAuth.new
      # @oauth.get_app_access_token
      # signed_request_string = params[:auth][:signedRequest]
      # decoded_request = @oauth.parse_signed_request(signed_request_string)
      # assert(decoded_request['user_id'], params['facebook_id'])

      # {
      #   "algorithm"=>"HMAC-SHA256",
      #   "code"=>"nB5EFFDzI7jqzNoKPzG6jAXKVHmAFlYqUmHlCUaue-fkbHCZgwzUbHHmKwh3pWnJISaFQ0hUcAFobRP5yyJoT",
      #   "issued_at"=>1519911385,
      #   "user_id"=>"10160340817255227"
      # }

      facebook_token = params[:auth][:accessToken]
      # access_token and other values aren't required if you set the defaults as described above
      @graph = Koala::Facebook::API.new facebook_token
      if profile = @graph.get_object("me?fields=email,name")
        # {"email"=>"kherad@gmail.com", "name"=>"Maysam Torabi", "id"=>"10160340817255227"}
        email = profile['email']
        name = profile['name']
        facebook_id = profile['id']
      else
        facebook_id = params[:auth][:userID]
      end
      user = User.find_by email: email
      unless user
        user = User.find_by facebook_token: facebook_token if facebook_token
      end
      unless user
        user = User.find_by facebook_id: facebook_id if facebook_id
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
    rescue => e
      Rails.logger.warn "Error during processing: #{$!}"
      Rails.logger.warn "Backtrace:\n\t#{e.backtrace.join("\n\t")}"

      render json: e, status: :bad_request
    end
  end

  def sign_up
    permitted_params = params.permit(:email, :password)
    user = User.new(permitted_params)
    if user.save
      # If your User model has a `to_token_payload` method, you should use that here
      render json: { jwt: user.token }, status: :created
    else
      render json: { error: user.errors.full_messages }, status: :unprocessable_entity
    end
  end
end
