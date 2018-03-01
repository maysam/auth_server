class User < ApplicationRecord
  has_secure_password

  validates :email, uniqueness: true, presence: true

  def token
    Knock::AuthToken.new(payload: { sub: id }).token
  end
end
