Sequel.migration do
  up do
    create_table(:users) do
    primary_key :id
    String :name, null: false
    String :surnames, null: false
    Integer :dni, null: false
    String :userName, null: false
    String :password, null: false
    Integer :rol, null: false
  end
end
  down do
    drop_table(:users)
  end
end
