# frozen_string_literal: true

require File.expand_path '../test_helper.rb', __dir__

# Class that contains the Category model's tests
class UserTest < MiniTest::Unit::TestCase
  MiniTest::Unit::TestCase

  def test_name_presence
    @cat = Category.new

    @cat.name = nil

    assert_equal @cat.valid?, false

    @cat.name = 'COVID-19'

    assert_equal @cat.valid?, true
  end
end
