# frozen_string_literal: true

# Modelo de User
class User < Sequel::Model
  many_to_many :categories
  many_to_many :documents
  one_to_many :relations
  plugin :validation_helpers
  def validate
    super
    validates_presence %i[name surname dni email password rol admin]
    validates_length_range 3..40, %i[name surname], message: 'not allowed'
    validates_integer :dni
    validates_type String, %i[name surname email password]
    validates_unique(%i[name surname dni], :email)
    validates_operator(:>, 0, :dni)
  end
end
