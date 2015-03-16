require './algo'

algo = Algo.new

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
initial_cover = starter_kit.on_set
puts "\nGenerating Prime Implicants . . . ".colorize(:green)
puts
pi_list = PrimeImplicant.generate_final_prime_implicants(starter_kit.on_set, starter_kit.dc_set)
puts "\nInitial Cover: #{initial_cover.inspect}".colorize(:green)
puts "Prime Implicants: #{pi_list.inspect}".colorize(:blue)

categorized_pi_list =  PrimeImplicant.calculate_essential_pi_list(pi_list, starter_kit.dc_set)
essential_pi_list = categorized_pi_list[0]
non_essential_pi_list = categorized_pi_list[1]

puts "Essential PI List: #{essential_pi_list}".colorize(:blue)
puts "Non-essential PI List: #{non_essential_pi_list}".colorize(:blue)

puts "\nChecking if the essential prime implicants fully cover the function . . . ".colorize(:green)
minterm_coverage_list = algo.get_minterm_function_coverage(initial_cover, essential_pi_list, false)

minterms_fully_covered = minterm_coverage_list[0]
minterms_not_fully_covered = minterm_coverage_list[1]

puts "\nMinterms fully covered: #{minterms_fully_covered.inspect}".colorize(:green)
puts "\nMinterms not fully covered: #{minterms_not_fully_covered.inspect}".colorize(:green)

if (minterms_not_fully_covered.length == 0)  # all the minterms in the initial cover are covered by the essential PIs
  puts "\nEssential PIs fully cover the function ! So, the Essential PI List would be the minimum cost cover.".colorize(:blue)
  puts "However, the program would continue finding other possible covers (which won't be the minimum cost cover(s) )...".colorize(:blue)
else
  puts "\nEssential PIs don't fully cover the function. So, need to include non-essential PIs for full cover."
end

cover_list = algo.find_all_covers(initial_cover, essential_pi_list, non_essential_pi_list)

puts "\nNumber of potential covers: #{cover_list.length}".colorize(:blue)
algo.find_minimum_cost_cover(cover_list, file_name)
