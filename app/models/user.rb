require 'openssl'

class User < ApplicationRecord
  ITERATIONS = 20_000
  DIGEST = OpenSSL::Digest::SHA256.new
  USERNAME_FORMAT = /\A\w+\z/
  EMAIL_FORMAT = /.+@.+\..+/

  attr_accessor :password

  has_many :questions
  before_validation :normalized_case
  before_save :encrypt_password
  validates :email, :username, presence: true, uniqueness: true
  validates :email, format: { with: EMAIL_FORMAT }
  validates :username, length: { maximum: 40 }, format: { with: USERNAME_FORMAT }
  validates :password, presence: true, on: :create, confirmation: true

  def encrypt_password
    if password.present?
      self.password_salt = User.hash_to_string(OpenSSL::Random.random_bytes(16))

      self.password_hash = User.hash_to_string(
        OpenSSL::PKCS5.pbkdf2_hmac(
          password, password_salt, ITERATIONS, DIGEST.length, DIGEST
        )
      )

    end
  end

  def self.hash_to_string(password_hash)
    password_hash.unpack('H*')[0]
  end

  def self.authenticate(email, password)
    user = find_by(email: email)

  return nil unless user.present?

    hashed_password = User.hash_to_string(
      OpenSSL::PKCS5.pbkdf2_hmac(
        password, user.password_salt, ITERATIONS, DIGEST.length, DIGEST
      )
    )
  return user if user.password_hash == hashed_password
    nil
  end


  def normalized_case
    self.username.downcase!
    self.email.downcase!
  end
end
