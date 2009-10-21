
module StopOrdering
  extend self

  def merge2(a, b)
    if a.detect {|e| b.index(e) && (b.index(e) < a.index(e))}
      a | b
    else
      b | a
    end
  end

  def merge(a, b)
    a = a.dup
    b = b.dup
    merged = []
    x_hold = []
    y_hold = []
    while x = x_hold.shift || a.shift
      y = y_hold.shift || b.shift
      if x.nil?
        merged << y
      elsif y.nil?
        merged << x
      elsif x == y
        merged << x
      elsif a.index(y) # a contains y , just wait
        merged << x
      elsif b.index(x) # b contains x, just wait
        merged << y
        x_hold << x
      else
        merged << x 
        y_hold << y
      end
    end
    merged = (merged + y_hold) + b
    merged
  end

end
