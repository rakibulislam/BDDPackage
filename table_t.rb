class Table_T
  attr_accessor :t

  def initialize
    @t = Hash.new
    t[0] = nil
    t[1] = nil
    @node_counter = 2 #first two nodes are 0 and 1 nodes
  end

  def add(triple)
    #u = t.size
    u = @node_counter
    @node_counter = @node_counter + 1
    #t[u] = build_value(triple)
    t[u] = triple
    u
  end

  def delete_node(node_num)
    t.delete(node_num)
  end

  def get_node(node_num)
    return t[node_num]
  end

  def set_node_value(node_num, i,h,l)
    triple = t[node_num]
    triple.i = i
    triple.l = l
    triple.h = h
  end

  def build_value(triple)
    "i: #{triple.i}, l: #{triple.l}, h: #{triple.h}"
  end
end
