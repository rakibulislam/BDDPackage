class ROBDD
  attr_accessor :t, :h,  :var_order, :orig_func, :number_of_inputs

  def initialize(num_of_vars)
    @t = Table_T.new
    @h = Table_H.new
    @number_of_inputs = num_of_vars

    # dynamic var_order is needed for sifting
    @var_order = []
    set_initial_var_order(num_of_vars)
  end

  def set_initial_var_order(num_of_vars)
    (1..num_of_vars).each do |i|
      var_order << i
    end
  end

  #added to avoid refactoring initializer
  def set_orig_func(func)
    @orig_func = func
  end

  def find_nodes_with_var(var_num)
    nodes_with_var = Hash.new
    # should be replaced by hash iteration
    (t.t).each do |k, val|
      if k < 2  #terminal nodes, so they can't be parents of any other node
        next
      end
      if(t.t[k].i == var_num)
        nodes_with_var[k] = t.t[k]
      end
    end

    return nodes_with_var
  end

  def find_parent_nodes(node_num)
    parent_nodes = Hash.new

    (t.t).each do |k, val|
      if k < 2  #terminal nodes, so they can't be parents of any other node
        next
      end

      if t.t[k].l == node_num || t.t[k].h == node_num
        parent_nodes[k] = t.t[k]
      end
    end
    return parent_nodes
  end

  def remove_redundant_node(node_num)
    node = t.t[node_num]

     if node.l != node.h   # node isn't redundant in this case
       return
     end

    # case when node is redundant, i.e node.l == node.h
    parent_nodes = find_parent_nodes(node_num)

    parent_nodes.each do |k, val|
      if parent_nodes[k].l == node_num
        parent_nodes[k].l = node.l
      end
      # the parent node itself could be redundant, so both it's high and low branches have to be checked
      if parent_nodes[k].h == node_num
        parent_nodes[k].h = node.h
      end
    end

    # parent's children have been properly set, so the node can be deleted
    t.delete_node(node_num)
  end

  def does_node_exist(i,l,h)
    triple = Triple.new(i,l,h)
    return h.member?(triple)
  end

  def get_new_node_num(i,l,h)
    node = Triple.new(i,l,h)
    if  h.member?(triple)
      return h.lookup(triple)
    else
      u = t.add(triple)
      h.insert(triple, u)
    end
  end

  def add_redundant_node(parent_node_num, child_node_num, var_num_in_node)
    new_node_num = t.add(Triple.new(var_num_in_node,child_node_num,child_node_num))
    #new_node_num = get_new_node_num(var_num_in_node,child_node_num,child_node_num)
    parent_node = t.get_node(parent_node_num)

    if parent_node.l == child_node_num
      parent_node.l = new_node_num
    end

    if parent_node.h == child_node_num
      parent_node.h = new_node_num
    end
  end

  def get_size()
    return t.t.size
  end

  def swap_vars_robdd(upper_level_var, lower_level_var)
    swap_vars_in_var_order(upper_level_var, lower_level_var)
    self.t = Table_T.new
    self.h = Table_H.new

    build_func(orig_func, 1, number_of_inputs)
    # debug
    #puts "Printing from swap var robdd:"
    puts "current var order: ".colorize(:blue)
    puts var_order.inspect
    puts "current robdd table size: ".colorize(:green)
    puts t.t.size()
    #puts t.pretty_t
  end

  def swap_vars(upper_level_var, lower_level_var)
    all_upper_nodes = find_nodes_with_var(upper_level_var)
    all_lower_nodes = find_nodes_with_var(lower_level_var)

    all_upper_nodes.each do |upper_node_num,upper_node|

      low_child_node = t.get_node(upper_node.l)
      high_child_node = t.get_node(upper_node.h)

      if upper_node.l < 2 # terminal nodes, 0 or 1
        add_redundant_node(upper_node_num,upper_node.l,lower_level_var)
      elsif low_child_node.i != lower_level_var
        add_redundant_node(upper_node_num,upper_node.l,lower_level_var)
      end

      if upper_node.h < 2 # terminal nodes, 0 or 1
        add_redundant_node(upper_node_num,upper_node.h,lower_level_var)
      elsif high_child_node.i != lower_level_var
        add_redundant_node(upper_node_num,upper_node.h,lower_level_var)
      end
    end

    all_lower_nodes.each do |lower_node_num,lower_node|
      parent_nodes = find_parent_nodes(lower_node_num)
      parent_nodes.each do |parent_node_num, parent_node|
        if parent_node.i != upper_level_var
          add_redundant_node(parent_node_num,lower_node_num,upper_level_var)
        end
      end
    end

    # updating node list, since it might have changed
    all_upper_nodes = find_nodes_with_var(upper_level_var)
    all_upper_nodes.each do |upper_node_num, upper_node|
      # all the v's are node numbers
      v1 = upper_node.h
      v0 = upper_node.l

      v11 = t.get_node(v1).h
      v10 = t.get_node(v1).l

      v01 = t.get_node(v0).h
      v00 = t.get_node(v0).l

      #doing the actual swap
      t.set_node_value(v1, upper_level_var,v11,v01)
      t.set_node_value(v0, upper_level_var,v10,v00)

      t.set_node_value(upper_node_num, lower_level_var,v1,v0)
    end

    # the two vars would be swapped at this point
    # need to remove redundant nodes

    all_lower_nodes = find_nodes_with_var(lower_level_var)
    all_upper_nodes = find_nodes_with_var(upper_level_var)

    all_lower_nodes.each do |node_num, node|
      remove_redundant_node(node_num)
    end

    all_upper_nodes.each do |node_num, node|
      remove_redundant_node(node_num)
    end

    #Table t should have a ROBDD at this point
    swap_vars_in_var_order(upper_level_var, lower_level_var)
  end

  def swap_vars_in_var_order(upper_level_var, lower_level_var)
    # updating the var_order
    upper_var_index = var_order.index(upper_level_var)
    lower_var_index = var_order.index(lower_level_var)

    var_order[upper_var_index] = lower_level_var
    var_order[lower_var_index] = upper_level_var
  end

  def minterm_set_var_val(minterm, i, var_val)
    # minterm is a string representing the minterm, eg 11x for x1x2 in a 3 var case
    # i is 1 based index
    # var_val is 0 or 1 (i.e binary)
    # var_num is 1 based
    var_num = var_order[i-1]

    if(minterm[var_num-1] == 'x') # variable is absent in minterm
      return minterm
    elsif(minterm[var_num-1] == var_val.to_s) 
      minterm[var_num-1] = 'x' # the variable would disappear in this case
    else
      minterm = '0'      
    end
    return minterm
  end
  
  def function_set_var_val(func, var_num, var_val, total_num_of_vars)
    # func is an array of strings representing the sum of minterms, eg 11x + x01
    # var_num is 1 based
    # var_val is 0 or 1 (i.e binary)
    # func = _func.clone
    minterm_equals_1 = 'x' * total_num_of_vars
    func_result = []
    
    (0...func.length).each do |i|
      minterm_result = minterm_set_var_val(func[i], var_num, var_val)
      
      if(minterm_result == minterm_equals_1)
        return ['1'] # the whole function value is 1 if any minterm is 1
      elsif (minterm_result == '0')
        # a zero minterm is redundant, so no need to add it to the function's result
      else
        func_result << minterm_result
      end
    end
    
    if func_result.length == 0  # all the minterms returned as zero
      return ['0']
    else
      return func_result
    end    
  end

  def make(triple)
    if triple.l == triple.h
      return triple.l
    elsif h.member?(triple)
      return h.lookup(triple)
    else
      u = t.add(triple)
      h.insert(triple, u)
      return u
    end
  end

  def build_func(func, i, num_of_vars)
    #func = _func.clone
    # cases when the end nodes (i.e 0 or 1) is reached
    if func.length == 1
      if func[0] == '0'
        return 0
      elsif func[0] == '1'
        return 1
      end
    end

    if i > num_of_vars
      if func.length == 1 && func[0] == '0'
        return 0
      else
        return 1
      end
    else
      v0 = build_func(function_set_var_val(Marshal.load(Marshal.dump(func)), i, 0, num_of_vars), i+1, num_of_vars)
      v1 = build_func(function_set_var_val(Marshal.load(Marshal.dump(func)), i, 1, num_of_vars), i+1, num_of_vars)
      return make(Triple.new(i, v0, v1))
    end
  end

  def apply(op, u1, u2, t1, t2)
    puts "APP(#{u1}, #{u2})"

    if t1[u1].is_a?(::Hash)
      var_u1 = t1[u1][:i]
    else
      var_u1 = t1[u1].i
    end

    low_u1 = t1[u1].l if u1 > 1
    high_u1 = t1[u1].h if u1 > 1

    if t2[u2].is_a?(::Hash)
      var_u2 = t2[u2][:i]
    else
      var_u2 = t2[u2].i
    end

    low_u2 = t2[u2].l if u2 > 1
    high_u2 = t2[u2].h if u2 > 1

    g = {}
    key = build_key_for_g(u1, u2)

    if g[key]
      g[key]
    elsif ([0, 1].include? u1) && ([0, 1].include? u2)
      if op == 'and'
        u = _and(u1, u2)
      elsif op == 'or'
        u = _or(u1, u2)
      elsif op == 'xor'
        u = _xor(u1, u2)
      end
    elsif var_u1 == var_u2
      u = make(Triple.new(var_u1, apply(op, low_u1, low_u2, t1, t2), apply(op, high_u1, high_u2, t1, t2)))
    elsif var_u1 < var_u2
      u = make(Triple.new(var_u1, apply(op, low_u1, u2, t1, t2), apply(op, high_u1, u2, t1, t2)))
    else
      u = make(Triple.new(var_u2, apply(op, u1, low_u2, t1, t2), apply(op, u1, high_u2, t1, t2)))
    end

    g[key] = u
    u
  end

  private

  def build_key_for_g(u1, u2)
    "#{u1},#{u2}"
  end

  def _and(u1, u2)
    return 0 if u1 == 0 && u2 == 0
    return 0 if u1 == 0 && u2 == 1
    return 0 if u1 == 1 && u2 == 0
    return 1 if u1 == 1 && u2 == 1
  end

  def _or(u1, u2)
    return 0 if u1 == 0 && u2 == 0
    return 1 if u1 == 0 && u2 == 1
    return 1 if u1 == 1 && u2 == 0
    return 1 if u1 == 1 && u2 == 1
  end

  def _xor(u1, u2)
    return 0 if u1 == 0 && u2 == 0
    return 1 if u1 == 0 && u2 == 1
    return 1 if u1 == 1 && u2 == 0
    return 0 if u1 == 1 && u2 == 1
  end
end
