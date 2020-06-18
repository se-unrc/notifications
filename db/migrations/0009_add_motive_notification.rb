Sequel.migration do 

	up do
		add_column :documents_users, :motive, String  
	end
	

	down do 
		drop_column :users, :type
	end

end