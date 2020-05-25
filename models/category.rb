class Category < Sequel::Model
    many_to_many  :users
  	one_to_many :documents
    plugin :validation_helpers
    def validate
      super
      validates_presence [:name, :description]
      validates_length_range 3..30, :name
      validates_length_range 5..80, :description
      validates_type String, [:name, :description]
      validates_unique([:name, :description])
    end
  end
