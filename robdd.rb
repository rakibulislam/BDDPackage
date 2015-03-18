class ROBDD
  
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
  
  def function_set_var_val(func,var_num, var_val, total_num_of_vars)
    # func is an array of strings representing the sum of minterms, eg 11x + x01
    # var_num is 1 based
    # var_val is 0 or 1 (i.e binary)
    
    minterm_equals_1 = 'x' * total_num_of_vars
    
    func_result = []
    
    (0...func.length).each do |i|
      minterm_result = minterm_set_var_val(func[i],var_num,var_val)
      
      if(minterm_result == minterm_equals_1)
        return '1' # the whole function value is 1 if any minterm is 1
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
  
  
end

# Test Area
#
# r = ROBDD.new
# min = 'x01'
# retVal = r.minterm_set_var_val(min, 2, 0)
# 
# puts retVal


