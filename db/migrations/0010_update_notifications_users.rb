Sequel.migration do
  up do
    set_column_default :notifications_users, :seen, false
  end
  down do
    drop_table :notifications_users, :seen
  end
end
