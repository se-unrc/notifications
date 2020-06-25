class  NotificationUser < Sequel::Model(:notifications_users)
	many_to_one :notification
	many_to_one :user
end
