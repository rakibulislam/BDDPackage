class Table_T
  attr_accessor :u, :triple, :t

  def initialize(u, triple)
    @t = Hash.new
    t[0] = nil
    t[1] = nil
    @u = u
    @triple = triple
  end

  def add(u, triple)
    t[u] = triple
  end
end
