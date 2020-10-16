# frozen_string_literal: true

# Modelo de Notification
class Notification < Sequel::Model
  many_to_many :users
  one_to_one :documents
end
