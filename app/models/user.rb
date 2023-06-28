class User < ApplicationRecord
  before_save { self.email = email.downcase }
  validates(:name, presence: true, length: { Settings.user_model.max_name_length })

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates(:email, presence: true, length: { maximum: Settings.user_model.max_email_length },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: true)

  has_secure_password
  validates(:password, presence: true, length: { minimum: Settings.user_model.min_pw_length })
end
