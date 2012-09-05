class Room

  attr_accessor :name

  def initialize(name, config)
    @events = []
    @name = name
    @portal = config["teleport"] ? true : false
    @config = config
    @has_player = false
    @has_grue = false
    @has_gem = false
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

  def to_s
    @name.gsub(/_/, ' ').capitalize
  end
end