# frozen_string_literal: true

# Class that contains the Document model
class Document < Sequel::Model
  plugin :validation_helpers
  def validate
    super
    validates_presence %i[date name categorytaged document]
  end
  many_to_one :categories
  many_to_many :users
  set_primary_key :id
end
