class Shape_Array < Array

  def include?(coord)
    return false unless coord.is_a?(Coord)
    for ar in self
      return true if ar.x == coord.x && ar.y == coord.y
    end
    return false
  end

end

module PHI
  module SHAPES

  end
end

class Shape_Manager
  # @shape_obj = weapon/unarmed/skill/item shape object.
  #   size_length is the length of the attack.
  #   size_width is the width of the attack, adding one per point on each side.
  #   offset is the amount of spaces the character has between it and its weapon attack.
  #   damage is the damage type, physical/magic/agility
  #   startup is the adjusted weapon attack time startup
  #   cooldown is the adjusted weapon attack time cooldown

  attr_accessor :shape_obj
  attr_reader   :positions
  attr_accessor :character
  attr_accessor :host
  attr_accessor :target
  attr_reader   :offset

  def initialize(host)
    @host = host
  end

  def width
    return @skill.size[0]
  end

  def length
    return @skill.size[1]
  end

  def get_character
    if @host.is_a?(Game_Actor)
      @character = $game_party.players[@host.id]
    else
      @character = $game_troop.get_character(@host)
    end
  end

  def clear
    get_character
    @positions = Shape_Array.new if @positions.nil?
    @positions.clear
    @direction = 5
    @target = nil
    @skill = nil
  end

  # ------------------------------------------------------------------------------------------------------- #
  # prepare_attack_template #
  # ----------------------- #
  # @character
  #   The host character, used as the position from, and the graphic for the window.
  # @character_target
  #   The target character, used as a direction reference, and for the direction of the graphic.
  # ------------------------------------------------------------------------------------------------------- #
  #Todo: complete prepare shape.
  def prepare(target, skill)
    clear
    return if target.nil? or (target.is_a?(Array) && target.size == 0)
    @target = target unless target.is_a?(Array)
    @target = target[0] if target.is_a?(Array)
    @skill = skill
    @direction = get_relative_direction
    create_shape
  end

  def refresh
    prepare(@target, @skill)
  end

  def get_shape
    refresh
    return @positions
  end

  def chop_positions
    new_positions = @positions.clone
    for i in 0...new_positions.size
      pos = new_positions[i]
      if pos.x > @target.x - 10 && pos.x < @target.x + 10 &&
          pos.y > @target.y - 7 && pos.y < @target.y + 7
        next
      else
        new_positions[i] = nil
      end
    end
    return new_positions.compact
  end

  def in_range?
    return (@target.x - @character.x).abs <= @skill.offset && (@target.y - @character.y).abs <= @skill.offset
  end

  def test_in_range?(xy)
    return (xy.x - @character.x).abs <= @skill.offset && (xy.y - @character.y).abs <= @skill.offset
  end

  def create_shape
    #Todo: Fix direction checker.
    case @skill.shape
      when 0
        create_rect_shape
      when 1
        create_ellipse_shape
      when 2
        create_cone_shape
      when 3
        create_cross_shape
      when 4
        create_line_to_target
      when nil

    end
  end
  # ------------------------------------------------------------------------------------------------------------------ #
  def create_rect_shape
    case @direction
      when 1
        #set_down_left
        set_left_right_rect
      when 2
        set_up_down_rect
      when 3
        #set_down_right
        set_left_right_rect
      when 4
        set_left_right_rect
      when 5
        set_left_right_rect
      when 6
        set_left_right_rect
      when 7
        #set_up_left
        set_up_down_rect
      when 8
        set_up_down_rect
      when 9
        set_up_down_rect
      #set_up_right
    end
  end
  def set_up_down_rect
    x, y = @target.x, @target.y
    for w in 0...width
      for l in 0...length
        prepare_pos x-w, y+l
        prepare_pos x+w, y+l
        prepare_pos x-w, y-l
        prepare_pos x+w, y-l
      end
    end
  end
  def set_left_right_rect
    x, y = @target.x, @target.y
    for w in 0...width
      for l in 0...length
        prepare_pos x+l, y-w
        prepare_pos x+l, y+w
        prepare_pos x-l, y-w
        prepare_pos x-l, y+w
      end
    end
  end
  # ------------------------------------------------------------------------------------------------------------------ #
  def create_ellipse_shape
    #Todo: create shape
    case @direction
      when 1
        #set_down_left
        set_ellipse(Ellipse.new(@target.x, @target.y, width, length))
      when 2
        set_ellipse(Ellipse.new(@target.x, @target.y, width, length))
      when 3
        #set_down_right
        set_ellipse(Ellipse.new(@target.x, @target.y, length, width))
      when 4
        set_ellipse(Ellipse.new(@target.x, @target.y, length, width))
      when 5
        set_ellipse(Ellipse.new(@target.x, @target.y, length, width))
      when 6
        set_ellipse(Ellipse.new(@target.x, @target.y, length, width))
      when 7
        #set_up_left
        set_ellipse(Ellipse.new(@target.x, @target.y, width, length))
      when 8
        set_ellipse(Ellipse.new(@target.x, @target.y, width, length))
      when 9
        set_ellipse(Ellipse.new(@target.x, @target.y, width, length))
      #set_up_right
    end
  end

  def set_ellipse(pixel)
    radius = pixel.a
    prepare_pos(pixel.x, pixel.y + radius)
    prepare_pos(pixel.x, pixel.y - radius)
    prepare_pos(pixel.x + radius, pixel.y)
    prepare_pos(pixel.x - radius, pixel.y)
    f = 1 - radius
    dd_f_x = 1
    dd_f_y = -2 * radius
    x = 0
    y = radius
    while x < y
      if f >= 0
        y -= 1
        dd_f_y += 2
        f += dd_f_y
      end
      x += 1
      dd_f_x += 2
      f += dd_f_x
      prepare_pos(pixel.x + x, pixel.y + y)
      prepare_pos(pixel.x + x, pixel.y - y)
      prepare_pos(pixel.x - x, pixel.y + y)
      prepare_pos(pixel.x - x, pixel.y - y)
      prepare_pos(pixel.x + y, pixel.y + x)
      prepare_pos(pixel.x + y, pixel.y - x)
      prepare_pos(pixel.x - y, pixel.y + x)
      prepare_pos(pixel.x - y, pixel.y - x)
    end
    fill_ellipse
    @positions.each { |pos| p 'pos x: ' + pos.x.to_s + ' pos Y ' + pos.y.to_s}
  end
  def fill_ellipse
    filler = {}
    for pos in @positions
      filler[pos.x] = Coord.new(pos.y, pos.y) unless filler.keys.include? pos.x
      filler[pos.x] = Coord.new([pos.y, filler[pos.x].x].min, [pos.y, filler[pos.x].y].max)
    end
    filler.each do |x, y|
      for y2 in y.x...y.y
        prepare_pos(x, y2)
      end
    end
  end
  # ------------------------------------------------------------------------------------------------------------------ #
  def create_cone_shape
    #Todo: create shape
  end

  # ------------------------------------------------------------------------------------------------------------------ #
  def create_cross_shape
    #Todo: create shape
  end
  # ------------------------------------------------------------------------------------------------------------------ #
  def create_line_to_target
    #Todo: create line to target
  end
  # ------------------------------------------------------------------------------------------------------------------ #

  def prepare_pos(x,y)
    @positions.push Coord.new(x,y) unless @positions.include? Coord.new(x, y)
  end

  def get_relative_direction
    return get_direction(@character.x - @target.x, @character.y - @target.y)
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

  def get_shape_targets
    everything = []
    @positions.each { |xy|
      $game_map.events_xyc(xy).each { |ev|
        everything.push(ev) unless everything.include?(ev) or ev.nil? #if !(ev.battler.nil? || ev.battler.dead?) && !everything.include?(ev)
      }
    }
    everything.push target if !everything.include?(target) && target != nil
    everything.compact!
    p 'shape targets ' + everything.size.to_s
    return everything
  end

end

=begin
  def set_down
    x, y = @xy.x, @xy.y
    for w in 0...width
      for l in 0...length
        prepare_pos x-w,  y+l+@offset
        prepare_pos x+w,  y+l+@offset
        for w2 in 1...w+1
          break if l < 1
          prepare_pos x-w-w2,  y+l+@offset
          prepare_pos x+w+w2,  y+l+@offset
        end
      end
    end
  end
  def set_up
    x, y = @xy.x, @xy.y
    for w in 0...width
      for l in 0...length
        prepare_pos x-w, y-l-@offset
        prepare_pos x+w, y-l-@offset
        for w2 in 1...w+1
          break if l < 1
          prepare_pos x-w-w2, y-l-@offset
          prepare_pos x+w+w2, y-l-@offset
        end
      end
    end
  end
  def set_right
    x, y = @xy.x, @xy.y
    for w in 0...width
      for l in 0...length
        prepare_pos x+l+@offset, y-w
        prepare_pos x+l+@offset, y+w
        for w2 in 1...w+1
          break if l < 1
          prepare_pos x+l+@offset, y-w-w2
          prepare_pos x+l+@offset, y+w+w2
        end
      end
    end
  end
  def set_left
    x, y = @xy.x, @xy.y
    for w in 0...width
      for l in 0...length
        prepare_pos x-l-@offset, y-w
        prepare_pos x-l-@offset, y+w
        for w2 in 1...w+1
          break if l < 1
          prepare_pos x-l-@offset, y-w-w2
          prepare_pos x-l-@offset, y+w+w2
        end
      end
    end
  end
  def set_up_left
    x, y = @xy.x, @xy.y
    #w2 = 0
    for w in 0...width
      for l in 0...length
        # upleft
        prepare_pos x-l-@offset, y-l-@offset
        # upleft > right
        prepare_pos x-l+w-@offset, y-l-@offset
        # upleft > down
        prepare_pos x-l-@offset, y-l+w-@offset
        for w2 in 1...w+1
          break if l < 1
          # upleft > right
          prepare_pos x-l+w+w2-@offset, y-l-@offset
          # upleft > down
          prepare_pos x-l-@offset, y-l+w+w2-@offset
        end
      end
    end
  end
  def set_up_right
    x, y = @xy.x, @xy.y
    #w2 = 0
    for w in 0...width
      for l in 0...length
        # upright
        prepare_pos x+l+@offset, y-l-@offset
        # upright > left
        prepare_pos x+l-w+@offset, y-l-@offset
        # upright > down
        prepare_pos x+l+@offset, y-l+w-@offset
        for w2 in 1...w+1
          break if l < 1
          # upright > left
          prepare_pos x+l-w-w2+@offset, y-l-@offset
          # upright > down
          prepare_pos x+l+@offset, y-l+w+w2-@offset
        end
      end
    end
  end
  def set_down_left
    x, y = @xy.x, @xy.y
    #w2 = 0
    for w in 0...width
      for l in 0...length
        # downleft
        prepare_pos x-l-@offset, y+l+@offset
        # downleft > right
        prepare_pos x-l+w-@offset, y+l+@offset
        # downleft > up
        prepare_pos x-l-@offset, y+l-w+@offset
        for w2 in 1...w+1
          break if l < 1
          # downleft > right
          prepare_pos x-l+w+w2-@offset, y+l+@offset
          # downleft > up
          prepare_pos x-l-@offset, y+l-w-w2+@offset
        end
      end
    end
  end
  def set_down_right
    x, y = @xy.x, @xy.y
    #w2 = 0
    for w in 0...width
      for l in 0...length
        # downright
        prepare_pos x+l+@offset, y+l+@offset
        # downright > left
        prepare_pos x+l-w+@offset, y+l+@offset
        # downright > up
        prepare_pos x+l+@offset, y+l-w+@offset
        for w2 in 1...w+1
          break if l < 1
          # downright > left
          prepare_pos x+l-w-w2+@offset, y+l+@offset
          # downright > up
          prepare_pos x+l+@offset, y+l-w-w2+@offset
        end
      end
    end
  end

    xy = self.to_xy(@index)
    x, y = xy[0],xy[1]
    if width == 1 && length == 1
      @positions.push [x,y+1] unless @positions.include? [x,y+1]
      return
    end
    for w in 0...width
      for l in 0...length
        n1x, n1y = x-w, y+l+1+@offset
        n2x, n2y = x+w, y+l+1+@offset
        @positions.push [n1x, n1y] unless @positions.include? [n1x, n1y]
        @positions.push [n2x, n2y] unless @positions.include? [n2x, n2y]
      end
    end

  #############################################################
  #Trident shape
    xy = self.to_xy(@index)
    x, y = xy[0],xy[1]
    #if width == 1 && length == 1
    #  prepare_pos  x+1, y
    #  return
    #end
    for w in 0...width
      for l in 0...length
        w2 = w
        if l < 2 then l2 = l else l2 = 2 end
        w2 += l2
        prepare_pos x+l+1+@offset, y-w
        prepare_pos x+l+1+@offset, y+w
        prepare_pos x+l+1+@offset, y-w2
        prepare_pos x+l+1+@offset, y+w2
      end
    end

=end

=begin
class DI8
  attr_accessor :downleft
  attr_accessor :down
  attr_accessor :downright
  attr_accessor :right
  attr_accessor :upright
  attr_accessor :up
  attr_accessor :upleft
  attr_accessor :left
  def initialize(downleft, down, downright, left, right, upleft, up, upright)
    self.set(downleft, down, downright, left, right, upleft, up, upright)
  end

  def set(downleft, down, downright, left, right, upleft, up, upright)
    @downleft = downleft
    @down = down
    @downright = downright
    @right = right
    @upright = upright
    @up = up
    @upleft = upleft
    @left = left
  end

  def to_xy(index)
    return [0,0] if index.nil?
    return [0,0] if index < 0
    return [(index % 17), (index / 17)]
  end

  def get_closest_around(index, ar = self.to_ar)
    difx, dify, difi = 100, 100, -1
    input_xy = self.to_xy(index)
    for i in 0...ar.size
      temp_xy = self.to_xy(ar[i])
      xdif_base = (input_xy[0] - temp_xy[0]).abs
      ydif_base = (input_xy[1] - temp_xy[1]).abs
      if difx > xdif_base or dify > ydif_base
        difi = i
        difx = xdif_base
        dify = ydif_base
      end
    end
    return [ar[difi], to_direction(difi+1)]
  end

  def to_direction(raw_direction)
    new_direction = raw_direction
    new_direction += 1 if raw_direction > 4
    case new_direction
      when 1
        return 9
      when 2
        return 8
      when 3
        return 7
      when 4
        return 6
      when 6
        return 4
      when 7
        return 3
      when 8
        return 2
      when 9
        return 1
    end
  end

  def to_ar
    return [@downleft, @down, @downright, @left, @right, @upleft, @up, @upright]
  end

end

class Shape_Manager
  attr_accessor :shape_object
  attr_reader   :positions

  def initialize(raw_shape_obj)
    @shape_object = raw_shape_obj
    @positions = []
    @index = -1
    @offset = 0
  end

  def width
    return 1 if @shape_object.nil?
    return @shape_object.size_width
  end

  def length
    return 1 if @shape_object.nil?
    return @shape_object.size_length
  end

  def dispose
    @positions = [] if @positions.nil?
    @positions.clear
  end

  def get_offset
    return 0 if @shape_object.nil?
    if $game_system.target_state == 0
      offset = @shape_object.offset - 1
    else
      offset = @shape_object.offset
    end
    return offset
  end

  #Todo: complete prepare shape.
  def prepare_shape(index, direction)
    dispose
    @index = index
    @offset = get_offset
    case direction
      when 1
        # down left
        set_down_left
        return @positions
      when 2
        # down
        set_down
        return @positions
      when 3
        # down right
        set_down_right
        return @positions
      when 4
        # left
        set_left
        return @positions
      when 6
        # right
        set_right
        return @positions
      when 7
        # up left
        set_up_left
        return @positions
      when 8
        # up
        set_up
        return @positions
      when 9
        # up right
        set_up_right
        return @positions
      else
        @positions.clear
        return @positions
    end
  end
=begin
    xy = self.to_xy(@index)
    x, y = xy[0],xy[1]
    if width == 1 && length == 1
      @positions.push [x,y+1] unless @positions.include? [x,y+1]
      return
    end
    for w in 0...width
      for l in 0...length
        n1x, n1y = x-w, y+l+1+@offset
        n2x, n2y = x+w, y+l+1+@offset
        @positions.push [n1x, n1y] unless @positions.include? [n1x, n1y]
        @positions.push [n2x, n2y] unless @positions.include? [n2x, n2y]
      end
    end

  #############################################################
  #Trident shape
    xy = self.to_xy(@index)
    x, y = xy[0],xy[1]
    #if width == 1 && length == 1
    #  prepare_pos  x+1, y
    #  return
    #end
    for w in 0...width
      for l in 0...length
        w2 = w
        if l < 2 then l2 = l else l2 = 2 end
        w2 += l2
        prepare_pos x+l+1+@offset, y-w
        prepare_pos x+l+1+@offset, y+w
        prepare_pos x+l+1+@offset, y-w2
        prepare_pos x+l+1+@offset, y+w2
      end
    end

def set_down
  xy = self.to_xy(@index)
  x, y = xy[0],xy[1]
  #if width == 1 && length == 1
  #  prepare_pos x,y+1
  #  return
  #end
  for w in 0...width
    for l in 0...length
      w2 = w
      w2 += l if w > 1
      prepare_pos x-w,  y+l+1+@offset
      prepare_pos x+w,  y+l+1+@offset
      prepare_pos x-w2, y+l+1+@offset
      prepare_pos x+w2, y+l+1+@offset
    end
  end
end

def set_up
  xy = self.to_xy(@index)
  x, y = xy[0],xy[1]
  #if width == 1 && length == 1
  #  prepare_pos x, y-1
  #  return
  #end
  for w in 0...width
    for l in 0...length
      w2 = w
      w2 += l if w > 1
      prepare_pos x-w, y-l-1-@offset
      prepare_pos x+w, y-l-1-@offset
      prepare_pos x-w2, y-l-1-@offset
      prepare_pos x+w2, y-l-1-@offset
    end
  end
end

def set_right
  xy = self.to_xy(@index)
  x, y = xy[0],xy[1]
  #if width == 1 && length == 1
  #  prepare_pos  x+1, y
  #  return
  #end
  for w in 0...width
    for l in 0...length
      w2 = w
      w2 += l if w > 1
      prepare_pos x+l+1+@offset, y-w
      prepare_pos x+l+1+@offset, y+w
      prepare_pos x+l+1+@offset, y-w2
      prepare_pos x+l+1+@offset, y+w2
    end
  end
end

def set_left
  xy = self.to_xy(@index)
  x, y = xy[0],xy[1]
  #if width == 1 && length == 1
  #  prepare_pos x-1, y
  #  return
  #end
  for w in 0...width
    for l in 0...length
      w2 = w
      w2 += l if w > 1
      prepare_pos x-l-1-@offset, y-w
      prepare_pos x-l-1-@offset, y+w
      prepare_pos x-l-1-@offset, y-w2
      prepare_pos x-l-1-@offset, y+w2
    end
  end
end

def set_up_left
  xy = self.to_xy(@index)
  x, y = xy[0],xy[1]
  for w in 0...width
    for l in 0...length
      #w2 = w
      #w2 += l if w > 1
      prepare_pos x-w, y-l-1-@offset
      prepare_pos x+w, y-l-1-@offset
      #prepare_pos x-w2, y-l-1-@offset
      #prepare_pos x+w2, y-l-1-@offset
      prepare_pos x-l-1-@offset, y-w
      prepare_pos x-l-1-@offset, y+w
      #prepare_pos x-l-1-@offset, y-w2
      #prepare_pos x-l-1-@offset, y+w2
    end
  end
end

def set_up_right
end

def set_down_left
end

def set_down_right
end

def prepare_pos(x,y)
  @positions.push [x, y] unless @positions.include? [x, y]
end

def to_xy(index)
  return [0,0] if index.nil?
  return [0,0] if index < 0
  return [(index % 17), (index / 17)]
end

end


=end