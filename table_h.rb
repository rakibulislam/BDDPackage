class Table_H
  attr_accessor :h

  def initialize
    @h = Hash.new
  end

  def member?(triple)
    key = build_key(triple)
    h.keys.include? key
  end

  def lookup(triple)
    key = build_key(triple)
    h[key]
  end

  def insert(triple, u)
    key = build_key(triple)
    h[key] = u
  end

  def build_key(triple)
    "i: #{triple.i}, l: #{triple.l}, h: #{triple.h}"
  end
end
