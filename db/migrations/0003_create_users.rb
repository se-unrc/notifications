Sequel.migration do 
	up do
		add_column :users, :email, String, null: false
		add_column :users, :username, String, null: false
		add_column :users, :password, String, null: false
	end

	down do 
		drop_column :users, :email
		drop_column :users, :username
		drop_column :users, :password
	end

end