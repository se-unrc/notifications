class User < Sequel::Model
    many_to_many  :categories
    many_to_many :documents
    one_to_many :relations
      plugin :validation_helpers
      def validate
        super
        validates_presence [:name, :surname, :dni, :email, :password, :rol, :admin]
        validates_length_range 3..40, [:name, :surname], message: 'not allowed'
        validates_integer :dni
        validates_type String, [:name, :surname, :email, :password]
        validates_unique([:name, :surname, :dni], :email)
        validates_operator(:>, 0, :dni)
    end
end
