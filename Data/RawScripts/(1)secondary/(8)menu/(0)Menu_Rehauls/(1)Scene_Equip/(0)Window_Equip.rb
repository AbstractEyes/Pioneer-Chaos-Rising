class Window_Equip_Overhaul < Window_Selectable

  def initialize(x,y,w,h)
    super(x,y,w,h)
    self.opacity = 0
    @last_index = 0
  end

  def update
    super
    if self.index != @last_index
      @last_index = self.index
      draw_equipment_stats
    end
  end

  def draw_equipment_stats
    #equip = @actor.equip

  end

  def stat_rect(i)
    rect = item_rect(i)
    rect.width / 3
    rect.height = 32
    rect.x = 32 * (i / 3)
    rect.y = $screen_height / 2 + (32 * (i % 3))
    return item_rect(i)
  end

  def refresh(actor_index)
    @actor = $game_party.members[actor_index]
    @item_max = 5
    @column_max = 1
    create_contents
    draw_equipment(item_rect(0), 'Weapon 1', @actor.equips[0], :RED)
    draw_equipment(item_rect(1), 'Weapon 2', @actor.equips[1], :RED)
    draw_equipment(item_rect(2), 'Head', @actor.equips[2], :CYAN)
    draw_equipment(item_rect(3), 'Coat', @actor.equips[3], :CYAN)
    draw_equipment(item_rect(4), 'Chest', @actor.equips[4], :CYAN)
  end

  def draw_stat(rect, stat_key)
    case stat_key
      when :hp
      when :mp
      when :stam
      when :atk
      when :agi
      when :int
      when :def
      when :cri
      when :cri_mul
      when :sta_res
    end
  end

  def draw_equipment(rect, name, item, color = :CYAN)
    font = self.contents.font.size
    self.contents.font.size = 16
    self.contents.font.color = PHI.color(color)
    self.contents.draw_text(rect.x, rect.y-10,rect.width,rect.height, name)
    self.contents.font.size = font
    rect.x += 60
    rect.width -= 60
    return if item.nil?
    draw_map_icon(item.icon_index, rect.x, rect.y)
    self.contents.draw_text(rect.x + 38, rect.y, rect.width, rect.height, item.name)
  end

end