class User < Sequel::Model
	plugin :validation_helpers
  def validate
    super
    validates_presence [:name, :email, :username, :password]
    validates_unique [:username]
  end
end
