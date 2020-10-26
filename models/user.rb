# frozen_string_literal: true

# Class that contains the User model
class User < Sequel::Model
  plugin :validation_helpers
  def validate
    super
    validates_presence %i[email name password username]
    validates_unique(:email, :username)
    validates_min_length 5, :password
    validates_max_length 20, :password
    validates_unique(:email, :username)
    validates_format(/\A.*@.*\..*\z/, :email, message: 'is not a valid email')
    validates_format(/\A\w{3,15}\z/, :username, message: 'is not a valid username')
  end
  many_to_many :categories
  many_to_many :documents
  set_primary_key :id
end
