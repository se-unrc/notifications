Sequel.migration do
  up do
    create_table(:documents) do
    primary_key :id
    Integer :numero_document, null: false
    String :name, null: false
    #categoria de la tabla categories y fecha del tipo date....
  end
end
  down do
    drop_table(:documents)
  end
end
