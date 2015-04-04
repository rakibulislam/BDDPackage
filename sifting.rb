class Sifting
  attr_accessor :orig_robdd, :num_of_vars,  :current_robdd, :orig_var_order, :highest_var_pos, :lowest_robdd_size, :var_pos_for_lowest_robdd_size

  def sift(robdd, _num_of_vars)
    @orig_robdd = robdd
    @num_of_vars = _num_of_vars
    @current_robdd = get_obj_copy(robdd)
    @orig_var_order = robdd.var_order
    @highest_var_pos = num_of_vars-1
    check_robdd_size = true

    (0...orig_var_order.length).each do |k|
      current_var = orig_var_order[k]
      current_var_pos = current_robdd.var_order.index(current_var)
      #setting initial values
      @lowest_robdd_size = current_robdd.get_size()
      @var_pos_for_lowest_robdd_size = current_var_pos

      if current_var_pos == 0
        sift_down(current_var_pos,highest_var_pos,check_robdd_size)
      elsif (current_var_pos == highest_var_pos)
        sift_up(current_var_pos,0,check_robdd_size)
      elsif (current_var_pos > highest_var_pos-current_var_pos)
        sift_down(current_var_pos, highest_var_pos,check_robdd_size)
        sift_up(highest_var_pos, 0,check_robdd_size)
      else
        sift_up(current_var_pos, 0,check_robdd_size)
        sift_down(0,highest_var_pos,check_robdd_size)
      end
      sift_back(current_var)

      # debug print
      puts "sifted on var:"
      puts current_var
      puts "min robdd:"
      puts current_robdd.t.t
    end
  end

  def sift_down_one_step(current_var_pos)
    if current_var_pos == highest_var_pos
      return # the var can't move down further
    end
    current_var = current_robdd.var_order[current_var_pos]
    var_just_below = current_robdd.var_order[current_var_pos+1]
    current_robdd.swap_vars(current_var,var_just_below)
  end

  def sift_up_one_step(current_var_pos)
    if current_var_pos == 0
      return # the var can't move up further
    end
    current_var = current_robdd.var_order[current_var_pos]
    var_just_above = current_robdd.var_order[current_var_pos-1]
    current_robdd.swap_vars(var_just_above,current_var)
  end

  def set_lowest_robdd_size(current_var_pos)
    new_robdd_size = current_robdd.get_size()
    if new_robdd_size <= lowest_robdd_size
      var_pos_for_lowest_robdd_size = current_var_pos
      lowest_robdd_size = new_robdd_size
    end
  end

  def sift_down(current_pos,new_pos,check_robdd_size)
    (current_pos...new_pos).each do |k|
      sift_down_one_step(k)
      if(check_robdd_size)
        set_lowest_robdd_size(k)
      end
    end
  end

  def sift_up(current_pos,new_pos,check_robdd_size)
    (current_pos...new_pos).each do |k|
      sift_up_one_step(k)
      if(check_robdd_size)
        set_lowest_robdd_size(k)
      end
    end
  end

  def sift_back(current_var)
    current_var_pos = current_robdd.var_order.index(current_var)
    check_robdd_size = false

    if current_var_pos == var_pos_for_lowest_robdd_size
      return # the robdd is already at its lowest size
    elsif current_var_pos < var_pos_for_lowest_robdd_size
      sift_down(current_var_pos,var_pos_for_lowest_robdd_size,check_robdd_size)
    else # i.e case when current_var_pos > var_pos_for_lowest_robdd_size
      sift_up(current_var_pos,var_pos_for_lowest_robdd_size,check_robdd_size)
    end
  end

  def get_obj_copy(ob)
    return Marshal.load(Marshal.dump(ob))
  end
end
