require 'colorize'
require './starter_kit'
require './triple'
require './table_t'
require './table_h'
require './robdd'
require 'pp'

if ARGV[0]
  # give file name as a command line argument
  file_name = "#{ARGV[0].strip}.eblif"
else
  # read file based on command line input
  print "\nEnter a digit for file name (1 for node1) or enter file name: "
  file_number = gets.chomp
  #file_number = 'node9' # changes for debugging only

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

robdd = ROBDD.new(starter_kit.number_of_inputs)

puts 'Creating the ROBDD . . .'
robdd.build_func(starter_kit.on_set, 1, starter_kit.number_of_inputs)
puts 'table_t: '
pp(robdd.t.t)
puts
puts 'table_h: '
pp(robdd.h.h)

puts 'Finding nodes with var 3:'
puts robdd.find_nodes_with_var(3).inspect

puts 'Finding parents for node 2:'
puts robdd.find_parent_nodes(2).inspect

