Sequel.migration do                                                                                           
        up do                                                                                                       
          alter_table(:suscriptions) do                                                                                   
            drop_column :idUser
            drop_column :idCat                                                                                                                                                             
          end                                                                                                       
        end
        up do
          alter_table(:suscriptions) do
           add_foreign_key(:user_id, :users)
           add_foreign_key(:cat_id, :categories)
          end
        end
end                                                                                                         
