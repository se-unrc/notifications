Sequel.migration do
	up do
		alter_table(:documents) do
        add_foreign_key :category_id, :categories, :null=>false
        end
	end
end