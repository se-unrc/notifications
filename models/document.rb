class Documents < Sequel::Model
	plugin :validation_helpers
  def validate
    super
    validates_presence [:name, :date, :uploader]
  end
  many_to_many :user
  set_primary_key :id
end
