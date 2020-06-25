Sequel.migration do                                                                                           
    up do 
    	alter_table :documents  do
    		set_column_allow_null :userstaged 
    	end                                                                                                       
    end
end