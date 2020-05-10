Sequel.migration do
  up do
    drop_column :categories , :numero_category
  end
  down do
    add_column  :categories, :numero_category
  end
end
