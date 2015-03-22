class Table_T
  attr_accessor :t

  def initialize
    @t = Hash.new
    t[0] = nil
    t[1] = nil
  end

  def add(triple)
    u = t.size + 1
    t[u] = triple
    u
  end
end
