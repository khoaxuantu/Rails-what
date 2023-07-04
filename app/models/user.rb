class User < ApplicationRecord
  attr_accessor :remember_token, :activation_token, :reset_token
  before_create :create_activation_method
  before_save :downcase_email

  scope :activated_users, -> { where(activated: true) }

  validates(:name, presence: true, length: { maximum: Settings.user_model.max_name_length })

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates(
    :email,
    presence: true,
    length: { maximum: Settings.user_model.max_email_length },
    format: { with: VALID_EMAIL_REGEX },
    uniqueness: true
  )

  has_secure_password
  validates(
    :password,
    presence: true,
    length: { minimum: Settings.user_model.min_pw_length },
    allow_nil: true
  )

  class << self

    # Returns the hash digest of the given string
    def digest(string)
      cost = ActiveModel::SecurePassword.min_cost ?
        BCrypt::Engine::MIN_COST : BCrypt::Engine.cost

      BCrypt::Password.create(string, cost: cost)
    end

    # Returns a random token
    def new_token
      SecureRandom.urlsafe_base64
    end

  end

  # Remember a user in the database for use in persistent sessions
  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
    remember_digest
  end

  def authenticated?(attribute, token)
    # The remember_digest must be existing first
    digest = self.send("#{attribute}_digest")
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end

  # Forgets an user
  def forget
    update_attribute(:remember_digest, nil)
  end

  # Returns a session token to prevent session hijacking
  # We reuse the remember digest for convenience
  def session_token
    remember_digest || remember
  end

  # Activates an account
  def activate
    update_columns(activated: true, activated_at: Time.zone.now)
  end

  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  def create_reset_digest
    self.reset_token = User.new_token
    update_columns(reset_digest: User.digest(self.reset_token),
      reset_sent_at: Time.zone.now)
  end

  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  # Return true if a password reset has expired
  def password_reset_expired?
    reset_sent_at < 2.hours.ago
  end

  private

    # Converts email to all lowercase
    def downcase_email
      self.email = email.downcase
    end

    ## Creates and assigns the activation token and digest
    def create_activation_method
      self.activation_token = User.new_token
      self.activation_digest = User.digest(activation_token)
    end
end
