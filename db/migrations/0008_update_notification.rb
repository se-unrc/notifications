# frozen_string_literal: true

Sequel.migration do
  up do
    alter_table(:notifications) do
      add_foreign_key :document_id, :documents, null: false
    end
  end

  down do
    drop_column :notifications, :document_id
  end
end
