class Enchant_Battery_Interface < Window_Base

  def initialize(x,y,w,h)
    super(x,y,w,h)
  end

  def refresh(db_id, soc_index, battery)
    @equip = $game_party.equipment[db_id]
    @socket_index = soc_index
    @capacity = @equip.socket_density(@socket_index)
    @battery = battery
    create_contents
    #draw "positive traits"
    for i in 0...@capacity*2
      #draw backgrounds
      if i < @capacity
        self.contents.fill_rect(get_rect(i), Color.new(255,60, 60, 80))
      else
        self.contents.fill_rect(get_rect(i), Color.new(60,60, 255, 80))
      end
    end
    for i in 0...@battery.fragments.size
      rect = get_rect(i)
      rect.x += 32
      fragment = @battery.fragments[i]
      self.contents.font.color = fragment.value_color
      size = self.contents.font.size
      self.contents.font.size = 18
      self.contents.draw_text(rect, fragment.short_name)
      self.contents.font.size = size
      rect.x -= 32
      self.draw_element(rect, fragment)
    end
    #draw list of positive items + costs
    #draw "negative traits"
    #draw list of negative items + costs
  end

  def get_rect(i)
    rect = Rect.new(0, i * 32, self.contents.width, 24)
    return rect
  end

  def draw_element(rect, fragment)
    p 'icon index',  fragment.icon_index
    self.draw_map_icon(fragment.icon_index, rect.x, rect.y, true)
    self.contents.font.color = fragment.color
    size = self.contents.font.size
    self.contents.font.size = 16 if fragment.ele_id > -1
    self.contents.draw_text(rect, fragment.sym_name)
    self.contents.font.size = size
  end

  def draw_stat(rect, fragment)

  end

end

class Enchant_Battery_Confirmation < Window_Base

  def initialize(x,y,w,h)
    super(x,y,w,h)
  end

  def refresh(wrapper)
    create_contents
    costs = wrapper.costs
    self.contents.draw_text(0, 0, self.contents.width, 24, 'Costs:')
    rect = Rect.new(32, 30, self.contents.width, 24)
    if costs[0] > 0
      rect = nudge(rect)
      self.draw_icon(self.currency_icon_index(:markers), rect.x - 32, rect.y)
      self.contents.draw_text(rect, 'MARKERS ' + costs[0].to_s)
    end
    if costs[1] > 0
      rect = nudge(rect)
      self.draw_icon(self.currency_icon_index(:collateral), rect.x - 32, rect.y)
      self.contents.draw_text(rect, 'COLLATERAL ' + costs[1].to_s)
    end
    if costs[2] > 0
      rect = nudge(rect)
      self.draw_icon(self.currency_icon_index(:carbon), rect.x - 32, rect.y)
      self.contents.draw_text(rect, 'CARBON ' + costs[2].to_s)
    end
    if costs[3] > 0
      rect = nudge(rect)
      self.draw_icon(self.currency_icon_index(:metal), rect.x - 32, rect.y)
      self.contents.draw_text(rect, 'METAL ' + costs[3].to_s)
    end
    if costs[4] > 0
      rect = nudge(rect)
      self.draw_icon(self.currency_icon_index(:elemental), rect.x - 32, rect.y)
      self.contents.draw_text(rect, 'ELEMENTAL ' + costs[4].to_s)
    end
    if costs[5] > 0
      rect = nudge(rect)
      self.draw_icon(self.currency_icon_index(:chaos), rect.x - 32, rect.y)
      self.contents.draw_text(rect, 'CHAOS ' + costs[5].to_s)
    end
    rect = nudge(rect)
    self.contents.draw_text(rect, 'Press: confirm'  + ' to complete enchantment.')

  end

  def nudge(rect)
    rect.y += 24
    return rect
  end


end
