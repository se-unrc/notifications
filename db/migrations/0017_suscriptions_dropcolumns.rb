Sequel.migration do                                                                                           
        down do                                                                                                       
          alter_table(:suscriptions) do                                                                                   
            drop_coulmn :idUser
            drop_coulmn :idCat                                                                                                                                                             
          end                                                                                                       
        end
end                                                                                                         
