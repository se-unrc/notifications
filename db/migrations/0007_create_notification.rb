# frozen_string_literal: true

Sequel.migration do
  up do
    create_table(:notifications) do
      primary_key :id
      String :description, null: false
      String :date, null: false
    end
  end
  down do
    drop_table(:notifications)
  end
end
