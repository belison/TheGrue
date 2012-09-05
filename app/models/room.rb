class Room

  attr_accessor :name, :map

  def initialize(name, config)
    @config = config
    @events = []
    @map = {}
    @name = name
    @portal = config["teleport"] ? true : false

    @has_gem = false
    @has_grue = false
    @has_player = false
  end

  def door_destination(direction)
    @config[direction]
  end

  def has_events?
    !@events.empty?
  end

  def has_exit?
    @portal
  end

  def move_from
    @has_player = false
  end

  def move_grue_from
    @has_grue = false
  end

  def move_grue_to
    if (@has_player)
      @events.push("You're dead! The Grue ate you")
    end

    @has_grue = true
  end

  def move_to
    if (@has_player)
      @events.push('The door was locked')
    elsif (@has_grue)
      @events.push('There is a gem on the floor')
      @has_gem = true
    end

    @has_player = true
  end

  def print_events
    @events.each do |e|
      puts e
    end

    @events = []
  end

  def shortest_direction_to_room(room)
    @map[room.name][:direction]
  end

  def to_s
    @name.gsub(/_/, ' ').capitalize
  end

  def valid_move_direction?(direction)
    !@config[direction].blank?
  end
end