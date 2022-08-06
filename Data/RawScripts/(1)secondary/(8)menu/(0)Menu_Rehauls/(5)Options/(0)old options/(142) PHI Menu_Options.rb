
class Menu_Categories < Window_Base
  
  def initialize(x,y,width,height)
    super(x,y,width,height)
    refresh
  end
  
  def categories
    return @data
  end
  
  def refresh
    self.contents.clear
    @data = []
    for i in 0...PHI::Vocab::OPTIONS.size
      @data.push PHI::Vocab::OPTIONS[i][0]
    end
    for i in 0...@data.size
      self.contents.draw_text(0,i*50,self.contents.width,50, @data[i])
    end
  end
  
end

class Menu_Options < Window_Selectable
  
  def initialize(x,y,width,height,spacing=0)
    super(x,y,width,height,spacing)
    self.active = false
  end
  
  def refresh(bound_key)
    self.contents.clear
    @data = []
    base = PHI::Vocab::OPTIONS[bound_key][1]
    for i in 0...base.size
      @data.push(base[i])
    end
    @column_max = @data.size
    @column_max = 1 if @column_max == 0
    @item_max = @data.size
    create_contents
    for i in 0...@item_max
      draw_item(i)
    end
  end
  
  def draw_item(index)
    rect = item_rect(index)
    if @data[index][0]
      color = PHI.color(:BLACK)
      color.alpha = 200
    else
      color = PHI.color(:WHITE)
    end
    self.contents.fill_rect(rect, color) if @data[index][0]
    self.contents.draw_text(rect, @data[index][1])
  end
  
end