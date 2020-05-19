class User < Sequel::Model
      many_to_many  :categories
      many_to_many :documents
    end
