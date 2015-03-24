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
  
  def function_set_var_val(_func,var_num, var_val, total_num_of_vars)
    # func is an array of strings representing the sum of minterms, eg 11x + x01
    # var_num is 1 based
    # var_val is 0 or 1 (i.e binary)
    func = _func.clone
    minterm_equals_1 = 'x' * total_num_of_vars
    func_result = []
    
    (0...func.length).each do |i|
      minterm_result = minterm_set_var_val(func[i],var_num,var_val)
      
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

  def build_func(_func, i, num_of_vars)
    func = _func.clone
    if i > num_of_vars
      if func.length == 1 && func[0] == '0'
        return 0
      else
        return 1
      end
    else
      v0 = build_func(function_set_var_val(func.clone, i,0,num_of_vars),i+1,num_of_vars)
      v1 = build_func(function_set_var_val(func.clone, i,1,num_of_vars),i+1,num_of_vars)

      triple = Triple.new(i,v0,v1)

      return make(triple)
    end

  end

end

# Test Area
#
# r = ROBDD.new
# min = 'x01'
# retVal = r.minterm_set_var_val(min, 2, 0)
# puts retVal
