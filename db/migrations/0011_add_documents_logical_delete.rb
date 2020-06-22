Sequel.migration do 

	up do
		add_column :documents, :delete, TrueClass
		set_column_default :documents, :delete, false  
	end
	

	down do 
		drop_column :documents, :delete
	end

end