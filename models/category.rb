# frozen_string_literal: true

class Category < Sequel::Model
  many_to_many :users
  one_to_many :documents
  plugin :validation_helpers
  def validate
    super
    validates_presence %i[name description]
    validates_length_range 3..50, :name
    validates_length_range 3..300, :description
    validates_type String, %i[name description]
    validates_unique(%i[name description])
  end
end
