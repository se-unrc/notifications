Sequel.migration do                                                                                           
        up do                                                                                                       
          create_table(:docs) do                                                                                   
            primary_key :id                                                                                         
            String :name, null: false
            String :date, null: false                                                                               
          end                                                                                                       
        end                                                                                                         
        down do                                                                                                     
          drop_table(:users)                                                                                        
        end                                                                                                         
      end