require 'colorize'
require './starter_kit'

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
puts starter_kit.on_set
puts starter_kit.dc_set
