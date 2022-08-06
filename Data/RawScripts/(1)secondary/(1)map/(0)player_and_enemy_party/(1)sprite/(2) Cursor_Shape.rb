class Cursor_Bitmap
  
  def initialize
    @direction = -1
    @base_bitmap = Bitmap.new(32,32)
  end
  # --------- #
  # Get Shape #
  # -------------------------------------------------------------------- #
  # Draws the bitmap shape with the specified parameters for the cursor, #
  # and returns the completed bitmap object.                             #
  # -------------------------------------------------------------------- #
  # (x,y) center point coordinates
  # shape = int value
  #   0 = rectangle
  #   1 = line
  #   2 = circle
  #   3 = cone
  #   4 = cross
  # size = size variation
  # color_background = background color of shape
  # color_outline = outline color of shape
  # direction = direction variation for certain (1)shapes
  def get_shape(x, y, shape, size, 
                color_background, color_outline=nil, direction=-1)
    @x, @y = x, y
    @shape_manager, @direction, @size = shape, direction, size
    @color_background, @color_outline = color_background, color_outline
    case @shape_manager
    when 0
      draw_rectangle
    when 1
      draw_line
    when 2
      draw_circle
    when 3
      draw_cone
    when 4
      draw_cross
    end
    return @base_bitmap
  end
  
  def draw_cross
    @base_bitmap = Bitmap.new(@size*32,@size*32)
    #draw_rectangle(@x-@size*32/2, @y-@size/2*32, 32,       @size*32)
    #draw_rectangle(@x+@size*32/2, @y-@size/2*32, @size*32, 32      )
  end
  
  def draw_rectangle
    @base_bitmap = Bitmap.new(@size*32,@size*32)
    @width = 32
    @height = 32
    if !@color_outline.nil?
      outline_rect = Rect.new(@x,@y,@width,@height)
      background_rect = Rect.new(@x+4,@y+4,@width-8,@height-8)
      @base_bitmap.fill_rect(outline_rect, @color_outline)
      @base_bitmap.fill_rect(background_rect, @color_background)
    else
      background_rect = Rect.new(@x,@y,@width,@height)
      @base_bitmap.fill_rect(background_rect)
    end
  end
  
  def draw_line
  end
  
  def draw_circle
  end
  
  def draw_cone
  end
  
end