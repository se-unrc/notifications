Sequel.migration do
  up do
    create_table(:notifications) do
      primary_key :id
      String :description, null: false
      String :date, null: false
      add_foreign_key :document_id, :documents, :null=>false
    end
  end
  down do
    drop_table(:notifications)
  end
end
