class Table_T
  attr_accessor :t

  def initialize
    @t = Hash.new
    t[0] = nil
    t[1] = nil
  end

  def add(triple)
    u = t.size
    t[u] = triple
    u
  end

  def build_value(triple)
    { i: triple.i, l: triple.l, h: triple.h }
  end

  def pretty_t
    h = {}
    h[0] = nil
    h[1] = nil

    t.each do |key, val|
      next if key < 2
      temp = {}
      temp[:i] = val.i
      temp[:l] = val.l
      temp[:h] = val.h
      h[key] = temp
    end
    h
  end
end
