Sequel.migration do 

	up do
		add_column :documents_users, :read, TrueClass
		set_column_default :documents_users, :read, false
		add_column :documents_users, :datetime, DateTime
	end
	

	down do 
		drop_column :documents_users, :read
		drop_column :documents_users, :datetime
	end

end