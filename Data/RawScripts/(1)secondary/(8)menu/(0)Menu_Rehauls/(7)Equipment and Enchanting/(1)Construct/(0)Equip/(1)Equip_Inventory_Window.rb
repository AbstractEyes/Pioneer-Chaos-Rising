class Equip_Inventory_Header < Window_Base

end


class Equip_Inventory < Window_Selectable

  def initialize(x,y,w,h, window_mode=0)
    super(x,y,w,h)
    # 0 = standard party only
    # 1 = inventory only
    # 2 = inventory & party
    # 3 = inventory filtered to item type
    @window_mode = window_mode
    @wlh2 = 32
    @equip_keys = []
    @column_max = 6
    @index = 0
    self.opacity = 0
    @equip_keys = []
    @spare_equip_keys = []
    refresh
  end

  def actioner
    return $game_party.all_members_safe(0)
  end

  def actor(i)
    return $game_party.all_members_safe[i]
  end

  def get_actor(db_id)
    $game_party.all_members_safe.each { |act| return act if act.equip_ids.include?(db_id) }
    return nil
  end

  def equipped?(db_id)
    return @equip_keys.include?(db_id)
  end

  def equippable_to?(equipped_db_id, unequipped_db_id)
    return false if get_actor(equipped_db_id).nil?
    return get_actor(equipped_db_id).equippable?(unequipped_db_id) &&
        (self.index % 6 == $game_party.equipment[unequipped_db_id].kind)
  end

  def equippable_from?(equipped_db_id, unequipped_db_id, saved_index)
    return false if get_actor(equipped_db_id).nil?
    return get_actor(equipped_db_id).equippable?(unequipped_db_id) &&
        (saved_index % 6 == $game_party.equipment[unequipped_db_id].kind)
  end

  def sorted_index
    self.index - @equip_keys.size + 1
  end

  def has_equips?
    return !ordered_equipment_keys.empty?
  end

  def ordered_equipment_keys
    return @equip_keys + @spare_equip_keys
  end

  def equip
    return item
  end

  def item
    return ordered_equipment_keys[self.index]
  end

  def item_at(index)
    return ordered_equipment_keys[index]
  end

  def lock_type
    # If locking equipped item.
    return 0 if self.index <= @equip_keys.size - 1
    # If locking unequipped item.
    return 1 if self.index > @equip_keys.size - 1
  end

  def create_contents_now
    self.contents.dispose
    maxbitmap = 8192
    dw = [width - 32, maxbitmap].min
    dh = [[height - 32, row_max * @wlh2].max, maxbitmap].min
    bitmap = Bitmap.new(dw, dh)
    self.contents = bitmap
    self.contents.font.color = normal_color
  end

  def is_equipped?(db_id)
    return $game_party.equipment.equipped?(db_id)
  end

  def refresh_equips
    case @window_mode
      when 0
        @equip_keys = $game_party.equipment.equipped
        @spare_equip_keys = []
      when 1
        @equip_keys = []
        @spare_equip_keys = $game_party.equipment.sorted
      when 2
        @equip_keys = $game_party.equipment.equipped
        @spare_equip_keys = $game_party.equipment.sorted
      when 3
        @equip_keys = []
        @spare_equip_keys = $game_party.equipment.same_equips(@equip)
    end
    @item_max = ordered_equipment_keys.size
  end

  def refresh(equip = -1)
    return if (equip == nil or equip == -1) && @window_mode == 3
    @equip = equip
    refresh_equips
    create_contents_now
    # Draw background
    if @window_mode == 0 or @window_mode == 2
      rect = item_rect(0)
      rect.x -= 32
      rect.width = self.contents.width - 32
      rect.height = 32 * $game_party.all_members_safe.size
      self.contents.fill_rounded_rect(rect, PHI.color(:RED, 30), 11)
      for member_id in 0...$game_party.all_members_safe.size
        act = actor(member_id)
        draw_character_face(act.character_name, act.character_index, item_rect(0).x - 16, item_rect(member_id * 6).y+64, false)
        self.contents.draw_text(item_rect(0).x - 32, item_rect(member_id * 6 + 6).y - 32, 32, 64, act.level.to_s)
      end
    end
    if @window_mode == 1 or @window_mode == 2 or @window_mode == 3
      self.contents.fill_rect(32,2,self.contents.width - 32-8, 2, PHI.color(:GREY))
      if @spare_equip_keys.size > 0
        rect = item_rect(0)
        #rect.y = 32 * $game_party.all_members_safe.size
        rect.width = self.contents.width - 64
        rect.height  = 32 * (@spare_equip_keys.size / 6.0).ceil
        self.contents.fill_rounded_rect(rect, PHI.color(:BROWN, 30), 11)
      end
    end
    for i in 0...@item_max
      item = $game_party.equipment[item_at(i)]
      next if item_at(i) == equip
      draw_equipment(item_rect(i), item)
    end
    if @item_max == 0
      self.contents.draw_text(40,0,self.contents.width,32, 'No spare equipment')
    end
  end

  def refresh_item(index_db, item=false)
    refresh_equips
    index = index_db
    index = ordered_equipment_keys.index(index_db) if item
    self.contents.clear_rect(item_rect(index))
    @equip_keys.size <= index ? color = PHI.color(:BROWN, 30) : color = PHI.color(:RED, 30)
    self.contents.fill_rect(item_rect(index), color)
    draw_equipment(item_rect(index), $game_party.equipment[ordered_equipment_keys[index]])
  end

  def item_rect(index)
    rect = Rect.new(0, 0, 0, 0)
    rect.width = 36
    rect.height = @wlh2
    rect.x = index % @column_max * (rect.width + 4)
    rect.y = index / @column_max * @wlh2 + 4
    rect.x += 58
    #rect.y += 32
    return rect
  end

  def draw_equipment(rect, item, color = :CYAN)
    return if item.nil?
    draw_map_icon(item.icon_index, rect.x, rect.y)
    self.contents.font.color = PHI.color(color)
    fsize = self.contents.font.size
    rect.x -= 4
    rect.y -= 12
    self.contents.font.size = 16
    if item.level > 99
      self.contents.draw_text(rect, item.level.to_s)
    else
      self.contents.draw_text(rect, 'lvl ' + item.level.to_s)
    end
    #self.contents.font.color = normal_color
    self.contents.font.size = fsize
    #rect.y += 22
    #self.contents.draw_text(rect, 'o' * item.max_sockets)
    #self.contents.draw_text(rect.x + 38, rect.y, rect.width, rect.height, item.name)
  end

end

=begin
class Equip_Inventory < Window_Selectable

  def initialize(x,y,w,h)
    super(x,y,w,h)
    @wlh2 = 32
    @equip_keys = []
    @column_max = 6
    @index = 0
    self.opacity = 0
    refresh
    self.index = $game_index.equip_index
  end

  def actor(i)
    return $game_party.all_members_safe[i]
  end

  def get_actor(db_id)
    $game_party.all_members_safe.each { |act| return act if act.equip_ids.include?(db_id) }
    return nil
  end

  def equipped?(db_id)
    return @equip_keys.include?(db_id)
  end

  def equippable_to?(equipped_db_id, unequipped_db_id)
    return false if get_actor(equipped_db_id).nil?
    return get_actor(equipped_db_id).equippable?(unequipped_db_id) &&
        (self.index % 6 == $game_party.equipment[unequipped_db_id].kind)
  end

  def equippable_from?(equipped_db_id, unequipped_db_id, saved_index)
    return false if get_actor(equipped_db_id).nil?
    return get_actor(equipped_db_id).equippable?(unequipped_db_id) &&
        (saved_index % 6 == $game_party.equipment[unequipped_db_id].kind)
  end

  def sorted_index
    self.index - @equip_keys.size - 5
  end

  def ordered_equipment_keys
    return [nil, nil, nil, nil, nil, nil] + @equip_keys + @spare_equip_keys
  end

  def item
    return (@equip_keys + @spare_equip_keys)[self.index - 6]
  end

  def item_at(index)
    return ordered_equipment_keys[index]
  end

  def data
    return (@equip_keys + @spare_equip_keys)
  end

  def lock_type
    # If locking equipped item.
    return 0 if self.index <= @equip_keys.size + 5
    # If locking unequipped item.
    return 1 if self.index > @equip_keys.size + 5
  end

  def create_contents_now
    self.contents.dispose
    maxbitmap = 8192
    dw = [width - 32, maxbitmap].min
    dh = [[height - 32, row_max * @wlh2].max, maxbitmap].min
    bitmap = Bitmap.new(dw, dh)
    self.contents = bitmap
    self.contents.font.color = normal_color
  end

  def is_equipped?(db_id)
    return $game_party.equipment.equipped?(db_id)
  end

  def refresh_lite(locked_equip)
    create_contents_now
    # Draw background
    locked_refresh(locked_equip)
  end

  def refresh_equips
    @equip_keys = $game_party.equipment.equipped
    @spare_equip_keys = $game_party.equipment.sorted
    @item_max = ordered_equipment_keys.size
  end

  def refresh(locked_equip = -1)
    @equip_keys = $game_party.equipment.equipped
    @spare_equip_keys = $game_party.equipment.sorted
    @item_max = ordered_equipment_keys.size
    create_contents_now
    # Draw background
    #if locked_equip >= 0
      locked_refresh(locked_equip)
    #else
    #  unlocked_refresh
    #end
  end

  def refresh_item(index_db, item=false)
    @equip_keys = $game_party.equipment.equipped
    @spare_equip_keys = $game_party.equipment.sorted
    index = index_db
    index = (@equip_keys + @spare_equip_keys).index(index_db) + 6 if item
    self.contents.clear_rect(item_rect(index))
    @equip_keys.size <= index ? color = PHI.color(:BROWN, 30) : color = PHI.color(:RED, 30)
    self.contents.fill_rect(item_rect(index), color)
    draw_equipment(item_rect(index), $game_party.equipment[ordered_equipment_keys[index]])
  end

  def locked_refresh(locked_equip)
    rect = item_rect(0)
    rect.x -= 32
    rect.y = item_rect(6).y
    rect.width = self.contents.width - 32
    rect.height = 32 * $game_party.all_members_safe.size
    self.contents.fill_rounded_rect(rect, PHI.color(:RED, 30), 11)
    for icon_index in 0...6
      draw_equip_selection_icon(icon_index, item_rect(icon_index).x, item_rect(icon_index).y)
    end
    for member_id in 0...$game_party.all_members_safe.size
      act = actor(member_id)
      draw_character(act.character_name, act.character_index, item_rect(0).x - 16, item_rect(member_id * 6 + 6).y + 32)
      self.contents.draw_text(item_rect(0).x - 32, item_rect(member_id * 6 + 6).y - 32, 32, 64, act.level.to_s)
    end
    if @spare_equip_keys.size > 0
      rect = item_rect(0)
      rect.y = item_rect(6).y + 32 * $game_party.all_members_safe.size
      rect.width = self.contents.width - 64 + 16
      rect.height  = 32 * (@spare_equip_keys.size / 6.0).ceil
      self.contents.fill_rounded_rect(rect, PHI.color(:BROWN, 30), 11)
    end
    for i in 0...@item_max-6
      item = $game_party.equipment[(@equip_keys + @spare_equip_keys)[i]]
      next if (@equip_keys + @spare_equip_keys)[i] == locked_equip
      draw_equipment(item_rect(i + 6), item)
    end
  end

  def item_rect(index)
    rect = Rect.new(0, 0, 0, 0)
    rect.width = 36
    rect.height = @wlh2
    rect.x = index % @column_max * (rect.width + 4)
    rect.y = index / @column_max * @wlh2
    rect.x += 58
    #rect.y += 32
    return rect
  end

  def draw_equip_selection_icon(icon_index, x, y, enabled = true)
    bitmap = Cache.system('/book/equip_stamps')
    rect = Rect.new(icon_index % 16 * 32, icon_index / 16 * 32, 32, 32)
    self.contents.blt(x, y, bitmap, rect, enabled ? 255 : 100)
  end

  def draw_equipment(rect, item, color = :CYAN)
    return if item.nil?
    draw_map_icon(item.icon_index, rect.x, rect.y)
    self.contents.font.color = PHI.color(color)
    fsize = self.contents.font.size
    rect.x -= 4
    rect.y -= 12
    self.contents.font.size = 16
    if item.level > 99
      self.contents.draw_text(rect, item.level.to_s)
    else
      self.contents.draw_text(rect, 'lvl ' + item.level.to_s)
    end
    #self.contents.font.color = normal_color
    self.contents.font.size = fsize
    #rect.y += 22
    #self.contents.draw_text(rect, 'o' * item.max_sockets)
    #self.contents.draw_text(rect.x + 38, rect.y, rect.width, rect.height, item.name)
  end

end

=end

# -------------------------------------------------------------------------------------------------------------- #
# -------------------------------------------------------------------------------------------------------------- #
# -------------------------------------------------------------------------------------------------------------- #
# -------------------------------------------------------------------------------------------------------------- #
# -------------------------------------------------------------------------------------------------------------- #
=begin
class Equipment_Help < Window_Base

  def initialize(x,y,width,height)
    super(x,y,width,height)
    @x1 = x
    @y1 = y
    @w1 = width
    @h1 = height
    @equip = nil
    @column_max = 3.0
    self.back_opacity = 255
  end

  def equip
    return $game_party.equipment[@equip]
  end

  def refresh_basic(equip_in, skip_y=0)
    self.contents.clear
    return if equip_in.nil? or equip_in == -1
    @equip = equip_in
    create_contents
    rounded_outline = Rect.new(2, 2 + skip_y, self.contents.width-4, 80)
    rounded_fill = Rect.new(4, 4 + skip_y, self.contents.width-8, 76)
    draw_primary_information(rounded_fill, rounded_outline)
    rounded_outline.y += rounded_outline.height+4
    rounded_fill.y += rounded_outline.height+4
    if $game_party.equipment.equipped?(@equip)
      stat_pool = $game_party.equipment.stats_pool(@equip)
      rounded_outline.height = get_node_height(stat_pool)
      rounded_fill.height = rounded_outline.height - 4
      draw_attribute_information(rounded_fill, rounded_outline, stat_pool, $game_party.equipment.get_equipped_member(@equip).name + "'s Pool")
      rounded_outline.y += rounded_outline.height+4
      rounded_fill.y += rounded_outline.height+4
    end
    rounded_outline.height = get_node_height(equip.stats)
    rounded_fill.height = rounded_outline.height - 4
    draw_attribute_information(rounded_fill, rounded_outline, equip.stats, equip.name + ' Pool')
    rounded_outline.y += rounded_outline.height+4
    rounded_fill.y += rounded_outline.height+4
    unless equip.element_damages.keys.empty?
      rounded_outline.height = get_node_height(equip.element_damages)
      rounded_fill.height = rounded_outline.height - 4
      draw_attribute_information(rounded_fill, rounded_outline, equip.element_damages, 'Damage')
      rounded_outline.y += rounded_outline.height+4
      rounded_fill.y += rounded_outline.height+4
    end
    unless equip.element_resistances.keys.empty?
      rounded_outline.height = get_node_height(equip.element_resistances)
      rounded_fill.height = rounded_outline.height - 4
      draw_attribute_information(rounded_fill, rounded_outline, equip.element_resistances, 'Resistance')
      rounded_outline.y += rounded_outline.height+4
      rounded_fill.y += rounded_outline.height+4
    end

  end

  def refresh(equip, index, locked_equip=nil)
    case index
      when 0 # Forge
        # Shows nothing
        create_contents
        self.contents.draw_text(Rect.new(0,0, self.contents.width, 32), 'Forge New Equipment')
        self.contents.draw_text(Rect.new(0, 32, self.contents.width, 32), 'Cannot forge an existing equipment.')
      when 1
        # Draw basic upgrade info
        create_contents
        self.contents.draw_text(Rect.new(0,0, self.contents.width, 32), 'Upgrade existing equipment')
        # Draw basic equipment info
      when 2
        # Draw enchantment info
        create_contents
        self.contents.draw_text(Rect.new(0,0, self.contents.width, 32), 'Upgrade enchantments and sockets')
        # Draw enchantment socket infos.
      when 3
        # Draw basic rename info
        create_contents
        self.contents.draw_text(Rect.new(0,0, self.contents.width, 32), 'Rename existing equipment')
      when 4
        # Draw basic disassemble info
        create_contents
        self.contents.draw_text(Rect.new(0,0, self.contents.width, 32), 'Disassemble existing equipment')
      when 5
        #refresh_basic(equip)
        create_contents
        self.contents.draw_text(Rect.new(0,0, self.contents.width, 32), 'Sort equipment in inventory')
      else
        #draw nothing, preserve the current item
        refresh_basic(equip)
    end
  end

  def get_node_height(hash)
    return 0 if hash.is_a?(Array) && hash.size == 0
    return 0 if hash.is_a?(Hash) && hash.keys.size == 0
    return (hash.size / 3.0).ceil * 32 if hash.is_a?(Array)
    return (hash.keys.size / 3.0).ceil * 32
  end

  def draw_primary_information(rect_container, rect_outline)
    clone_container = rect_container.clone
    clone_outline = rect_outline.clone
    self.contents.fill_rounded_rect(clone_outline,PHI.color(:GREY, 200))
    self.contents.fill_rounded_rect(clone_container,PHI.color(:GREY, 20))
    draw_map_icon(equip.icon_index, clone_container.x, clone_container.y)
    self.contents.font.size = 22
    clone_container.x += 32
    clone_container.y -= 32
    self.contents.draw_text(clone_container, equip.name)
    self.contents.font.size = 20
    clone_container.x += 8
    clone_container.y += 32
    d_count = 0
    d_count = 1 if equip.description.size == 0
    d_count = (equip.description.size / 30.0).ceil if d_count == 0
    for ypos in 0...d_count
      #Todo: Make line wrap for description box.
      clone_container.y += 24 * ypos
      self.contents.draw_text(clone_container, equip.description[0+ypos*30...30+ypos*30])
    end
    #Graphics.wait(1)
  end

  def draw_attribute_information(rect_container, rect_outline, pool=equip.stats, name='')
    self.contents.fill_rounded_rect(rect_outline, PHI.color(:GREY, 200))
    self.contents.fill_rounded_rect(rect_container, PHI.color(:GREY, 20))
    saved_size = self.contents.font.size
    self.contents.font.size = 12
    rect_container.y -= 14
    rect_container.x += 22
    self.contents.draw_text(rect_container.x, rect_container.y, 120, 32, name)
    rect_container.y += 14
    rect_container.x -= 22
    self.contents.font.size = saved_size
    sorted_pool = pool.sort_by{ |stat_type, stat_value| PHI::ICONS::STAT_PRIORITY.keys.include?(stat_type) ? PHI::ICONS::STAT_PRIORITY[stat_type] : 1000}
    sorted_pool.each_with_index do |value1, i|
      key, value = value1[0],value1[1]
      x2 = rect_container.x + (rect_container.width / 3 * (i % 3))#; xn += 1
      y2 = rect_container.y + (32 * (i / 3))#(i % 3 * 32))#+ ((32 * i / ))
      if PHI::ICONS::STATS[key].nil? or !PHI::ICONS::STATS.keys.include?(key) or PHI::ICONS::STATS[key][1].nil?
        p equip.name, ' failed key access: draw_attribute_information ', key.to_s + ' ' + value.to_s
        next
      end
      color = self.contents.font.color.clone
      self.contents.font.color = PHI::ICONS::STATS[key][1]
      size = self.contents.font.size
      self.contents.font.size = 14
      draw_icon(PHI::ICONS::STATS[key][0], x2, y2+2)
      self.contents.draw_text(x2, y2-16,
                              self.contents.text_size(key.to_s.upcase).width, 32, key.to_s.upcase)
      self.contents.font.size = size
      x2 += 32
      self.contents.draw_text(x2+4, y2, 40, 32, value.to_s+'%')
      self.contents.font.color = color
      #Graphics.update if i %  == 0
    end
  end

  def draw_node_information(rect_container, rect_outline, hash, title, priority_hash=nil)
    self.contents.fill_rounded_rect(rect_outline, PHI.color(:GREY, 200))
    self.contents.fill_rounded_rect(rect_container, PHI.color(:GREY, 20))
    saved_size = self.contents.font.size
    self.contents.font.size = 12
    rect_container.y -= 12
    rect_container.x += 22
    bc = rect_container.height
    rect_container.height = 32
    self.contents.draw_text(rect_container, title)
    rect_container.y += 12
    rect_container.x -= 22
    rect_container.height = bc
    self.contents.font.size = saved_size
    hash.sort_by { |key, value| PHI::ICONS::STAT_PRIORITY[key] }.each_with_index do |(key,value),index|
      x2 = rect_container.x + ((((rect_container.width/@column_max).ceil * index) % @column_max.to_i) * (rect_container.width / @column_max))
      y2 = rect_container.y + (32*(index / @column_max.to_i))
      color = self.contents.font.color.clone
      self.contents.font.color = PHI::ICONS::STATS[key][1]
      size = self.contents.font.size
      self.contents.font.size = 11
      draw_icon(PHI::ICONS::STATS[key][0], x2, y2)
      self.contents.draw_text(x2, y2, 32, 32, key.to_s.upcase)
      self.contents.font.size = size
      value[0].is_a?(Array) ? out_val = value[0][0] : out_val = value[0]
      self.contents.draw_text(x2+26, y2, 40, 32, out_val.to_s)
      self.contents.font.color = color
    end
  end

end
=end