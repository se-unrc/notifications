Sequel.migration do
  up do
    add_column :users ,:surnames ,String, null: false
    add_column :users ,:dni, Integer, null: false
    add_column :users ,:username, String, null: false
    add_column :users ,:password, String, null: false
    add_column :users ,:rol, String, null: false
    add_column :users ,:admin ,Integer, null: false
  end

  down do
    drop_column :users, :surnames
    drop_column :users, :dni
    drop_column :users, :username
    drop_column :users, :password
    drop_column :users, :rol
    drop_column :users, :admin
  end
end
