# frozen_string_literal: true

require File.expand_path '../test_helper.rb', __dir__

# Class that contains the User model's tests
class UserTest < MiniTest::Unit::TestCase
  MiniTest::Unit::TestCase
  def test_name_presence
    @user = User.new

    @user.name = nil
    @user.username = 'john'
    @user.email = 'johndo@email.com'
    @user.password = '12345'

    assert_equal @user.valid?, false

    @user.name = 'John Doe'

    assert_equal @user.valid?, true
  end

  def test_username_presence
    @user = User.new

    @user.name = 'John Doe'
    @user.username = nil
    @user.email = 'johndo@email.com'
    @user.password = '12345'

    assert_equal @user.valid?, false

    @user.username = 'john'

    assert_equal @user.valid?, true
  end

  def test_email_presence
    @user = User.new
    @user.name = 'John Doe'
    @user.username = 'john'
    @user.email = nil
    @user.password = '12345'

    assert_equal @user.valid?, false

    @user.email = 'johndoe@mail.com'

    assert_equal @user.valid?, true
  end

  def test_password_presence
    @user = User.new
    @user.name = 'John Doe'
    @user.username = 'john'
    @user.email = 'johndoe@mail.com'
    @user.password = nil

    assert_equal @user.valid?, false

    @user.password = '12345'

    assert_equal @user.valid?, true
  end

  def test_email_format
    @user = User.new
    @user.name = 'John Doe'
    @user.username = 'john'
    @user.email = 'johndoemailcom'
    @user.password = '12345'

    assert_equal @user.valid?, false

    @user.email = 'johndoe@email.com'

    assert_equal @user.valid?, true
  end

  def test_username_format
    @user = User.new
    @user.name = 'John Doe'
    @user.username = 'john,doe'
    @user.email = 'johndo@email.com'
    @user.password = '12345'

    assert_equal @user.valid?, false

    @user.username = 'john doe'

    assert_equal @user.valid?, false

    @user.username = 'jo'

    assert_equal @user.valid?, false

    @user.username = 'johndoe'

    assert_equal @user.valid?, true
  end

  def test_password_length
    @user = User.new
    @user.name = 'John Doe'
    @user.username = 'john'
    @user.email = 'johndo@email.com'
    @user.password = '123'

    assert_equal @user.valid?, false

    @user.password = '012345678901234567890'

    assert_equal @user.valid?, false

    @user.password = '0123456789'

    assert_equal @user.valid?, true
  end

  # #TODO: Add uniqueness constraint in database in order to test for that property

  # def test_username_uniqueness

  #   @user1 = User.new
  #   @user1.name = "john doe"
  #   @user1.username = "jay"
  #   @user1.email = "johndoe@mail.com"
  #   @user1.password = "123"

  #   @user2 = User.new
  #   @user2.name = "jane doe"
  #   @user2.username = "jay"
  #   @user2.email = "janedoe@mail.com"
  #   @user2.password = "123"

  #   assert_equal @user2.valid?, false

  # end

  # def test_email_uniqueness

  #   @user3 = User.new
  #   @user4 = User.new

  #   @user3.email = "johndoe@mail.com"
  #   @user4.email = "johndoe@mail.com"

  #   assert_equal @user4.valid?, false

  # end
end
