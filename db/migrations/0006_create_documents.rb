Sequel.migration do 
	up do
		add_column :documents, :subject, String
		
	end

	down do 
		drop_column :documents, :subject
		
	end

end
