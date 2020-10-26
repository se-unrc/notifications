# frozen_string_literal: true

# Class that contains the Subscription model
class Subscription < Sequel::Model(:categories_users)
  many_to_one :category
  many_to_one :user
end
