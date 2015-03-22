class Table_H
  attr_accessor :h

  def initialize
    @h = Hash.new
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
