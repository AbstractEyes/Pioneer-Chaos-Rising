class Battle_Map_Action
  attr_accessor :type       # # attack, skill, item, guard
  attr_accessor :direction  # # If space, direction used.

  attr_accessor :host       # # The host character
  attr_accessor :battler    # # The host battler
  attr_reader   :target    # # The target characters
  attr_reader   :offset

  attr_reader   :path_started
  attr_reader   :path_failed

  def initialize(type='attack', host=nil)
    @host = host
    @battler = host.battler
    @target = @battler.shape_manager.target
    @type = type
    @offset = @battler.shape_manager.offset
  end

  def clear
    battler.action.clear
    @target = nil
    @type = ""
    @host = nil
    @offset = 1
  end

  def in_range?
    #p "Testing Range: " + (host.x - target.x).abs.to_s + " " + (host.y - target.y).abs.to_s
    #p "offset: " + offset.to_s
    return (host.x - target.x).abs <= offset && (host.y - target.y).abs <= offset
  end

  def valid
    return true #!blocked?# && !pathing? #&& battler.movable? && !battler.dead?
  end

  def blocked?
    return host.move_failed
  end

  def path_to
    host.offset_force_path(target.x,target.y, offset)
  end

  def possible?
    return false if blocked?
    return false if @battler.dead?
    return !blocked? && !@battler.dead?
  end

  def path_started?
    return @host.move_route_forcing
  end

  def path_required?
    return false if in_range?
    return !path_started?
  end

  def get_shape_targets
    return @battler.shape_manager.get_shape_targets
  end

  def get_positions
    return @battler.shape_manager.positions
  end

  def sequence
    return $data_skills[@battler.action.skill_id].sequence
  end


end

