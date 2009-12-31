require 'test/unit'
require '../lib/beautify2'

class Beautify2Test < Test::Unit::TestCase
  # def setup
  # end

  # def teardown
  # end

  def test_js_beautify
    src = IO.read('controls.js')
    expected = IO.read('controls.formatted.js')
    result = Beautifier.new.js_beautify(src)
    assert_equal(expected, result)
  end
end