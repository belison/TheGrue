class GameManager
  DIRECTIONS = {
    'n' => 'north',
    's' => 'south',
    'e' => 'east',
    'w' => 'west'
  }
  COMMANDS = ['exit', DIRECTIONS.keys].flatten
  REST_TURN = 4

  def initialize
    @moves = 1
    @playing = true

    init_rooms

    puts 'Welcome to BasicQuest'
    begin_input_loop
  end

  def begin_input_loop
    while @playing
      if time_to_rest?
        puts "You are resting, the Grue moves"
        move_grue
      else
        puts "You are in the #{@current_room.to_s} room, what now? (n,s,e,w,exit)"
        puts @current_room.print_events if @current_room.has_events?
        input = gets.chomp.downcase
        if input_invalid?(input)
          puts "Enter a valid command"
          next
        end

        process_command(input)
      end

      @moves += 1
    end
  end

  private

  def calc_best_move_to_player
    best = 100
    result = nil

    DIRECTIONS.each_value do |d|
      door = @grue_room.door_destination(d)
      if door
        route = get_room_by_name(door)
        test = room_distance(route, @current_room)
        if test < best
          best = test
          result = route
        end
      end
    end

    result
  end

  def room_distance(start, finish)
    distance = 0
    if start == finish
      return distance
    end

    DIRECTIONS.each_value do |d|
      door = start.door_destination(d)
      if door
        route = get_room_by_name(door)
        if route == finish
          distance += 1
        else
          distance += room_distance(route, finish)
        end
      end
    end

    return distance
  end

  def get_room_by_name(name)
    @rooms.each do |room|
      return room if room.name == name
    end
  end

  def init_rooms
    room_config = YAML.load_file(Rails.root.join('config', 'room_config.yml'))

    @rooms = room_config["rooms"].map do |config|
      ::Room.new(config.first, config[1])
    end

    @current_room = @rooms[Random.rand(@rooms.length-1)]
    @current_room.move_to

    #TODO change from random to 'far away'
    @grue_room = @rooms[Random.rand(@rooms.length-1)]
    @grue_room.move_grue_to
    binding.pry
  end

  def input_invalid?(input)
    return !COMMANDS.include?(input)
  end

  def move(input)
    cardinal = translate_to_cardinal(input)
    destination = @current_room.door_destination(cardinal)
    new_room = @current_room

    if destination
      new_room = get_room_by_name(destination)
      @current_room.move_from
    end

    new_room
  end

  def move_grue
    binding.pry
    next_grue_room = calc_best_move_to_player

    binding.pry
    @grue_room.move_from
    @grue_room = get_room_by_name(next_grue_room)
    @grue_room.move_grue_to
  end

  def process_command(input)
    if input == 'exit'
      @playing = false
      return
    else
      @current_room = move(input)
      @current_room.move_to
    end
  end

  def time_to_rest?
    @moves > 0 && (@moves % REST_TURN == 0)
  end

  def translate_to_cardinal(abbreviation)
    DIRECTIONS[abbreviation]
  end

end