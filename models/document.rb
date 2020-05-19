class Document < Sequel::Model
    many_to_one :categories
    many_to_many :users
  end
