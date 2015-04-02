class Table_T
  attr_accessor :t

  def initialize
    @t = Hash.new
    t[0] = nil
    t[1] = nil
  end

  def add(triple)
    u = t.size
    t[u] = build_value(triple)
    u
  end

  def build_value(triple)
    { i: triple.i, l: triple.l, h: triple.h }
  end
end
