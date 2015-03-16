class Table_H
  attr_accessor :u, :triple, :h

  def initialize(u, triple)
    @h = Hash.new
    @u = u
    @triple = triple
  end

  def member?(triple)
    h.keys.include? triple
  end

  def lookup(triple)
    h[triple]
  end

  def insert(triple, u)
    h[triple] = u
  end
end
