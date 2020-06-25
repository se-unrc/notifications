Sequel.migration do
  up do
    create_table(:notifications_users) do
      foreign_key :notification_id, :notifications, :null=>false
      foreign_key :user_id, :users, :null=>false
      primary_key [:notification_id, :user_id]
      index [:notification_id, :user_id]
      Boolean :seen, null: false
    end
  end
  down do
    drop_table :notifications_users
  end
end
