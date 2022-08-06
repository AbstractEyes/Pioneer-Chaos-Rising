class Equip_Option_Selection < Window_Base

  def initialize(x,y)
    super(x,y, 140, 140)
    self.opacity = 0
    create_contents
  end

  def refresh(x,y)
    self.x = x-32
    self.y = y-32
    self.contents.clear
    self.contents.fill_rect(0,0,32*3,32*3,PHI.color(:GREY, 100))
    draw_selection_icon(1, 32, 0, true)
    draw_selection_icon(5, 0, 32, true)
    draw_selection_icon(3, 32, 64, true)
    draw_selection_icon(2, 64, 32, true)
  end

  def draw_selection_icon(icon_index, x, y, enabled = true)
    bitmap = Cache.system('/book/equip_stamps')
    rect = Rect.new(icon_index % 16 * 32, icon_index / 16 * 32, 32, 32)
    self.contents.blt(x, y, bitmap, rect, enabled ? 255 : 100)
  end

end