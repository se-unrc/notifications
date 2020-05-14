Sequel.migration do
  up do
    add_column :users , :admin ,Integer , null: false
  end
  down do
    drop_column :users, :admin
  end
end
