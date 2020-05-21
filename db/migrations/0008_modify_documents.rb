Sequel.migration do
  up do
    drop_column :documents ,:date
    add_column :documents ,:dateDoc, String, null: false
  end

  down do
    drop_column :documents, :dateDoc
  end
end
