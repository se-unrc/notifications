Sequel.migration do
	up do
		create_table :subscriptions do
			primary_key :id
		end
		alter_table :subscriptions do
			add_foreign_key(:user_id, :users)
            add_foreign_key(:cat_id, :categories) 
		end
	end
    down do                                                                                             
        drop_table(:subscriptions)                                                                                        
    end  
end