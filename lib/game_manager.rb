class GameManager
  DIRECTIONS = {
    'n' => 'north',
    's' => 'south',
    'e' => 'east',
    'w' => 'west'
  }
  COMMANDS = ['exit', 'pick', DIRECTIONS.keys].flatten
  REST_TURN = 4

  def initialize
    reset_game
    init_rooms
    randomly_place_player
    randomly_place_grue

    puts 'Welcome to BasicQuest'
    begin_input_loop
  end

  private

    def begin_input_loop
      while @playing
        if time_to_rest?
          puts "You are resting, the Grue moves"
          grue_hunts
        else
          puts "You are in the #{@current_room.to_s} room, what now? (#{COMMANDS.join(', ')})"
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

    def get_room_by_name(name)
      @rooms.each do |room|
        return room if room.name == name
      end
    end

    def grue_hunts
      move_grue(@grue_room.shortest_direction_to_room(@current_room))
    end

    def init_rooms
      room_config = YAML.load_file(Rails.root.join('config', 'room_config.yml'))

      @rooms = room_config["rooms"].map do |config|
        ::Room.new(config.first, config[1])
      end

      #create map for best route to each room
      calculator = Calculator.new(@rooms)
      calculator.generate_room_map
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

    def move_grue(direction)
      next_grue_room = @grue_room.door_destination(direction)

      @grue_room.move_from
      @grue_room = get_room_by_name(next_grue_room)
      @grue_room.move_grue_to

      if @grue_room == @current_room
        puts "You're dead! The Grue ate you"
        @current_room.move_from
        reset_game
        randomly_place_player
      end
    end

    def randomly_place_grue
      #TODO change from random to 'far away'
      @grue_room = @rooms[Random.rand(@rooms.length)]
      @grue_room.move_grue_to
    end

    def randomly_place_player
      @current_room = @rooms[Random.rand(@rooms.length)]
      @current_room.move_to
    end

    def process_command(input)
      if input == 'exit'
        @playing = false
        return
      elsif input == 'pick'
        if @current_room.has_gem?
          @gem_count += 1
          @current_room.pick_up_gem
          puts "You now have #{@gem_count} gem(s)"
        else
          puts "You fumble around and find a bit of lint"
        end
      else
        @current_room = move(input)
        @current_room.move_to

        if @current_room.has_grue?
          move_grue(@grue_room.random_valid_direction)
        end
      end
    end

    def reset_game
      @gem_count = 0
      @moves = 1
      @playing = true
    end

    def time_to_rest?
      @moves > 0 && (@moves % REST_TURN == 0)
    end

    def translate_to_cardinal(abbreviation)
      DIRECTIONS[abbreviation]
    end

end