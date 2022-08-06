=begin
class Window_Target < Window_Selectable

  def initialize
    super
  end

  def update
    super
  end

  def refresh
    create_contents
  end

end
=end
=begin
class Window_Target < Window_Selectable
  attr_accessor :locked_position
  attr_reader   :dir8_lock
  attr_accessor :locked_direction
  attr_accessor :shape_manager
  attr_accessor :shape_tiles

  # Todo:  Add more target captures
  # Todo:  Prepare shapes for target grabbing
  # Todo:  Pre-Step shapes,
  # Todo:  Post timer shapes.
  def initialize(x,y,width,height)
    super(x-16,y-16,width+32,height+32, 0)
    @wlh2 = 32
    @corner = [0,0]
    @column_max = 17
    @section_columns = 0
    @section_rows = 0
    @item_max = 17*13
    @index_iterator = 0
    @battle_grid_index_list = []
    @character_index_list = []
    self.opacity = 0
    self.active = false
    self.visible = false
    @cursor_graphic = ::Sprite.new
    @cursor_graphic.bitmap = Bitmap.new(32,32)
    @battler = nil
    @data_window = Target_Data.new
    @last_state = $game_system.target_state
    @locked_position = -1
    @locked_direction = 5
    @shape_tiles = []
    @old_locked_direction = @locked_direction
    @dir8_lock = DI8.new(-1,-1,-1,-1,-1,-1,-1,-1)
    @background_sprite_image = Bitmap.new("graphics/Windows/hud/target.png")
  end

  def visible=(visible)
    super
    @data_window.visible = visible unless @data_window.nil?
  end
  
  def dispose
    @cursor_graphic.dispose
    @data_window.dispose
    @background_sprite_image.dispose
    super
  end

  # Gets the upper left corner xy of the window, on the map.
  def get_window_pos
    outx, outy = @character.x - 8, @character.y - 6
    if outx < 0
      outx = 0
    end
    if outx > $game_map.width - 17
      outx = $game_map.width - 17
    end
    if outy < 0
      outy = 0
    end
    if outy > $game_map.height - 13
      outy = $game_map.height - 13
    end
    @corner = [outx, outy]
  end

  # takes in host, type of usage, and shape of type.
  #    post macro determination, needs to handle in battle scene.
  def refresh(battler=@battler, type=@type, shape_manager=@shape_manager)
    self.contents.clear
    @battler = battler
    @index_iterator = 0
    @character = $game_party.get_player(@battler) if @battler.is_a?(Game_Actor)
    @character = $game_troop.get_character(@battler) if @battler.is_a?(Game_Enemy)
    @attack_grid = $game_party.get_leader.attack_range
    @battle_grid = $game_party.get_leader.battle_range
    @type = type
    @shape_manager = shape_manager
    @shape_tiles = []
    create_index_list
    filter_index
    refresh_lite
  end

  #####################################################################################
  # Target structure
  #####################################################################################
  def get
    return get_targets
  end

  def get_targets
    return [] if self.index < 0
    out_tiles = []
    for tile in prepare_shape_tiles
      out_tiles.push to_map_xy(to_window_index(tile[0], tile[1]))
    end
    return out_tiles
  end

  def get_direction
    return @locked_direction
  end

  def get_target_data
    return [] if self.index < 0
    xy = to_map_xy(self.index)
    #Todo: Add target ranges for (1)shapes.
    #Done: Pile target.
    return $game_map.events_xy(xy[0],xy[1]) # Pile
  end

  def index=(new_index)
    if new_index.is_a?(Integer)
      @index = new_index
      refresh_lite
    end
  end

  def filter_index
    @filtered_list = []
    case $game_system.target_state
      when 0
        if @locked_position > -1
          #Target accepted, direction state, locked around target.
          prepare_surrounding_index
          find_locked_starting_index
        else
          #Target select state, locked to monster.
          #Default state, unless the temp state is different.
          clear_locked
          prepare_filtered_targets
          find_monster_starting_index
        end
      when 1
        if @locked_position > -1
          #Target accepted, direction state, locked in position.
          prepare_placed_index
          find_locked_starting_direction
        else
          #Target select state, unlocked entirely.
          clear_locked
          prepare_raw_targets
          find_host_starting_index
        end
    end
  end

  def prepare_filtered_targets
    grid = @battle_grid_index_list
    for i in 0...grid.size
      xy = to_map_xy(grid[i])
      next if @filtered_list.include?(grid[i])
      case @type
        when "party"
          if player_here?(xy[0],xy[1])
            @filtered_list.push(grid[i])
          end
        when "enemy"
          if enemy_here?(xy[0],xy[1])
            @filtered_list.push(grid[i])
          end
        when "any"
          @filtered_list.push(grid[i]) if enemy_here?(xy[0],xy[1]) || player_here?(xy[0],xy[1])
      end
    end
    @index_iterator = 0
    @filtered_list.compact!
  end
  #####################################################################################
  # Update/Refresh sequence
  #####################################################################################
  def refresh_lite
    if @character != nil && self.index > -1
      @data_window.visible = true
      @data_window.refresh(140, 0, get_target_data)
    else
      @data_window.visible = false
    end
    draw_contents
  end

  def clear_locked
    @locked_direction = 5 if @locked_direction != 5
    @locked_position = -1
    @shape_tiles = []
  end

  def draw_contents
    create_contents
    draw_rects
  end

  #####################################################################################
  # Shared
  #####################################################################################

  
  def valid?(event, xy)
    return (event.battler != nil && !event.battler.dead? && event.x == xy[0] && event.y == xy[1])
  end

  def valid_selection?
    return true
  end


  def prepare_raw_targets
    @filtered_list = @battle_grid_index_list.clone
  end

  # Places the @locked FILTERED index list
  # Locks in place, points AT position.
  def prepare_surrounding_index
    xy = u_to_xy(@locked_position)
    @dir8_lock.set(xy, @shape_manager.raw_offset(@character))
  end

  # Places the @locked UNFILTERED index list
  # Locks in place, points away in a direction.
  def prepare_placed_index
    self.index = @locked_position
  end

  def find_locked_starting_index
    d = @dir8_lock.get_closest_around(host_index)
    self.index = d[0]
    @locked_direction = d[1]
  end

  def find_locked_starting_direction
    @locked_direction = 8 if @locked_direction.nil? or @locked_direction < 1 or @locked_direction > 9
  end

  def find_monster_starting_index
    if @filtered_list.size > 0
      d = @dir8_lock.get_closest_around(host_index, @filtered_list)
      self.index = d[0]
      #@locked_direction = d[1]
      refresh_lite
    end
  end

  def find_host_starting_index
    self.index = host_index
    for i in 0...@filtered_list.size
      return @index_iterator = i if @filtered_list[i] == host_index
    end
    @index_iterator = 0
  end
  
  # Retrieves all cells from the map containing the player,
  #  that the player itself can see.
  def create_index_list
    @battle_grid_index_list.clear
    @character_index_list.clear
    pos = get_window_pos
    @section_columns = 0
    @section_rows = 0
    for index_x in pos[0]...pos[0]+17
      for index_y in pos[1]...pos[1]+13
        wi = to_window_index(index_x,index_y)
        if @battle_grid.inside?(index_x,index_y)
          unless @battle_grid_index_list.include?(wi)
            @battle_grid_index_list.push(wi)
          end
        end
        if @attack_grid.inside?(index_x,index_y)
          unless @character_index_list.include?(wi)
            @character_index_list.push(wi)
          end
        end
      end
    end
    @section_columns = @battle_grid.width
    @section_rows = @battle_grid.height
    @character_index_list.sort!
    @battle_grid_index_list.sort!
  end

  def draw_rects
    for i in @battle_grid_index_list
      if @character_index_list.include?(i)
        draw_rectangle(i, 1)
      else
        draw_rectangle(i, 0.45)
      end
    end
    unless @shape_tiles.empty?
      for tile in @shape_tiles
        draw_colored_rectangle(to_window_index(tile[0],tile[1]), PHI.color(:RED, 255))
      end
    end
  end

  # Template rectangle.
  def draw_rectangle(index, mult)
    rect = item_rect(index)
    rect.x += 2
    rect.y += 2
    rect.width -= 4
    rect.height -= 4
    xy = to_map_xy(index)
    x, y = xy[0],xy[1]
    if player_here?(x, y) # Player here
      self.contents.fill_rect(rect, PHI.color(:CYAN, 120 * mult))
    elsif enemy_here?(x, y)
      self.contents.fill_rect(rect, PHI.color(:RED, 120 * mult))
    elsif event_here?(x, y)
      self.contents.fill_rect(rect, PHI.color(:GREEN, 120 * mult))
    elsif passable_here?(x,y) # Nothing here
      self.contents.fill_rect(rect, PHI.color(:GREY, 100 * mult))
    else
      self.contents.fill_rect(rect, PHI.color(:WHITE, 40 * mult))
    end
  end

  def draw_colored_rectangle(index, color)
    rect = item_rect(index)
    rect.x += 2
    rect.y += 2
    rect.width -= 4
    rect.height -= 4
    self.contents.fill_rect(rect, color)
  end

  def cursor_movable?
    return true if self.active && self.visible
    return false
  end

  # size_length is the length of the attack.
  # size_width is the width of the attack, adding one per point on each side.
  # offset is the amount of spaces the character has between it and its weapon attack.
  # damage is the damage type, physical/magic/agility
  # startup is the adjusted weapon attack time startup
  # cooldown is the adjusted weapon attack time cooldown
  def prepare_shape_tiles
    return nil if @character.nil?
    return nil if @character.get_member.nil?
    return @shape_manager.prepare_shape(
        @character,
        self.to_map_xy(@locked_position),
        @locked_direction,
        0,
        $game_system.target_state
    )
  end
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  def update
    @cursor_graphic.update
    @data_window.update
    super
    if @locked_direction != @old_locked_direction
      iterate_locked_direction_tiles
      @old_locked_direction = @locked_direction
    end
  end

  def iterate_locked_direction_tiles
    return if @locked_direction == 5
    if @locked_direction != 5
      @locked_direction = 5 if @locked_direction.nil? or @locked_direction < 1 or @locked_direction > 9
      @shape_tiles = prepare_shape_tiles
      refresh_lite
    end
  end


  #todo expand the index position handlers
  def next_index_position_unlocked
    @index_iterator += 1
    if @index_iterator % @section_columns == 0
      @index_iterator -= @section_columns
    end
    self.index = @filtered_list[@index_iterator]
  end
  def next_row_position_unlocked
    @index_iterator += @section_columns
    if @index_iterator > @section_rows * @section_columns
      @index_iterator -= @section_rows * @section_columns
    end
    self.index = @filtered_list[@index_iterator]
  end
  def last_index_position_unlocked
    @index_iterator -= 1
    if @index_iterator % @section_columns == @section_columns - 1
      @index_iterator += @section_columns
    end
    self.index = @filtered_list[@index_iterator]
  end
  def last_row_position_unlocked
    @index_iterator -= @section_columns
    if @index_iterator < 0
      @index_iterator += (@section_rows - 1) * @section_columns
    end
    self.index = @filtered_list[@index_iterator]
  end

  def next_index_position_locked
    @index_iterator += 1
    if @index_iterator >= @filtered_list.size
      @index_iterator = 0
    end
    self.index = @filtered_list[@index_iterator]
  end
  def next_row_position_locked
    next_index_position_locked
  end
  def last_index_position_locked
    @index_iterator -= 1
    if @index_iterator < 0
      @index_iterator = @filtered_list.size - 1
    end
    self.index = @filtered_list[@index_iterator]
  end
  def last_row_position_locked
    last_index_position_locked
  end

  #Todo: Set directions for direction changes.
  def placed_locked_cursor_down
    return if self.index == @dir8_lock.down
    if self.index == @dir8_lock.right
      self.index = @dir8_lock.downright
      @locked_direction = 7
    elsif self.index == @dir8_lock.left
      self.index = @dir8_lock.downleft
      @locked_direction = 9
    else
      self.index = @dir8_lock.down
      @locked_direction = 8
    end
  end
  def placed_locked_cursor_up
    return if self.index == @dir8_lock.up
    if self.index == @dir8_lock.right
      self.index = @dir8_lock.upright
      @locked_direction = 1
    elsif self.index == @dir8_lock.left
      self.index = @dir8_lock.upleft
      @locked_direction = 3
    else
      self.index = @dir8_lock.up
      @locked_direction = 2
    end
  end
  def placed_locked_cursor_left
    return if self.index == @dir8_lock.left
    if self.index == @dir8_lock.down
      self.index = @dir8_lock.downleft
      @locked_direction = 9
    elsif self.index == @dir8_lock.up
      self.index = @dir8_lock.upleft
      @locked_direction = 3
    else
      self.index = @dir8_lock.left
      @locked_direction = 6
    end
  end
  def placed_locked_cursor_right
    return if self.index == @dir8_lock.right
    if self.index == @dir8_lock.down
      self.index = @dir8_lock.downright
      @locked_direction = 7
    elsif self.index == @dir8_lock.up
      self.index = @dir8_lock.upright
      @locked_direction = 1
    else
      self.index = @dir8_lock.right
      @locked_direction = 4
    end
  end

  def placed_unlocked_cursor_down
    return if @locked_direction == 2
    if @locked_direction == 6
      @locked_direction = 3
    elsif @locked_direction == 4
      @locked_direction = 1
    else
      @locked_direction = 2
    end
  end
  def placed_unlocked_cursor_up
    return if @locked_direction == 8
    if @locked_direction == 4
      @locked_direction = 7
    elsif @locked_direction == 6
      @locked_direction = 9
    else
      @locked_direction = 8
    end
  end
  def placed_unlocked_cursor_left
    return if @locked_direction == 4
    if @locked_direction == 8
      @locked_direction = 7
    elsif @locked_direction == 2
      @locked_direction = 1
    else
      @locked_direction = 4
    end
  end
  def placed_unlocked_cursor_right
    return if @locked_direction == 6
    if @locked_direction == 8
      @locked_direction = 9
    elsif @locked_direction == 2
      @locked_direction = 3
    else
      @locked_direction = 6
    end
  end

  def position_locked?
    @locked_position > -1
  end
  #--------------------------------------------------------------------------
  # * Move cursor down
  #     wrap : Wraparound allowed
  #--------------------------------------------------------------------------
  def cursor_down(wrap = false)
  end
  #--------------------------------------------------------------------------
  # * Move cursor up
  #     wrap : Wraparound allowed
  #--------------------------------------------------------------------------
  def cursor_up(wrap = false)
  end
  #--------------------------------------------------------------------------
  # * Move cursor right
  #     wrap : Wraparound allowed
  #--------------------------------------------------------------------------
  def cursor_right(wrap = false)
  end
  #--------------------------------------------------------------------------
  # * Move cursor left
  #     wrap : Wraparound allowed
  #--------------------------------------------------------------------------
  def cursor_left(wrap = false)
  end
  #--------------------------------------------------------------------------
  # * Move cursor one page down
  #--------------------------------------------------------------------------
  def cursor_pagedown
  end
  #--------------------------------------------------------------------------
  # * Move cursor one page up
  #--------------------------------------------------------------------------
  def cursor_pageup
  end
  #--------------------------------------------------------------------------
  # * draw_pointer
  #--------------------------------------------------------------------------
  def draw_cursor_pointer
    return
  end

  def draw_cursor_background
    return unless @update_pointer
    return unless (@intern_frame_count % 5) == 0
    @background_sprite.bitmap.clear
    return if @index == -1
    return unless self.active or self.visible
    # Background
    opacity = @background_sprite.opacity + @sprite_inc_x * 18
    @background_sprite_image = create_target_bitmap
    @background_sprite.bitmap.blt(0, 0, @background_sprite_image, @background_sprite_image.rect)
    @background_sprite.opacity = opacity
  end

  def create_target_bitmap
    return @background_sprite_image
  end
  #--------------------------------------------------------------------------
  # * Index positions
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  # Convert coordinates into a usable index.
  def to_index(x,y)
    x=0 if x<0
    y=0 if y<0
    return (y*@column_max + x)
  end

  #--------------------------------------------------------------------------
  # Converts MAP xy to window index
  # Returns: map_index
  def to_window_index(x,y)
    # Convert to window xy
    xy = to_window_xy(x,y)
    # Converts to windows index
    return to_index(xy[0],xy[1])
  end

  #--------------------------------------------------------------------------
  # Converts map xy to window xy
  def to_window_xy(x,y)
    w = get_window_pos
    outx, outy = x - w[0], y - w[1]
    return [outx, outy]
  end

  #--------------------------------------------------------------------------
  def to_xy(iindex)
    return [0,0] if iindex.nil?
    return [0,0] if iindex < 0
    return [(iindex % @column_max), (iindex / @column_max)]
  end
  def u_to_xy(iindex)
    return [(iindex % @column_max), (iindex / @column_max)]
  end
  def host_index
    return -1 if @character.nil?
    return to_window_index(@character.x, @character.y)
  end
  #--------------------------------------------------------------------------
  def convert_to_map_xy(xy_inputs)
    out = []
    for xy in xy_inputs
      out.push to_map_xy(to_window_index(xy[0], xy[1]))
    end
    return out
  end
  def to_map_xy(window_index)
    # Convert to normal xy
    xy = to_xy(window_index)
    # Convert to map xy
    w = get_window_pos
    xy[0], xy[1] = xy[0] + w[0], xy[1] + w[1]
    # Return map xy
    return xy
  end

  def enemy_here?(x,y)
    for ev in $game_map.events_xy(x,y)
      next if ev.tags.nil?
      next if ev.battler.nil?
      next if ev.battler.dead?
      return true
    end
    return false
  end
  
  def player_here?(x,y)
    for player in $game_party.players.values
      return true if player.x == x and player.y == y
    end
    return false
  end

  def is_host?(x,y)
    return @character.x == x && @character.y == y
  end
  
  def event_here?(x,y)
    return !$game_map.events_xy(x,y).empty?
  end
  
  def passable_here?(x,y)
    return $game_map.passable?(x,y)
  end

end
=end