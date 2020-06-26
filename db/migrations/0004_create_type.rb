Sequel.migration do
  up do
    add_column :users, :type, String
  end

  down do
    drop_column :users, :type
  end
end
