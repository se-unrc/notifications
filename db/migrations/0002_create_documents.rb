Sequel.migration do                                                                                           
        up do                                                                                                       
          create_table(:documents) do                                                                                   
            primary_key :id                                                                                         
            String :name, null: false
            Date :date, null: false
            String :users, null: false
            String :categories, null: false
            String :document, null: false                                                                              
          end                                                                                                       
        end                                                                                                         
        down do                                                                                                     
          drop_table(:documents)                                                                                        
        end                                                                                                         
      end