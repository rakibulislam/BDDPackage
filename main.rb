require 'colorize'
require './starter_kit'
require './triple'
require './table_t'
require './table_h'
require './robdd'

if ARGV[0]
  # give file name as a command line argument
  file_name = "#{ARGV[0].strip}.eblif"
else
  # read file based on command line input
  #print "\nEnter a digit for file name (1 for node1) or enter file name: ".colorize(:blue)
  #file_number = gets.chomp
  file_number = 'node9' # changes for debugging only

  if file_number =~ /^\d+$/
    file_name = "node#{file_number}.eblif"
  else
    file_name = "#{file_number}.eblif"
  end
end

starter_kit = StarterKit.new(file_name)
# read eblif file and set the instance variables after parsing the eblif file
starter_kit.read_eblif
puts 'ON SET: '
puts starter_kit.on_set
puts "\nDC SET: "
puts starter_kit.dc_set

triple = Triple.new(4, 1, 0) # (i, l, h)
triple_2 = Triple.new(4, 0, 1)

puts "Testing Shannon's expansion"
puts "Minterms:"
puts starter_kit.on_set
puts "Number of variables:"
puts starter_kit.number_of_inputs

robdd = ROBDD.new

# puts "Setting x1 = 0 : "
# func_result0 = robdd.function_set_var_val(starter_kit.on_set,1, 0, starter_kit.number_of_inputs)
# puts func_result0
#
# puts "Setting x1 = 1 :"
# func_result1 = robdd.function_set_var_val(starter_kit.on_set,1, 1, starter_kit.number_of_inputs)
# puts func_result1
#
# puts "Setting x2 = 0, result00 :"
# func_result00 = robdd.function_set_var_val(func_result0.clone,2, 0, starter_kit.number_of_inputs)
# puts func_result00

puts "\nBefore making any node ..."
puts "table_t: #{robdd.t.t}"
puts "table_h: #{robdd.h.h}"
puts "lookup : #{robdd.h.lookup(triple).inspect}"
puts "member? : #{robdd.h.member?(triple)}"
puts "lookup : #{robdd.h.lookup(triple_2).inspect}"
puts "member? : #{robdd.h.member?(triple_2)}"

# puts "\nTesting Make method ..."
#
# puts "make(#{triple.str}) ...."
# robdd.make(triple)
# puts "table_t: #{robdd.t.t}"
# puts "table_h: #{robdd.h.h}"
# puts "lookup : #{robdd.h.lookup(triple).inspect}"
# puts "member? : #{robdd.h.member?(triple)}"
# puts "lookup : #{robdd.h.lookup(triple_2).inspect}"
# puts "member? : #{robdd.h.member?(triple_2)}"
#
# puts "make(#{triple_2.str}) ...."
# robdd.make(triple_2)
# puts "table_t: #{robdd.t.t}"
# puts "table_h: #{robdd.h.h}"
# puts "lookup : #{robdd.h.lookup(triple).inspect}"
# puts "member? : #{robdd.h.member?(triple)}"
# puts "lookup : #{robdd.h.lookup(triple_2).inspect}"
# puts "member? : #{robdd.h.member?(triple_2)}"

puts "Creating the ROBDD:"
robdd.build_func(starter_kit.on_set,1,starter_kit.number_of_inputs)
puts "table_t: #{robdd.t.t}"
puts "table_h: #{robdd.h.h}"

