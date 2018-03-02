class User < ApplicationRecord
  has_secure_password

  validates :email, uniqueness: true, presence: true

  def token
    Knock::AuthToken.new(payload: { sub: id }).token
  end

  def as_json(options)
    options.merge({
      id: id,
      name: name,
      email: email,
      facebook_id: facebook_id,
    })
  end
end
