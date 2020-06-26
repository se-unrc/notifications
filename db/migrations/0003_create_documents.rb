Sequel.migration do
  up do
    create_table(:documents) do
      primary_key :id
      String :name 
      String :subject
      foreign_key :user_id , :users 
      
    end
  end

  down do
    drop_table(:documents)
  end
end
