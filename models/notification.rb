# frozen_string_literal: true

# Class that contains the Notification model
class Notification < Sequel::Model(:documents_users)
  many_to_one :document
  many_to_one :user
end
