class Window_MessageScroll < Window_Selectable
  
  def initialize(x,y,width,height)
    super(x,y,width,height)
    @messages = []
    @index = -1
    self.active = false
    @item_max = 1
    @column_max = 1
    self.visible = false
    @wlh2 = 14
    self.opacity = 120
  end
  
  def add(message)
    @messages.push message
    $game_system.stored_messages.push message
    if @messages.size > 10
      @messages.shift
    end
    refresh
  end
  
  def refresh
    self.contents.clear
    @item_max = @messages.size
    @index = @item_max - 1
    create_contents
    for i in 0...@item_max
      draw_message(i)
    end
  end
  
  def draw_message(i)
    self.contents.font.size = 12
    self.contents.draw_text(item_rect(i), @messages[i])
  end
  
end