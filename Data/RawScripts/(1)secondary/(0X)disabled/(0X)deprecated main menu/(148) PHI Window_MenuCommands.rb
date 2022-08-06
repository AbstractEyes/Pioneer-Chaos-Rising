=begin
class Window_MenuCommands < Window_Selectable
#~       :unused => 176,
#~       :items  => 144,
#~       :skill  => 1597,
#~       :class =>  159,
#~       :equip  => 898,
#~       :status => 1598,
#~       :save   => 1567,
#~       :system => 1582,

  def initialize(x,y,width,height)
    super(x,y,width,height,32)
    self.index = 0
    s1 = [1627,PHI::Vocab::MENU_ITEM]
    s2 = [1597,PHI::Vocab::MENU_SKILL]
    s3 = [898,PHI::Vocab::MENU_EQUIP]
    s4 = [1598,PHI::Vocab::MENU_STATUS]
    s5 = [1567,PHI::Vocab::MENU_SAVE]
    s6 = [1582,PHI::Vocab::MENU_CONFIG]
    s7 = [1915,PHI::Vocab::MENU_EXIT]
    s8 = [1903,PHI::Vocab::MENU_PARTY]
    s9 = [1670,PHI::Vocab::MENU_FORMATION]
    @data = [s1, s2, s3, s4, s8, s9, s5, s6, s7]
    refresh(self.index)
  end
  
  def command
    return @data[self.index][1]
  end
  
  def refresh(index)
    self.contents.clear
    @wlh2 = 32
    @column_max = @data.size
    self.index = index
    @item_max = @data.size
    create_contents
    for i in 0...@item_max
      draw_option(i)
    end
  end
  
  def draw_option(i)
    icon_id = @data[i][0]
    rect = item_rect(i)
    color = PHI.color(:BLACK)
    color.alpha = 125
    color2 = PHI.color(:WHITE)
    rect.width += 4
    self.contents.fill_rect(rect, color2)
    rect.x += 2
    rect.y += 2
    rect.width -= 4
    rect.height -= 4
    self.contents.fill_rect(rect, color)
    self.draw_map_icon(icon_id,rect.x,rect.y)
    rect.x += 33
    self.contents.font.size = 15
  end
  
end
=end