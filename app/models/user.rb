class User < ApplicationRecord
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  attr_accessor :remember_token, :activation_token, :reset_token

  has_many :microposts, dependent: :destroy
  has_many(:active_relationships, class_name: Relationship.name,
    foreign_key: :follower_id, dependent: :destroy)
  has_many(:following, through: :active_relationships, source: :followed)
  has_many(:passive_relationships, class_name: Relationship.name,
    foreign_key: :followed_id, dependent: :destroy)
  has_many(:followers, through: :passive_relationships, source: :follower)

  before_create :create_activation_method
  before_save :downcase_email

  scope :activated_users, -> { where(activated: true) }

  validates(:name, presence: true,
    length: { maximum: Settings.user_model.max_name_length })
  validates(:email, presence: true,
    length: { maximum: Settings.user_model.max_email_length },
    format: { with: VALID_EMAIL_REGEX }, uniqueness: true)
  validates(:password, presence: true,
    length: { minimum: Settings.user_model.min_pw_length },
    allow_nil: true
  )

  has_one_attached :avatar do |attachable|
    attachable.variant :display,
      resize_to_limit: [Settings.user_model.max_avatar_size, Settings.user_model.max_avatar_size]
  end

  has_secure_password

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

  def forget
    update_attribute(:remember_digest, nil)
  end

  # Returns a session token to prevent session hijacking
  # We reuse the remember digest for convenience
  def session_token
    remember_digest || remember
  end

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

  def password_reset_expired?
    reset_sent_at < 2.hours.ago
  end

  def feed
    following_ids = get_following_ids_query
    post = Micropost.arel_table
    Micropost.where(post[:user_id].in(following_ids)
      .or(post[:user_id].eq(id)))
    .latest
    .includes(:user, image_attachment: :blob)
  end

  def follow(other_user)
    following << other_user unless self == other_user
  end

  def unfollow(other_user)
    following.delete(other_user)
  end

  def following?(other_user)
    following.include?(other_user)
  end

  class << self

    def digest(string)
      cost = ActiveModel::SecurePassword.min_cost ?
        BCrypt::Engine::MIN_COST : BCrypt::Engine.cost

      BCrypt::Password.create(string, cost: cost)
    end

    def new_token
      SecureRandom.urlsafe_base64
    end

  end

  private

  def downcase_email
    self.email = email.downcase
  end

  def create_activation_method
    self.activation_token = User.new_token
    self.activation_digest = User.digest(activation_token)
  end

  def get_following_ids_query
    rela = Relationship.arel_table
    following_ids = rela.project(rela[:followed_id])
      .where(rela[:follower_id].eq(id))
  end

end
