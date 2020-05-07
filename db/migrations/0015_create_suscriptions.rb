Sequel.migration do                                                                                           
        up do                                                                                                       
          create_table(:suscriptions) do                                                                                   
            primary_key :id                                                                                         
            foreign_key :idUser, null: false
            foreign_key :idCat, null: false                                                                       
          end                                                                                                       
        end                                                                                                         
        down do                                                                                                     
          drop_table(:suscriptions)                                                                                        
        end                                                                                                         
      end