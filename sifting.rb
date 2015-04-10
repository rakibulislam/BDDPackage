class Sifting
  attr_accessor :orig_robdd, :num_of_vars,  :current_robdd, :orig_var_order, :highest_var_pos, :lowest_robdd_size, :var_pos_for_lowest_robdd_size

  def sift(robdd, _num_of_vars)
    @orig_robdd = get_obj_copy(robdd)
    @num_of_vars = _num_of_vars
    @current_robdd = robdd
    @orig_var_order = self.orig_robdd.var_order
    @highest_var_pos = self.num_of_vars-1
    check_robdd_size = true

    puts "Started Sifting..."

    (0...self.orig_var_order.length).each do |k|
      current_var = self.orig_var_order[k]
      current_var_pos = self.current_robdd.var_order.index(current_var)
      #setting initial values
      @lowest_robdd_size = self.current_robdd.get_size()
      @var_pos_for_lowest_robdd_size = current_var_pos

      if current_var_pos == 0
        sift_down(current_var_pos,self.highest_var_pos,check_robdd_size)
      elsif (current_var_pos == self.highest_var_pos)
        sift_up(current_var_pos,0,check_robdd_size)
      elsif (current_var_pos > self.highest_var_pos-current_var_pos)
        sift_down(current_var_pos, self.highest_var_pos,check_robdd_size)
        sift_up(self.highest_var_pos, 0,check_robdd_size)
      else
        sift_up(current_var_pos, 0,check_robdd_size)
        sift_down(0,self.highest_var_pos,check_robdd_size)
      end
      sift_back(current_var)

      # debug print
      puts "sifted on var:".colorize(:green)
      puts current_var
      puts "current var order: ".colorize(:blue)
      puts self.current_robdd.var_order.inspect
      puts "robdd size for this var order: ".colorize(:green)
      puts self.current_robdd.t.t.size()
      #puts self.current_robdd.t.pretty_t
    end

    return self.current_robdd
  end

  def sift_down_one_step(current_var_pos)
    if current_var_pos == self.highest_var_pos
      return # the var can't move down further
    end
    current_var = self.current_robdd.var_order[current_var_pos]
    var_just_below = self.current_robdd.var_order[current_var_pos+1]
    # self.current_robdd.swap_vars(current_var,var_just_below)
    self.current_robdd.swap_vars_robdd(current_var,var_just_below)
  end

  def sift_up_one_step(current_var_pos)
    if current_var_pos == 0
      return # the var can't move up further
    end
    current_var = self.current_robdd.var_order[current_var_pos]
    var_just_above = self.current_robdd.var_order[current_var_pos-1]
    # self.current_robdd.swap_vars(var_just_above,current_var)
    self.current_robdd.swap_vars_robdd(var_just_above,current_var)
  end

  def set_lowest_robdd_size(current_var_pos)
    new_robdd_size = self.current_robdd.get_size()
    if new_robdd_size <= self.lowest_robdd_size
      self.var_pos_for_lowest_robdd_size = current_var_pos
      self.lowest_robdd_size = new_robdd_size
    end
  end

  def sift_down(current_pos,new_pos,check_robdd_size)
    k = current_pos
    while k < new_pos
    # (current_pos...new_pos).each do |k|
     #for k in current_pos...new_pos
      sift_down_one_step(k)
      if(check_robdd_size)
        set_lowest_robdd_size(k+1)
      end

      k = k + 1
    end
  end

  def sift_up(current_pos,new_pos,check_robdd_size)
    k = current_pos
    while k > new_pos
    # (current_pos...new_pos).each do |k|
    #for k in current_pos...new_pos
      sift_up_one_step(k)
      if(check_robdd_size)
        set_lowest_robdd_size(k-1)
      end

      k = k - 1
    end
  end

  def sift_back(current_var)
    current_var_pos = self.current_robdd.var_order.index(current_var)
    check_robdd_size = false

    if current_var_pos == self.var_pos_for_lowest_robdd_size
      return # the robdd is already at its lowest size
    elsif current_var_pos < self.var_pos_for_lowest_robdd_size
      sift_down(current_var_pos,self.var_pos_for_lowest_robdd_size,check_robdd_size)
    else # i.e case when current_var_pos > self.var_pos_for_lowest_robdd_size
      sift_up(current_var_pos,self.var_pos_for_lowest_robdd_size,check_robdd_size)
    end
  end

  def get_obj_copy(ob)
    return Marshal.load(Marshal.dump(ob))
  end
end
