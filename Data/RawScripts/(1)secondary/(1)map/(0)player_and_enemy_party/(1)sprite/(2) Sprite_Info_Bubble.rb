$sight_opacity = 125
class Sprite_Info_Bubble < Sprite
  attr_accessor :update_stop
  
  def initialize(viewport)
    super(viewport)
    self.bitmap = Bitmap.new(100,32)
    self.ox = self.bitmap.width / 2
    self.oy = self.bitmap.height * 2
    @update_stop = false
  end
  
  # This starts the bubble.
  def draw_bubble(relative_x,relative_y,color,b_data)
    self.visible = true
    self.x = relative_x
    self.y = relative_y
    self.z = 9009
    @counter = 0 if @counter.nil?
    if !bubble_data_match?(b_data)
      @b_data = b_data
      create_bitmap_rect(color)
      @counter += 1
      bitmap.draw_text(src_rect,"#{b_data[0]} #{b_data[1].name}")
    end
    @update_stop = true
  end
  
  def bubble_data_match?(b_data)
    return false if @b_data.nil? or b_data.nil?
    return ((b_data[1].name == @b_data[1].name) and (b_data[0] == @b_data[0]))
  end
  
  def move(relative_x,relative_y)
    self.x = relative_x
    self.y = relative_y
    self.z = 9001
  end
  
  def create_bitmap_rect(color)
    self.bitmap.clear
    # Updates sprite bitmap
    @color = color
    @color.alpha = $sight_opacity
    self.bitmap.fill_rect(src_rect,@color)
    @color.alpha = (@color.alpha * 0.65).to_i
    self.bitmap.fill_rect(src_rect.x+2,src_rect.y+2,src_rect.width-4,src_rect.height-4,@color)
    @color.alpha = (@color.alpha * 0.65).to_i
    self.bitmap.fill_rect(src_rect.x+4,src_rect.y+4,src_rect.width-8,src_rect.height-8,@color)
  end
  
  def update
    super
  end
  
  def dispose
    super
  end
    
  # This bar will be for different hp bars, timers, and other bars.
  def display_bar(val1,val2)
    # do maths to make bar filled from val1 as base,
    #   to val 2 filling the bar.
#~     self.bitmap.fill_rect
  end
  
end