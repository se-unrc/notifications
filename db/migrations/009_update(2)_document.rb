Sequel.migration do
  up do
    drop_column :documents , :file
    add_column :documents , :fileDocument ,String , null: false
  end
  down do
    add_column :documents , :file
  end
end
