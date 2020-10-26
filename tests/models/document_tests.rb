# frozen_string_literal: true

require File.expand_path '../test_helper.rb', __dir__

# Class that contains the Document model's tests
class UserTest < MiniTest::Unit::TestCase
  MiniTest::Unit::TestCase

  def test_name_presence
    @doc = Document.new

    @doc.name = nil
    @doc.date = '2020-05-10'
    @doc.userstaged = 'john,jane'
    @doc.categorytaged = 'Scolarships'
    @doc.document = 'doc.pdf'

    assert_equal @doc.valid?, false

    @doc.name = "Nigerian Prince's Will"

    assert_equal @doc.valid?, true
  end

  def test_date_presence
    @doc = Document.new

    @doc.name = "Nigerian Prince's Will"
    @doc.date = nil
    @doc.userstaged = 'john,jane'
    @doc.categorytaged = 'Scolarships'
    @doc.document = 'doc.pdf'

    assert_equal @doc.valid?, false

    @doc.date = '2020-04-19'

    assert_equal @doc.valid?, true
  end

  def test_category_presence
    @doc = Document.new

    @doc.name = 'Wire Transfer Receipt'
    @doc.date = '2020-05-10'
    @doc.userstaged = 'princeofnigeria,me'
    @doc.categorytaged = nil
    @doc.document = 'doc.pdf'

    assert_equal @doc.valid?, false

    @doc.categorytaged = 'Scams'

    assert_equal @doc.valid?, true
  end

  def test_document_presence
    @doc = Document.new

    @doc.name = 'Whatever'
    @doc.date = '2020-05-10'
    @doc.userstaged = 'john,jane'
    @doc.categorytaged = 'Scolarships'
    @doc.document = nil

    assert_equal @doc.valid?, false

    @doc.document = 'something.pdf'

    assert_equal @doc.valid?, true
  end
end
