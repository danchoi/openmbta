require 'test_helper'

# We need to aggregate stops when there are several trips under a headsign that
# have slightly different stop lists.

class StopOrderingTest < ActiveSupport::TestCase

  def test_overlap1
    a = %w{ a b c d }
    b = %w{ c d e }
    assert_equal %w{ a b c d e }, StopOrdering.merge(a, b)
  end

  def test_overlapping_2
    a = %w{ c d e }
    b = %w{ a b c d }
    assert_equal %w{ a b c d e }, StopOrdering.merge(a, b)
  end

  def test_overlapping_3
    a = %w{ c d e }
    b = %w{ a b c d }
    assert_equal %w{ a b c d e }, StopOrdering.merge(a, b)
  end

  def test_overlap_4
    a = %w{ a b c e f }
    b = %w{ c d e f}
    assert_equal %w{ a b c d e f}, StopOrdering.merge(a, b)
  end
end
