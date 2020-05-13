Sequel.migration do 
	up do
		add_column :documents, :date, String
		add_column :documents, :uploader, String
	end

	down do 
		drop_column :documents, :date
		drop_column :documents, :uploader
	end

end
