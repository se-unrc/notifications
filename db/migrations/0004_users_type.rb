Sequel.migration do 

	up do
		add_column :users, :type, String, null: false
		set_column_default :users, :type, 'user'  
	end
	

	down do 
		drop_column :users, :type
	end

end