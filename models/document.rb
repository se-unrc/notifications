class Document < Sequel::Model
	plugin :validation_helpers
    def validate
    super
        validates_presence [:date, :name, :userstaged, :categorytaged, :document]
  	end
	many_to_one  :categories
	many_to_many  :users
	set_primary_key :id
end
