require File.expand_path '../../test_helper.rb', __FILE__

class UserTest < MiniTest::Unit::TestCase

  MiniTest::Unit::TestCase   

  def test_name_presence

    @cat = Category.new

    @cat.name = nil

    assert_equal @cat.valid?, false

    @cat.name = "COVID-19"

    assert_equal @cat.valid?, true

  end
end
