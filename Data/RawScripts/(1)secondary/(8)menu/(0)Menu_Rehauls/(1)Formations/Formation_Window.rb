class Formation_Window < Window_Selectable

  def initialize(x,y,width,height)
    h = height + 32
    @nudge = 32
    super(x,y,width,h)
    @column_max = 5
    @item_max = 25
    @wlh2 = 32
    @locked = -1
    @bench = []
    @position = 0
    @data = PHI::Formation.formations
    refresh
  end

  def refresh(position = @position)
    create_contents
    @bench = $game_party.sorted_members[0...5]
    draw_formation(position)
  end

  def set
    swap(self.index, @locked)
    PHI::Formation.set(@position, @matrix)
    unlock
  end

  def swap(location, old_location)
    old = @matrix[old_location]
    new = @matrix[location]
    @matrix[old_location] = new
    @matrix[location] = old
  end

  def exists?
    return false if self.index < 0
    if @matrix[self.index] > 0
      return true
    end
    return false
  end

  def lock
    @locked = self.index
    refresh
  end

  def unlock
    @locked = -1
    refresh
  end

  def locked?
    return @locked > -1
  end

  def get_locked_member_id
    return @bench[@matrix[@locked] - 1]
  end

  def get_member_id(grid_index)
    return @bench[get_member_index(grid_index)]
  end

  def get_locked_member_index
    return @matrix[@locked] - 1
  end

  def get_member_index(grid_index)
    return @matrix[grid_index] - 1
  end

  def draw_formation(position)
    return unless @data.keys.include?(position)
    @matrix = prepare_matrix(position)
    @position = position
    for grid_index in 0...@item_max
      draw_rect(item_rect(grid_index))
      next unless get_member_id(grid_index) > 0
      next if locked? && get_locked_member_index == get_member_index(grid_index)
      draw_current_member(grid_index)
    end
    draw_locked
  end

  def prepare_matrix(position)
    matrix = []
    for i in 0...@data[position][:matrix].size
      matrix.concat(@data[position][:matrix][i])
    end
    return matrix
  end

  def item_rect(index)
    rect = Rect.new(0, 0, 0, 0)
    rect.width = (contents.width + @spacing) / @column_max - @spacing
    rect.height = @wlh2
    rect.x = index % @column_max * (rect.width + @spacing)
    rect.y = index / @column_max * @wlh2 + @nudge
    return rect
  end

  def draw_current_member(grid_index, shade=nil)
    #return if @bench[player_index] == -1
    return if $game_party.players[get_member_id(grid_index)].nil?
    rect = item_rect(grid_index)
    draw_actor_graphic($game_party.players[get_member_id(grid_index)], rect.x+16, rect.y+32, shade)
  end

  def draw_locked
    return unless locked?
    actor = $game_party.players[get_locked_member_id]
    return if actor.nil?
    rect = item_rect(self.index)
    rect.x += 16
    rect.y += 32
    draw_locked_character(actor.character_name, actor.character_index, rect.x, rect.y, Color.new(1.5, 1.25, 1, 1))
  end

  def draw_rect(rect)
    x,y,w,h = rect.x+4,rect.y+4,rect.width-2,rect.height-8
    x2,y2,w2,h2 = x+2,y+2,w-10,h-4
    self.contents.fill_rect(x,y,w,h, PHI.color(:RED, 120))
    self.contents.fill_rect(x2,y2,w2,h2, PHI.color(:RED, 40))
  end

  def draw_actor_graphic(actor, x, y, shade)
    draw_locked_character(actor.character_name, actor.character_index, x, y, shade)
  end

  def draw_locked_character(character_name, character_index, x, y, shade)
    return if character_name == nil
    bitmap = Cache.character(character_name)
    sign = character_name[/^[\!\$]./]
    if sign != nil and sign.include?('$')
      cw = bitmap.width / 3
      ch = bitmap.height / 4
    else
      cw = bitmap.width / 12
      ch = bitmap.height / 8
    end
    n = character_index
    src_rect = Rect.new((n%4*3+1)*cw, (n/4*4+3)*ch, cw, ch)
    self.contents.blt(x - cw / 2, y - ch, filter(bitmap.clone, src_rect, shade), src_rect)
  end

  def filter(bitmap_clone, src_rect, color)
    return bitmap_clone if color.nil?
    for column in src_rect.x...src_rect.width + src_rect.x
      for row in src_rect.y...src_rect.height + src_rect.y
        pixel = bitmap_clone.get_pixel(column, row)
        red = color.red * pixel.red
        blue = color.blue * pixel.blue
        green = color.green * pixel.green
        bitmap_clone.set_pixel(column, row, Color.new(red, green, blue, pixel.alpha))
      end
    end
    return bitmap_clone
  end

end