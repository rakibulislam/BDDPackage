require 'colorize'
require './starter_kit'
require './triple'
require './table_t'
require './table_h'
require './robdd'
require './sifting'
require 'pp'
require 'benchmark'

class Main
  def apply(file_1, file_2)
    starter_kit = StarterKit.new(file_1)
    # read eblif file and set the instance variables after parsing the eblif file
    starter_kit.read_eblif
    robdd_1 = ROBDD.new(starter_kit.number_of_inputs)
    robdd_1.build_func(starter_kit.on_set, 1, starter_kit.number_of_inputs)
    t1 = robdd_1.t.t
    u1 = t1.keys[-1]
    num_inputs_1 = starter_kit.number_of_inputs
    puts "ROBDD for #{file_1}: ".colorize(:blue)
    pp(robdd_1.t.pretty_t)

    starter_kit = StarterKit.new(file_2)
    starter_kit.read_eblif
    robdd_2 = ROBDD.new(starter_kit.number_of_inputs)
    robdd_2.build_func(starter_kit.on_set, 1, starter_kit.number_of_inputs)
    t2 = robdd_2.t.t
    u2 = t2.keys[-1]
    num_inputs_2 = starter_kit.number_of_inputs
    puts "ROBDD for #{file_2}: ".colorize(:blue)
    pp(robdd_2.t.pretty_t)

    terminal_node_var_num = [num_inputs_1, num_inputs_2].max + 1

    t1[0] = { i: terminal_node_var_num, l: nil, h: nil }
    t1[1] = { i: terminal_node_var_num, l: nil, h: nil }
    t2[0] = { i: terminal_node_var_num, l: nil, h: nil }
    t2[1] = { i: terminal_node_var_num, l: nil, h: nil }

    final_robdd = ROBDD.new(starter_kit.number_of_inputs)

    time = Benchmark.realtime do
      final_robdd = ROBDD.new(starter_kit.number_of_inputs)
      final_robdd.apply('and', u1, u2, t1, t2)
      puts "\nFinal ROBDD after AND operation: ".colorize(:green)
      pp(final_robdd.t.pretty_t)
    end

    puts "\nTime elapsed in AND operation: #{time*1000} milliseconds".colorize(:blue)

    file_name = "apply_#{file_1.gsub('.eblif', '')}_and_#{file_2.gsub('.eblif', '')}"

    dot_file_path = './bdd_graphs/apply_graphs/'+ file_name + '.dot'
    ps_file_path = './bdd_graphs/apply_graphs/'+ file_name + '.ps'

    dot_fmt = final_robdd.t.get_dot_format
    File.write(dot_file_path, dot_fmt)

    `dot -Tps #{dot_file_path} -o #{ps_file_path}`
    puts "\nApply (AND operation) Graph generated. Please go to this path: #{ps_file_path} to see the graph!".colorize(:blue)
    `open #{ps_file_path}`

    time = Benchmark.realtime do
      final_robdd = ROBDD.new(starter_kit.number_of_inputs)
      final_robdd.apply('or', u1, u2, t1, t2)
      puts "\nFinal ROBDD after OR operation: ".colorize(:green)
      pp(final_robdd.t.pretty_t)
    end

    puts "\nTime elapsed in OR operation: #{time*1000} milliseconds".colorize(:blue)

    file_name = "apply_#{file_1.gsub('.eblif', '')}_or_#{file_2.gsub('.eblif', '')}"

    dot_file_path = './bdd_graphs/apply_graphs/'+ file_name + '.dot'
    ps_file_path = './bdd_graphs/apply_graphs/'+ file_name + '.ps'

    dot_fmt = final_robdd.t.get_dot_format
    File.write(dot_file_path, dot_fmt)

    `dot -Tps #{dot_file_path} -o #{ps_file_path}`
    puts "\nApply (OR operation) Graph generated. Please go to this path: #{ps_file_path} to see the graph!".colorize(:blue)
    `open #{ps_file_path}`

    time = Benchmark.realtime do
      final_robdd = ROBDD.new(starter_kit.number_of_inputs)
      final_robdd.apply('xor', u1, u2, t1, t2)
      puts "\nFinal ROBDD after XOR operation: ".colorize(:green)
      pp(final_robdd.t.pretty_t)
    end

    puts "\nTime elapsed in XOR operation: #{time*1000} milliseconds".colorize(:blue)

    file_name = "apply_#{file_1.gsub('.eblif', '')}_xor_#{file_2.gsub('.eblif', '')}"

    dot_file_path = './bdd_graphs/apply_graphs/'+ file_name + '.dot'
    ps_file_path = './bdd_graphs/apply_graphs/'+ file_name + '.ps'

    dot_fmt = final_robdd.t.get_dot_format
    File.write(dot_file_path, dot_fmt)

    `dot -Tps #{dot_file_path} -o #{ps_file_path}`
    puts "\nApply (XOR operation) Graph generated. Please go to this path: #{ps_file_path} to see the graph!".colorize(:blue)
    `open #{ps_file_path}`
    puts
  end

  def apply_one_param(input)
    # give file names as a command line argument comma separated
    file_names = input.strip.split(',')
    file_1 = "#{file_names[0]}.eblif"
    file_2 = "#{file_names[1]}.eblif"

    apply(file_1, file_2)
  end

  def robdd(_filename)
    filename = "#{_filename}.eblif"

    starter_kit = StarterKit.new(filename)
    # read eblif file and set the instance variables after parsing the eblif file
    starter_kit.read_eblif

    robdd = ROBDD.new(starter_kit.number_of_inputs)
    robdd.set_orig_func(starter_kit.on_set)

    puts 'Creating the ROBDD . . .'
    robdd.build_func(starter_kit.on_set, 1, starter_kit.number_of_inputs)

    puts "variable order:"
    puts robdd.var_order.inspect
    puts 'ROBDD: '
    pp (robdd.t.pretty_t)

    dot_fmt = robdd.t.get_dot_format
    dot_file_path = './bdd_graphs/robdd_graphs/'+_filename + '.dot'
    ps_file_path = './bdd_graphs/robdd_graphs/'+_filename + '.ps'
    File.write(dot_file_path, dot_fmt)

    `dot -Tps #{dot_file_path} -o #{ps_file_path}`
    puts "\nROBDD Graph generated. Please go to this path: #{ps_file_path} to see the graph!".colorize(:blue)
    `open #{ps_file_path}`
    puts
  end

  def sifting(_filename)
    filename = "#{_filename}.eblif"
    starter_kit = StarterKit.new(filename)
    # read eblif file and set the instance variables after parsing the eblif file
    starter_kit.read_eblif

    robdd = ROBDD.new(starter_kit.number_of_inputs)
    robdd.set_orig_func(starter_kit.on_set)

    puts 'Creating the ROBDD . . .'
    robdd.build_func(starter_kit.on_set, 1, starter_kit.number_of_inputs)

    puts "original var order:"
    puts robdd.var_order.inspect
    puts 'original table_t: '
    pp(robdd.t.pretty_t)

    time = Benchmark.realtime do
      sifting = Sifting.new
      robdd = sifting.sift(robdd, starter_kit.number_of_inputs)
    end

    puts 'final var order: '
    puts robdd.var_order.inspect
    puts "\ntable_t after sifting: ".colorize(:blue)
    pp(robdd.t.pretty_t)
    puts "\nTime elapsed in Sifting operation: #{time*1000} milliseconds".colorize(:blue)
    puts

    dot_file_path = './bdd_graphs/sifting_graphs/'+_filename + '.dot'
    ps_file_path = './bdd_graphs/sifting_graphs/'+_filename + '.ps'

    dot_fmt = robdd.t.get_dot_format
    File.write(dot_file_path, dot_fmt)

    `dot -Tps #{dot_file_path} -o #{ps_file_path}`
    puts "\nSifting Graph generated. Please go to this path: #{ps_file_path} to see the graph!".colorize(:blue)
    `open #{ps_file_path}`
    puts
  end
end

if ARGV.length == 2
  cmd = ARGV[0].downcase
  main = Main.new

  case  cmd
    when 'robdd'
      main.robdd(ARGV[1])
    when 'apply'
      main.apply_one_param(ARGV[1])
    when 'sifting'
      main.sifting(ARGV[1])
  end
else
  print "\nPlease enter the function you would like to perform (e.g robdd or sifting or apply):"

  cmd = gets.chomp.downcase
  main = Main.new

  case  cmd
    when 'robdd'
      print "\nEnter a digit for file name (type 1 for node1): "
      file_number = gets.chomp
      file_name = "node#{file_number}"
      main.robdd(file_name)
    when 'apply'
      # read file based on command line input
      print "\nEnter 2 digits for file names (1,2): "
      file_names = gets.chomp.strip.split(',')
      file_1 = "node#{file_names[0]}.eblif"
      file_2 = "node#{file_names[1]}.eblif"
      main.apply(file_1,file_2)
    when 'sifting'
      print "\nEnter a digit for file name (type 1 for node1): "
      file_number = gets.chomp
      file_name = "node#{file_number}"
      main.sifting(file_name)
  end
end
