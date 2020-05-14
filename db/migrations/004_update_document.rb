Sequel.migration do
  up do
    drop_column :documents , :numero_document
    add_column :documents , :file ,File , null: false
    add_column :documents , :description ,String , null: false
    add_column :documents , :date ,String , null: false
    alter_table(:documents) do
        add_foreign_key :category_id, :categories, :null=>false
    end
  end
  down do
    add_column  :documents, :numero_document
    drop_column :documents, :file
    drop_column :documents, :description
    drop_column :documents, :date
    drop_column :documents, :category_id
  end
end