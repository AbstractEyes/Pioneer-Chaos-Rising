class Belt_Node < Sprite
  attr_reader :skill
  attr_reader :actor
  attr_accessor :flash
  attr_reader :index
  attr_reader :belt_index
  @skill = nil
  @actor = nil
  @destination = nil
  @new_zoom = nil
  @steps = 0
  @steps_left = 0
  @old_xy = nil
  @difference_xy = nil
  @difference_zoom = nil
  @new_z = nil
  @old_z = nil

  def animate_move(new_position, new_zoom, new_z, steps)
    @destination = new_position
    @new_zoom = new_zoom
    @steps = steps
    @steps_left = 0
    @old_xy = Coord.new(self.x, self.y)
    @old_zoom = Coord.new(self.zoom_x, self.zoom_y)
    @difference_xy = Coord.new(self.x - @destination.x, self.y - @destination.y)
    @difference_step = Coord.new((@destination.x.to_f - @old_xy.x.to_f).to_f / @steps,(@destination.y.to_f - @old_xy.y.to_f).to_f / @steps)
    @difference_zoom = Coord.new(self.zoom_x - new_zoom.x, self.zoom_y - new_zoom.y)
    @difference_zoom_step = Coord.new((@new_zoom.x.to_f - @old_zoom.x.to_f).to_f / @steps,(@new_zoom.y.to_f - @old_zoom.y.to_f).to_f / @steps)
    @new_z = new_z
    @old_z = self.z
  end

  def set_host(actor, skill)
    @actor = actor
    @skill = skill
    self.bitmap = Cache.system("Iconset2")
    rect = Rect.new(skill.icon_index % 16 * 32, skill.icon_index / 16 * 32, 32, 32)
    self.src_rect.set(rect.x, rect.y, rect.width, rect.height)
    @background.dispose if @background != nil
    @background = Sprite.new(self.viewport)
    @background.visible = self.visible
    @background.opacity = self.opacity
    @background.x = self.x
    @background.y = self.y
    @background.bitmap = Bitmap.new(32,32)
    @background.bitmap.fill_rect(0,0,32,32, get_background_color)
    fill_color = get_background_color
    fill_color.alpha = 150
    @old_color = get_background_color
    @background.bitmap.fill_rect(2,2,28,28, fill_color)
  end

  def get_background_color
    if @skill.unlocked
      # Check if can level
      if @skill.max_level > @skill.level
        # White, learnable.
        if @skill.lvl_rq <= @actor.level
          return PHI.color(:WHITE, 255)
        else
          return PHI.color(:GREY, 200)
        end
      else
        # Cyan, completed skill.
        return PHI.color(:CYAN, 255)
      end
    else
      # Check if can be unlocked.
      return PHI.color(:GREY, 100)
    end
  end

  def set_index(belt_index, index)
    @belt_index = belt_index
    @index = index
    @flash = false
    @flash_timer = 60
    @current_flash = 0
    @old_color = self.color
  end

  def visible=(new_val)
    super(new_val)
    @background.visible = new_val
  end

  def opacity=(new_val)
    super(new_val)
    @background.opacity = new_val
  end

  def dispose
    @background.dispose if @background != nil
    @background = nil
    super
  end

  def zoom_x=(new_zoom)
    @background.zoom_x = new_zoom if @background != nil
    super
  end
  def zoom_y=(new_zoom)
    @background.zoom_y = new_zoom if @background != nil
    super
  end

  def x=(new_val)
    @background.x = new_val if @background != nil
    super
  end
  def y=(new_val)
    @background.y = new_val if @background != nil
    super
  end
  def z=(new_val)
    @background.z = new_val if @background != nil
    super
  end

  def update(*args)
    super(*args)
    animate_flash
    animate_movement
  end

  def shifting?
    @steps = 0 if @steps.nil?
    @steps_left = 0 if @steps_left.nil?
    return @steps > 0
  end

  def animate_movement
    if shifting?
      @steps_left += 1
      self.x = @old_xy.x + @steps_left * @difference_step.x
      self.y = @old_xy.y + @steps_left * @difference_step.y
      self.zoom_x = @old_zoom.x + @steps_left * @difference_zoom_step.x
      self.zoom_y = @old_zoom.y + @steps_left * @difference_zoom_step.y
      #self.z = ((@new_z - @old_z).to_f / @steps)
      if @steps_left >= @steps
        self.x = @destination.x
        self.y = @destination.y
        self.zoom_x = @new_zoom.x
        self.zoom_y = @new_zoom.y
        self.z = @new_z
        @destination = nil
        @new_zoom = nil
        @steps = 0
        @steps_left = 0
        @old_xy = nil
        @new_z = nil
        @old_z = nil
        @difference_xy = nil
        @difference_zoom = nil
      end
    end
  end

  def animate_flash
    if @flash
      #flash forward
      @current_flash += 1
      if @current_flash < 24
        if @current_flash < 12
          @background.color.set(@old_color.red-@current_flash * 4,
                                @old_color.green-@current_flash * 4,
                                @old_color.blue-@current_flash * 4, 255)
        else
          nv = 12
          @background.color.set(((@old_color.red - 4 * nv)+(@current_flash-nv) * 4),
                                ((@old_color.green - 4 * nv)+(@current_flash-nv) * 4),
                                ((@old_color.blue - 4 * nv)+(@current_flash-nv) * 4), 255)
        end

      else
        @current_flash = 0
        @background.color = @old_color
      end
      #todo: flash back
    else
      @current_flash = 0
      @background.color = @old_color if @background.color != @old_color
    end
  end

end

class Skill_Belt_Window < Window_Base
  attr_accessor :active
  def initialize(x,y,width,height)
    super(x,y,width,height)
    @belt_index = 0
    @index = 0
    @last_index = -1
    @last_belt_index = 0
    @belt_keys = nil
    @belt_nodes = {}
    @belt_indexes = {}
    @active = false
  end

  def dispose
    @belt_nodes.each_value { |nodes| nodes.each { |node| node.dispose; }; } unless @belt_nodes.keys.empty?
    @belt_nodes.clear
    super
  end

  def opacity=(new_val)
    @belt_nodes.each_value { |nodes| nodes.each { |node| node.opacity = new_val; }; } unless @belt_nodes.keys.empty?
    super
  end

  def index_array(belt, nudge=0)
    @belt_indexes[belt.__id__] = 0 unless @belt_indexes.keys.include? belt.__id__
    return [
        chop_index(@belt_indexes[belt.__id__] - 3 + nudge, belt),
        chop_index(@belt_indexes[belt.__id__] - 2 + nudge, belt),
        chop_index(@belt_indexes[belt.__id__] - 1 + nudge, belt),
        chop_index(@belt_indexes[belt.__id__] + nudge, belt),
        chop_index(@belt_indexes[belt.__id__] + 1 + nudge, belt),
        chop_index(@belt_indexes[belt.__id__] + 2 + nudge, belt),
        chop_index(@belt_indexes[belt.__id__] + 3 + nudge, belt)
    ]
  end
  def chop_index(i, belt)
    # convert to right index.
    if i > belt.size - 1
      return i - belt.size
    elsif i < 0
      return i + belt.size
    end
    return i
  end

  def belt_index
    return @belt_index
  end
  def index=(val)
    @index = val if val.is_a?(Integer)
  end
  def belt_index=(val)
    @belt_index = val if val.is_a?(Integer)
  end

  def update
    super
    @belt_nodes.each_value { |nodes| nodes.each { |node| node.update; }; }
    update_icons
  end

  def refresh(actor)
    oa = @actor
    @actor = actor
    p @actor.class_id
    @belt_keys = PHI::SKILL_DATA.get_weapons(@actor.class_id)
    create_belts if oa != @actor
    update_icons
  end

  def active=(value)
    @active = value
    if @active
      reset_flashing
    else
      disable_flashing
    end
  end

  def create_belts
    draw_pos = 0
    for i in 0...@belt_keys.size
      belt = get_skill_belt(i)
      next if belt.nil?
      draw_pos += 1
      for b in 0...belt.size
        skill = belt[b]
        sprite = Belt_Node.new(self.viewport)
        sprite.set_index(draw_pos, b)
        sprite.set_host(@actor, skill)
        @belt_nodes[i] = [] unless @belt_nodes.keys.include?(i)
        @belt_nodes[i].push sprite
        @belt_indexes = {} if @belt_indexes.nil?
        @belt_indexes[belt.__id__] = 0 unless @belt_indexes.keys.include? i
      end
    end
    force_position_belts
  end

  def force_position_belts
    position_belt_top(get_graphics_belt(get_last_belt_index))
    position_belt_mid(get_graphics_belt(@belt_index))
    position_belt_bot(get_graphics_belt(get_next_belt_index))
    reset_flashing if @active
  end

  def set_visibility(belt, indexes)
    for id in 0...belt.size
      value = belt[id]
      if indexes.include? id
        value.visible = true
      else
        value.visible = false
      end
    end
  end

  def position_belt_top(belt)
    indexes = index_array(belt)
    set_visibility(belt, indexes)
    for i in 0...indexes.size
      cur_i = indexes[i]
      sprite = belt[cur_i]
      sprite.y = self.y + 8
      sprite.z = self.z + 1
      case i
        when 0, 6
          sprite.zoom_x = 1
          sprite.zoom_y = 1
          sprite.z = self.z + 1
          sprite.y += 30
        when 1, 5
          sprite.zoom_x = 1.25
          sprite.zoom_y = 1.25
          sprite.z = self.z + 2
          sprite.y += 20
        when 2, 4
          sprite.zoom_x = 1.5
          sprite.zoom_y = 1.5
          sprite.z = self.z + 3
          sprite.y += 10
        when 3
          sprite.zoom_x = 1.5
          sprite.zoom_y = 1.5
          sprite.z = self.z + 4
          sprite.y += 4
          #sprite.y
        else
          sprite.zoom_x = 1
          sprite.zoom_y = 1
      end
      case i
        when 0
          sprite.x = self.x + 8
        when 1
          sprite.x = self.x + 18 + 8
        when 2
          sprite.x = self.x + 48 + 8
        when 3
          sprite.x = self.x + self.width / 2 - (sprite.src_rect.width * sprite.zoom_x).to_i / 2
        when 4
          sprite.x = self.x + self.width - (sprite.src_rect.width * sprite.zoom_x).to_i - 8 - 48
        when 5
          sprite.x = self.x + self.width - (sprite.src_rect.width * sprite.zoom_x).to_i - 8 - 18
        when 6
          sprite.x = self.x + self.width - (sprite.src_rect.width * sprite.zoom_x).to_i - 8
      end
    end
  end

  def position_belt_mid(belt)
    indexes = index_array(belt)
    set_visibility(belt, indexes)
    for i in 0...indexes.size
      cur_i = indexes[i]
      sprite = belt[cur_i]
      sprite.y = self.y + self.height / 2 - 32
      sprite.z = self.z + 1
      case i
        when 0, 6
          sprite.zoom_x = 1.25
          sprite.zoom_y = 1.25
          sprite.z = self.z + 1
          sprite.y += 12
        when 1, 5
          sprite.zoom_x = 1.5
          sprite.zoom_y = 1.5
          sprite.z = self.z + 2
          sprite.y += 8
        when 2, 4
          sprite.zoom_x = 1.75
          sprite.zoom_y = 1.75
          sprite.z = self.z + 3
          sprite.y += 4
        when 3
          sprite.zoom_x = 2.25
          sprite.zoom_y = 2.25
          sprite.y = self.y + self.height / 2 - sprite.height * sprite.zoom_y / 2
          sprite.z = self.z + 4
        else
          sprite.zoom_x = 1
          sprite.zoom_y = 1
      end
      case i
        when 0
          sprite.x = self.x + 8
        when 1
          sprite.x = self.x + 18 + 8
        when 2
          sprite.x = self.x + 48 + 8
        when 3
          sprite.x = self.x + self.width / 2 - (sprite.src_rect.width * sprite.zoom_x).to_i / 2
        when 4
          sprite.x = self.x + self.width - (sprite.src_rect.width * sprite.zoom_x).to_i - 8 - 48
        when 5
          sprite.x = self.x + self.width - (sprite.src_rect.width * sprite.zoom_x).to_i - 8 - 18
        when 6
          sprite.x = self.x + self.width - (sprite.src_rect.width * sprite.zoom_x).to_i - 8
      end
    end
  end

  def position_belt_bot(belt)
    indexes = index_array(belt)
    set_visibility(belt, indexes)
    for i in 0...indexes.size
      cur_i = indexes[i]
      sprite = belt[cur_i]
      sprite.y = self.y + self.height - 64 - 8
      sprite.z = self.z + 1
      case i
        when 0, 6
          sprite.zoom_x = 1
          sprite.zoom_y = 1
          sprite.z = self.z + 1
        #sprite.y += 12
        when 1, 5
          sprite.zoom_x = 1.25
          sprite.zoom_y = 1.25
          sprite.z = self.z + 2
          sprite.y += 2
        when 2, 4
          sprite.zoom_x = 1.5
          sprite.zoom_y = 1.5
          sprite.z = self.z + 3
          sprite.y += 4
        when 3
          sprite.zoom_x = 1.5
          sprite.zoom_y = 1.5
          sprite.z = self.z + 4
          sprite.y += 8
        else
          sprite.zoom_x = 1
          sprite.zoom_y = 1
      end
      case i
        when 0
          sprite.x = self.x + 8
        when 1
          sprite.x = self.x + 18 + 8
        when 2
          sprite.x = self.x + 48 + 8
        when 3
          sprite.x = self.x + self.width / 2 - (sprite.src_rect.width * sprite.zoom_x).to_i / 2
        when 4
          sprite.x = self.x + self.width - (sprite.src_rect.width * sprite.zoom_x).to_i - 8 - 48
        when 5
          sprite.x = self.x + self.width - (sprite.src_rect.width * sprite.zoom_x).to_i - 8 - 18
        when 6
          sprite.x = self.x + self.width - (sprite.src_rect.width * sprite.zoom_x).to_i - 8
      end
    end
  end

  def get_skill_belt(sorted_index)
    return @actor.skills[@belt_keys[sorted_index]]
  end

  def get_graphics_belt(belt_id)
    return @belt_nodes[belt_id]
  end

  def get_last_belt_index
    return @belt_nodes.keys.size - 1 if @belt_index - 1 < 0
    return @belt_index - 1
  end

  def get_next_belt_index
    return 0 if @belt_index + 1 >= @belt_nodes.keys.size
    return @belt_index + 1
  end

  def get_last_index
  end

  def index
  end

  def get_next_index
  end

  def shifting?
    for belt in @belt_nodes.values
      for item in belt
        return true if item.shifting?
      end
    end
    return false
  end

  def update_icons
    self.contents.clear
    #Enable to always work.
    #force_position_belts
  end

  def next_belt
    return if shifting?
    @belt_index += 1
    if self.belt_index > @belt_keys.size - 1
      @belt_index = 0
    end
    shift_up
  end
  def last_belt
    return if shifting?
    @belt_index -= 1
    if @belt_index < 0
      @belt_index = @belt_keys.size - 1
    end
    shift_down
  end
  def next_skill
    return if shifting?
    shift_left
    @belt_indexes[get_graphics_belt(@belt_index).__id__] += 1
    if @belt_indexes[get_graphics_belt(@belt_index).__id__] > get_skill_belt(@belt_index).keys.size - 1
      @belt_indexes[get_graphics_belt(@belt_index).__id__] = 0
    end
  end
  def last_skill
    return if shifting?
    shift_right
    @belt_indexes[get_graphics_belt(@belt_index).__id__] -= 1
    if @belt_indexes[get_graphics_belt(@belt_index).__id__] < 0
      @belt_indexes[get_graphics_belt(@belt_index).__id__] = get_skill_belt(@belt_index).keys.size - 1
    end
  end

  def shift_down
    # Shifts all belts down
    top_graphics = get_graphics_belt(get_last_belt_index)
    mid_graphics = get_graphics_belt(@belt_index)
    bot_graphics = get_graphics_belt(get_next_belt_index)
    top_belt = index_array(top_graphics)
    mid_belt = index_array(mid_graphics)
    bot_belt = index_array(bot_graphics)
    shift_icons_vertical(mid_graphics, bot_graphics, mid_belt, bot_belt)
    shift_icons_vertical(top_graphics, mid_graphics, top_belt, mid_belt)
    shift_icons_vertical(bot_graphics, top_graphics, bot_belt, top_belt)
    reset_flashing
  end

  def shift_up
    # Shifts all belts up
    top_graphics = get_graphics_belt(get_last_belt_index)
    mid_graphics = get_graphics_belt(@belt_index)
    bot_graphics = get_graphics_belt(get_next_belt_index)
    top_belt = index_array(top_graphics)
    mid_belt = index_array(mid_graphics)
    bot_belt = index_array(bot_graphics)
    shift_icons_vertical(bot_graphics, mid_graphics, bot_belt, mid_belt)
    shift_icons_vertical(mid_graphics, top_graphics, mid_belt, top_belt)
    shift_icons_vertical(top_graphics, bot_graphics, top_belt, bot_belt)
    reset_flashing
  end

  def shift_icons_vertical(current_graphics, target_graphics, current_indexes, target_indexes)
    for x in 0...current_indexes.size
      old_index = current_indexes[x]
      new_index = target_indexes[x]
      current_graphics[old_index].animate_move(Coord.new(target_graphics[new_index].x, target_graphics[new_index].y),
                                       Coord.new(target_graphics[new_index].zoom_x, target_graphics[new_index].zoom_y),
                                               target_graphics[new_index].z, 20)
    end
  end

  def shift_icons(graphics, old_indexes, new_indexes)
    for x in 0...old_indexes.size
      old_index = old_indexes[x]
      new_index = new_indexes[x]
      next if graphics[new_index].nil?
      graphics[new_index].animate_move(Coord.new(graphics[old_index].x, graphics[old_index].y),
                                       Coord.new(graphics[old_index].zoom_x, graphics[old_index].zoom_y),
                                       graphics[old_index].z, 10)
    end
    set_visibility(graphics, new_indexes)
  end

  def shift_right
    graphics = get_graphics_belt(@belt_index)
    old_indexes = index_array(graphics)
    new_indexes = index_array(graphics, -1)
    graphics[new_indexes[3]].flash = true
    graphics[old_indexes[3]].flash = false
    shift_icons(graphics, old_indexes, new_indexes)
  end
  def shift_left
    # Shifts the current belt left
    graphics = get_graphics_belt(@belt_index)
    old_indexes = index_array(graphics)
    new_indexes = index_array(graphics, 1)
    graphics[new_indexes[3]].flash = true
    graphics[old_indexes[3]].flash = false
    shift_icons(graphics, old_indexes, new_indexes)
  end

  def reset_flashing
    disable_flashing
    get_primary_node.flash = true
  end

  def disable_flashing
    for i in 0...get_ordered_belts.size
      belt = get_ordered_belts[i]
      for node in belt
        node.flash = false
      end
    end
  end

  def get_primary_node
    return get_graphics_belt(@belt_index)[index_array(get_graphics_belt(@belt_index))[3]]
  end

  def get_unordered_belts
    return get_graphics_belt(get_last_belt_index) +
            get_graphics_belt(@belt_index) +
            get_graphics_belt(get_next_belt_index)
  end

  def get_ordered_belts
    return [get_graphics_belt(get_last_belt_index),
            get_graphics_belt(@belt_index),
            get_graphics_belt(get_next_belt_index)]
  end

end
