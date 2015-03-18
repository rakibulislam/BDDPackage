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
  print "\nEnter a digit for file name (1 for node1) or enter file name: ".colorize(:blue)
  file_number = gets.chomp

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
u = 2
table_h = Table_H.new(u, triple)
table_h.insert(triple, u)

puts "\nTable_H methods testing..."
puts "\nH: #{table_h.h}"
puts "lookup : #{table_h.lookup(triple).inspect}"
puts "member? : #{table_h.member?(triple)}"
puts "lookup : #{table_h.lookup(triple_2).inspect}"
puts "member? : #{table_h.member?(triple_2)}"

u = 3
table_h.insert(triple_2, u)
puts '- - - - - - - - '
puts "\nH: #{table_h.h}"
puts "lookup : #{table_h.lookup(triple).inspect}"
puts "member? : #{table_h.member?(triple)}"
puts "lookup : #{table_h.lookup(triple_2).inspect}"
puts "member? : #{table_h.member?(triple_2)}"

puts "\nTable_T methods testing..."
table_t = Table_T.new(u, triple)
puts "\nT: #{table_t.t}"
table_t.add(u, triple)
puts "\nT: #{table_t.t}"

puts "Testing Shannon's expansion"
puts "Minterms:"
puts starter_kit.on_set
puts "Number of variables:"
puts starter_kit.number_of_inputs

robdd = ROBDD.new

puts "Setting x1 = 0 :"

func_result0 = robdd.function_set_var_val(starter_kit.on_set,1, 0, starter_kit.number_of_inputs)

puts func_result0

puts "Setting x1 = 1 :"

func_result1 = robdd.function_set_var_val(starter_kit.on_set,1, 1, starter_kit.number_of_inputs)

puts func_result1

puts "Setting x2 = 0, result00 :"

func_result00 = robdd.function_set_var_val(func_result0.clone,2, 0, starter_kit.number_of_inputs)

puts func_result00




