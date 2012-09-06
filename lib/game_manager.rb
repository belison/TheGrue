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
    reset_game
    init_rooms
    randomly_place_player
    randomly_place_grue
  end

  def begin_input_loop
    puts 'Welcome to BasicQuest'

    while @playing
      puts "\n\n"

      if time_to_rest?
        puts "You are resting, the Grue moves"
        grue_hunts
      else
        puts @current_room.print_events if @current_room.has_events?
        puts "You are in the #{@current_room.to_s} room, what now? (#{COMMANDS.join(', ')})"
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

    def check_winning_condition
      if player_wins?
        puts "*** You won! ***"
        reset_game
        randomly_place_player
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

    def move(direction)
      destination = @current_room.door_destination(direction)

      if destination
        new_room = get_room_by_name(destination)
        @current_room.move_from

        new_room.move_to
        @current_room = new_room

        if @current_room.has_grue?
          @gem_count += 1
          puts "You found a gem! You now have #{@gem_count} gem(s)"
          move_grue(@grue_room.random_valid_direction)
        end

        check_winning_condition
      else
        puts 'The door was locked'
      end
    end

    ##
    # TODO it is possible that the grue would flee back to the same room
    # Ochre for example and then eat the player
    def move_grue(direction)
      next_grue_room = @grue_room.door_destination(direction)

      @grue_room.move_grue_from
      @grue_room = get_room_by_name(next_grue_room)
      @grue_room.move_grue_to

      if @grue_room == @current_room
        puts "You're dead! The Grue ate you"
        @current_room.move_from
        reset_game
        randomly_place_player
      end
    end

    def player_wins?
      @gem_count >= 5 && @current_room.has_portal?
    end

    def process_command(input)
      if input == 'exit'
        @playing = false
        return
      else
        cardinal = translate_to_cardinal(input)
        move(cardinal)
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

    def reset_game
      @gem_count = 0
      @moves = 1
      @playing = true
    end

    def time_to_rest?
      @moves % REST_TURN == 0
    end

    def translate_to_cardinal(abbreviation)
      DIRECTIONS[abbreviation]
    end

end