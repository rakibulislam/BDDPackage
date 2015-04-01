class ROBDD
  attr_accessor :t, :h,  :var_order

  def initialize(num_of_vars)
    @t = Table_T.new
    @h = Table_H.new

    # dynamic var_order is needed for sifting
    @var_order = []
    set_initial_var_order(num_of_vars)
  end

  def set_initial_var_order(num_of_vars)
    (1..num_of_vars).each do |i|
      var_order << i
    end
  end

  def find_nodes_with_var(var_num)
    nodes_with_var = Hash.new

    (2...t.t.size).each do |k|
      if(t.t[k].i == var_num)
        nodes_with_var[k] = t.t[k]
      end
    end

    return nodes_with_var

  end

  def find_parent_nodes(node_num)
    parent_nodes = Hash.new

    (2...t.t.size).each do |k|
      if t.t[k].l == node_num || t.t[k].h == node_num
        parent_nodes[k] = t.t[k]
      end
    end

    return parent_nodes

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
    #func = _func.clone
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

  def build_key_for_g(u1, u2)
    "#{u1},#{u2}"
  end

  def op(u1, u2)
    return 0 if u1 == 0 && u2 == 0
  end
end
