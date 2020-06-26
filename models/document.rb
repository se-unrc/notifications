class Document < Sequel::Model
	plugin :validation_helpers
  def validate
    super
    validates_presence [:name, :date, :uploader, :subject]
  end
  def index
     @documents = Document.all
  end
  one_to_many :users
  set_primary_key :id
end
