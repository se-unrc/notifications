Sequel.migration do
  up do
    create_table(:users) do
    primary_key :id
    String :name, null: false
    String :surnames, null: false
    Integer :dni, null: false
    String :userName, null: false
    String :password, null: false
    #rol de tipo troles
  end
end
  down do
    drop_table(:users)
  end
end
