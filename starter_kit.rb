class StarterKit
  attr_accessor :on_set, :dc_set, :number_of_inputs, :number_of_cubes, :cubes, :file_name

  def initialize(file_name)
    @on_set = []
    @dc_set = []
    @cubes = []
    @number_of_inputs = 0
    @number_of_cubes = 0
    @file_name = file_name
  end

  # read eblif file and parse it to build the cubes, ON_SET and DC_SET
  def read_eblif
    begin
      f = File.open("./test_nodes/#{file_name}")
    rescue Exception => e
      puts "\n#{file_name} Not found!"
      puts "\nPlease Enter a Valid File Name!".colorize(:red)
      puts
      exit
    end

    puts "\nProcessing #{file_name} . . . ".colorize(:green)

    f.each do |line|
      if line.start_with? '.names'
        @number_of_inputs = line.split(' ').size - 2
        next
      end
      cube = line.split(' ')[0]
      output = line.split(' ')[1]

      if output == '1'
        on_set << cube
      elsif output == 'd' || output == 'x'
        dc_set << cube
      end
    end
    # a function is a set of cubes
    @cubes = on_set + dc_set
    @number_of_cubes = cubes.size
  end

  def cube_cost(cube)
    cost = 0
    (0...cube.length).each do |index|
      cost += 1 unless cube[index] == 'x' || cube[index] == 'd'
    end
    cost += 1 if cost > 1
  end

  # cover_cost will be same as function_cost as it takes a set of cubes and returns the total cost of cubes
  def function_cost(cubes)
    cost = 0
    (0...cubes.length).each do |index|
      cost += cube_cost(cubes[index])
    end
    # function.length = num_of_cubes in the function
    cost += cubes.length + 1 if cubes.length > 1
  end
end
