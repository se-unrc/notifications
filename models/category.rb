class Category < Sequel::Model 
	plugin :validation_helpers
    def validate
    super
		validates_presence [:name]
		validates_unique [:name]
  	end
	many_to_many  :users
	one_to_many :documents
	set_primary_key :id
end
