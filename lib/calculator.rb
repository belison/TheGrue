class Calculator
  DIRECTIONS = {
    'n' => 'north',
    's' => 'south',
    'e' => 'east',
    'w' => 'west'
  }

  def initialize(rooms)
    @rooms = rooms
  end

  def generate_room_map
    @rooms.each do |room|
      @rooms.each do |destination|
        next if destination == room
        room.map[destination.name] = shortest_direction_to_room(room, destination)
      end
    end
  end

  private

    ##
    # TODO make this more efficient
    # If a room has already found its shortest path to another
    # could look it up in the existing map rather than running again
    #
    def room_by_name(name)
      @rooms.each do |room|
        return room if room.name == name
      end
    end

    def room_distance(start, finish)
      if @visited.include?(start)
        return nil
      end

      @visited.push(start)

      distance = 0
      if start == finish
        return distance
      end

      best = 100
      DIRECTIONS.each_value do |d|
        if start.valid_move_direction?(d)
          route = room_by_name(start.door_destination(d))
          if route == finish
            return 1
          else
            test = room_distance(route, finish)
            test = test.nil? ? nil : 1 + test

            if test && test < best
              best = test
            end
          end
        end
      end

      return best
    end

    ##
    # TODO dry up the duplication in the recursive method with this one
    #
    def shortest_direction_to_room(start, finish)
      best = 100
      result = nil

      DIRECTIONS.each_value do |d|
        @visited = [start]
        if start.valid_move_direction?(d)
          route = room_by_name(start.door_destination(d))
          distance = room_distance(route, finish)
          if distance && distance < best
            best = distance
            result = d
          end
        end
      end

      {:direction => result, :distance => best}
    end

end