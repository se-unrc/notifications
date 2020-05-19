class Subscription < Sequel::Model(:categories_users)
	many_to_one  :category
	many_to_one :user
end
