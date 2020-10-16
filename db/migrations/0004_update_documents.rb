# frozen_string_literal: true

Sequel.migration do
  up do
    alter_table(:documents) do
      add_foreign_key :category_id, :categories, null: false
    end
  end

  down do
    drop_column :documents, :category_id
  end
end
