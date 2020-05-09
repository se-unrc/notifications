class Document < Sequel::Model
	plugin :validation_helpers
    def validate
    super
        validates_presence [:date, :name, :users, :categories, :Document]
  	end
	many_to_many  :categories
end
