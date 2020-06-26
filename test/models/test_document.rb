require File.expand_path '../../test_helper.rb', __FILE__
require "minitest/autorun"

class DocumentTest < Minitest::Unit::TestCase
	MiniTest::Unit::TestCase

	def test_document_existence
		# Arrange
		@document = Document.new
		# Act
		@document.name = nil
		# Assert
		assert_equal @document.valid?, false
	end

	def test_create_document
  		user  = User.new(name: "testUser",email: "test@test.com", username: "test",password: "123456")
  		assert_equal user.valid?, true
	end
end