Sequel.migration do
	up do
		create_table(:categories_users) do
		  foreign_key :category_id, :categories, :null=>false
		  foreign_key :user_id, :users, :null=>false
		  primary_key [:category_id, :user_id]
		  index [:category_id, :user_id]
	 end
 end
	 down do
		 drop_table :categories_users
	 end
end