Sequel.migration do
	up do
		alter_table :users do
			rename_column :type, :role
		end
	end
end