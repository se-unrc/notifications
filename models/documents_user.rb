class Documents_user < Sequel::Model
	plugin :validation_helpers
  def validate
    super
    validates_presence [:document_id, :user_id ]
  end
  def index
     @tagged = Documents_user.all
  end
  many_to_one :user
  many_to_one :document
  set_primary_key :id
end
