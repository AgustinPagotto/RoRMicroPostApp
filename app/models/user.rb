class User < ApplicationRecord
  # Database association where one user can have many microposts
  # Destroy makes that when the user is deleted, its microposts are delted as well
  has_many :microposts, dependent: :destroy
  # Defines the relationships being active follower-followed
  # And passive followed-follower
  has_many :active_relationships, class_name: 'Relationship', foreign_key: 'follower_id', dependent: :destroy
  has_many :passive_relationships, class_name: 'Relationship', foreign_key: 'followed_id', dependent: :destroy
  has_many :following, through: :active_relationships, source: :followed
  has_many :followers, through: :passive_relationships, source: :follower
  attr_accessor :remember_token, :activation_token, :reset_token

  before_save :downcase_email
  before_create :create_activation_digest

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :name, presence: true, length: { maximum: 50 }
  validates :email, presence: true, length: { maximum: 255 }, format: { with: VALID_EMAIL_REGEX },
                    uniqueness: true
  # present, length less than 72 bytes, confirmation password
  has_secure_password
  validates :password, presence: true, length: { minimum: 6 }, allow_nil: true
  # Returns the hash digest of the given string.
  def self.digest(string)
    cost = if ActiveModel::SecurePassword.min_cost
             BCrypt::Engine::MIN_COST
           else
             BCrypt::Engine
               .cost
           end
    BCrypt::Password.create(string, cost:)
  end

  # Returns a random token
  def self.new_token
    SecureRandom.urlsafe_base64
  end

  # Saves a new_token, which is encrypted, in the remember_digest attribute db
  # Remembers a user in the database for use in persistent sessions.
  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
    remember_digest
  end

  # Returns a session token to prevent session hijacking.
  # We reuse the remember digest for convenience.
  def session_token
    remember_digest || remember
  end

  # Returns true if the given token matches the digest.
  # remember_digest is available thanks to Active Record.
  # remember_token is not the same as the remember_token attr_accessor
  def authenticated?(attribute, token)
    # With send we can generalice the authenticated? method to check differents tokens/digests
    digest = send("#{attribute}_digest")
    return false if digest.nil?

    # If remember_digest is null we return false
    # return false if remember_digest.nil?

    BCrypt::Password.new(digest).is_password?(token)
  end

  # Forgets a user
  def forget
    update_attribute(:remember_digest, nil)
  end

  # Activates an account.
  def activate
    update_columns(activated: true, activated_at: Time.zone.now)
  end

  # Sends activation email.
  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  # Sets the password reset attributes.
  def create_reset_digest
    self.reset_token = User.new_token
    update_columns(reset_digest: User.digest(reset_token), reset_sent_at: Time.zone.now)
  end

  # Sends password reset email.
  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  # Returns ture if a password reset has expired
  def password_reset_expired?
    reset_sent_at < 2.hours.ago
  end

  # Returns a user's status feed.
  # following_ids is a method from Active Record based on the has_many :following to get the ids corresponding to the user.following collection
  def feed
    following_ids = 'SELECT followed_id FROM relationships WHERE follower_id = :user_id'
    Micropost.where("user_id IN (#{following_ids}) OR user_id = :user_id", user_id: id).includes(:user,
                                                                                                 image_attachment: :blob)

    # With the where only we pull only the micropost and not it attachments, the .includes helps mitigating this with what is called eager loading, which will retrieve the user and the image attached with the micropost
  end

  # Follows a user.
  def follow(other_user)
    following << other_user unless self == other_user
  end

  # Unfollows a user.
  def unfollow(other_user)
    following.delete(other_user)
  end

  # Returns true if the current user is following the other user.
  def following?(other_user)
    following.include?(other_user)
  end

  private

  # Converts email to all lowercase
  def downcase_email
    self.email = email.downcase
  end

  # Creates and assigns the activation token and digest.
  def create_activation_digest
    self.activation_token = User.new_token
    self.activation_digest = User.digest(activation_token)
  end
end
