class User < Sequel::Model
      many_to_many  :categories
      many_to_many :documents
      plugin :validation_helpers
      def validate
        super
        validates_presence [:name, :surnames, :dni, :email, :password, :rol, :admin]
        validates_length_range 3..40, [:name, :surnames], message: 'not allowed'
        validates_integer :dni
        validates_type String, [:name, :surnames, :email, :password]
        validates_unique([:name, :surnames], :dni, :email)
        validates_operator(:>, 0, :dni)
    end
end
