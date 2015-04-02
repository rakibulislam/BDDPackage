class ROBDD
  attr_accessor :t, :h

  def initialize
    @t = Table_T.new
    @h = Table_H.new
  end
  
  def minterm_set_var_val(minterm, var_num, var_val)
    # minterm is a string representing the minterm, eg 11x for x1x2 in a 3 var case
    # var_num is 1 based
    # var_val is 0 or 1 (i.e binary)
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

    var_u1 = t1[u1][:i]
    low_u1 = t1[u1][:l] if u1 > 1
    high_u1 = t1[u1][:h] if u1 > 1
    var_u2 = t2[u2][:i]
    low_u2 = t2[u2][:l] if u2 > 1
    high_u2 = t2[u2][:h] if u2 > 1

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
