class User < ApplicationRecord
  attr_accessor :remember_token, :activation_token

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
