class Game_Character
  attr_accessor :shove_frames
  attr_accessor :max_shove_frames

  def shove_command(commands, host, target)
    self.shove_frames = 0
    self.max_shove_frames = 0
    self.shoved = true
    $scene.spriteset.update if $scene.is_a?(Scene_Map)
    for cmi in 0...commands.size
      command = commands[cmi]
      case command[0]
        when :relative
          self.max_shove_frames += command[2] * 12
          prepare_relative(command, host)
        when :absolute
          self.max_shove_frames += command[2] * 12
          prepare_absolute(command, host)
        when :away_host
          self.max_shove_frames += command[2] * 12
          prepare_away_target(command, host)
        when :away_target
          self.max_shove_frames += command[2] * 12
          prepare_away_target(command, target)
        when :to_host
          self.max_shove_frames += 12 * [distance_x_from_target(host).abs, distance_y_from_target(host).abs].max
          prepare_to_target(command, host)
        when :to_target
          self.max_shove_frames += 12 * [distance_x_from_target(target).abs, distance_y_from_target(target).abs].max
          prepare_to_target(command, target)
        when :toward_host
          self.max_shove_frames += command[2] * 12
          prepare_toward_target(command, host)
        when :toward_target
          self.max_shove_frames += command[2] * 12
          prepare_toward_target(command, target)
      end
    end
  end

  def prepare_relative(command, target)
    arry = [8, 9, 6, 3, 2, 1, 4, 7]
    #input_1 = target.direction   facing_direction
    #input_2 = command[1]         relative_direction
    #p 'battler name: ' + user.battler.name.to_s
    #p 'host name: ' + self.battler.name.to_s
    #p 'raw_command: ' + command.inspect
    #p 'input direction: ' + user.direction.to_s
    #p 'completed_direction: ' + arry.rotate(arry.index(user.direction))[arry.index(command[1])].to_s
    shove_direction(command[2], arry.rotate(arry.index(target.direction))[arry.index(command[1])])
  end

  def prepare_absolute(command, target)
    shove_direction(command[2], command[1])
  end

  def prepare_away_target(command, target)
    shove_direction(command[2], get_direction(self.x - target.x, self.y - target.y))
  end

  def prepare_to_target(command, target)
    shove_to_nearby_character(command, target)
  end

  def prepare_toward_target(command, target)
    shove_direction(command[2], get_direction(self.x - target.x, self.y - target.y))
  end

  def face_target(target)
    sx, sy = distance_x_from_target(target), distance_y_from_target(target)
    if sx.abs > sy.abs
      sx > 0 ? turn_left : turn_right
    elsif sx.abs < sy.abs
      sy > 0 ? turn_up : turn_down
    elsif sx.abs == sy.abs
      if sx > 0 and sy > 0
        set_direction(7)
      elsif sx < 0 and sy > 0
        set_direction(9)
      elsif sx > 0 and sy < 0
        set_direction(1)
      elsif sx < 0 and sy < 0
        set_direction(3)
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Calculate X Distance From Player
  #--------------------------------------------------------------------------
  def distance_x_from_target(target)
    sx = self.x - target.x
    if $game_map.loop_horizontal?         # When looping horizontally
      if sx.abs > $game_map.width / 2     # Larger than half the map width?
        sx -= $game_map.width             # Subtract map width
      end
    end
    return sx
  end
  #--------------------------------------------------------------------------
  # * Calculate Y Distance From Player
  #--------------------------------------------------------------------------
  def distance_y_from_target(target)
    sy = self.y - target.y
    if $game_map.loop_vertical?           # When looping vertically
      if sy.abs > $game_map.height / 2    # Larger than half the map height?
        sy -= $game_map.height            # Subtract map height
      end
    end
    return sy
  end

  def get_nearest_position(target)
    return Coord.new(self.x, self.y) if target == self
    # Get base direction
    direction = convert_direction_xy(get_direction(self.x - target.x, self.y - target.y))
    #Base direction not passable, find another.
    unless passable?(target.x + direction.x, target.y + direction.y)
      arry = [8, 9, 6, 3, 2, 1, 4, 7]
      for degree in 0...4
        dir1 = convert_direction_xy(arry.rotate(arry.index(target.direction))[degree])
        if passable?(target.x + dir1.x, target.y + dir1.y)
          direction = dir1
          break
        end
        dir2 = convert_direction_xy(arry.rotate(arry.index(target.direction))[arry.size-degree])
        if passable?(target.x + dir2.x, target.y + dir2.y)
          direction = dir2
          break
        end
      end
    end
    return Coord.new(target.x + direction.x, target.y + direction.y)
  end

  def get_direction(x, y)
    #Todo: Add min/max for direction.
    if x < 0 && y < 0
      #up left
      return 7
    elsif x < 0 && y > 0
      #down left
      return 1
    elsif x > 0 && y > 0
      #downright
      return 3
    elsif x > 0 && y < 0
      #up right
      return 9
    elsif x < 0 && y == 0
      # left
      return 4
    elsif x > 0 && y == 0
      # right
      return 6
    elsif x == 0 && y > 0
      # down
      return 2
    elsif x == 0 && y < 0
      # up
      return 8
    else
      return 5
    end
  end

  def convert_direction_xy(direction)
    case direction
      when 1
        ox, oy = -1, 1
      when 2
        ox, oy = 0, 1
      when 3
        ox, oy = 1, 1
      when 4
        ox, oy = -1, 0
      when 6
        ox, oy = 1, 0
      when 7
        ox, oy = -1, -1
      when 8
        ox, oy = 0, -1
      when 9
        ox, oy = 1, -1
      else
        ox, oy = 0, 0
    end
    return Coord.new(ox,oy)
  end

  def shove_direction(spaces, direction)
    dir = convert_direction_xy(direction)
    ox, oy = dir.x, dir.y
    ax, ay = self.x, self.y
    for i in 1..spaces
      if passable?(self.x + ox * i, self.y + oy * i)
        ax, ay = self.x + ox * i, self.y + oy * i
      else
        break
      end
    end
    #p 'x, y: ' + self.x.to_s + ' ' + self.y.to_s
    #p 'dirx, diry: ' + ax.to_s + ' ' + ay.to_s
    shoveto(ax, ay)
  end

  def shove_to_nearby_character(command, nearby_target)
    xy = get_nearest_position(nearby_target)
    shoveto(xy.x, xy.y)
  end

end