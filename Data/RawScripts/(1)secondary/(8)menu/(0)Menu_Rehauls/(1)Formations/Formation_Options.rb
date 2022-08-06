class Formation_Options < Window_Selectable

  def initialize(x,y,width,height)
    super(x,y,width,height)
    @item_max = PHI::Formation.formations.keys.size - 1
    @column_max = 1
    @wlh2 = 32
    refresh
  end

  def update
    super
  end

  def dispose
    super
  end

  def refresh
    self.contents.clear
    @data = PHI::Formation.formations
    self.index = 0
    create_contents
    for i in 0...@item_max
      if @data.keys.include?(i)
        draw_active(i)
      else
        draw_locked(i)
      end
    end
  end

  def draw_active(index)
    rect = item_rect(index)
    if @data[index].keys.include?(:name)
      index == PHI::Formation.primary ? color = PHI.color(:RED) : color = normal_color
      self.contents.font.color = color
      self.contents.font.color.alpha = 255
      self.contents.draw_text(rect, @data[index][:name])
    end
  end

  def draw_locked(index)
    rect = item_rect(index)
    self.contents.font.color = normal_color
    self.contents.font.color.alpha = 100
    self.contents.draw_text(rect, (index+1).to_s + ". Locked")
  end


end