Sequel.migration do
	up do
		add_column :docs, :users, String, null: false
		add_column :docs, :categories, String, null: false
		add_column :docs, :document, String, null: false
	end
	down do 
		drop_column :docs, :users
		drop_column :docs, :categories
		drop_column :docs, :document
	end

end
