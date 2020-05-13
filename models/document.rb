class Documents < Sequel::Model
	plugin :validation_helpers
  def validate
    super
    validates_presence [:name, :date, :uploader]
  end
end
