class Sprite_Cursor < Sprite
  
  def initialize(viewport)
    super(viewport)
    @n_rect = Rect.new(0,0,0,0)
    self.bitmap = Cache.system("Battle_Cursor")
    @o_up = false
    @o_down = true
    @o_counter = 0
    create_background(@n_rect)
    self.visible = false
  end
  
  def create_background(rect)
    @background.dispose unless @background.nil?
    @background = nil
    @background = ::Sprite.new(viewport)
    @background.x = rect.x
    @background.y = rect.y
    @background.z = self.z
    return if rect.width == 0 or rect.height == 0
    b_bitmap = Bitmap.new(rect.width,rect.height)
    b_bitmap.gradient_fill_rect(b_bitmap.rect,PHI.color(:LTGREY),PHI.color(:WHITE))
    n_rect = b_bitmap.rect.clone
    n_rect.x += 1
    n_rect.y += 1
    n_rect.width -= 2
    n_rect.height -= 2
    b_bitmap.gradient_fill_rect(n_rect,PHI.color(:GREY),PHI.color(:LTGREY))
    n_rect = b_bitmap.rect.clone
    n_rect.x += 1
    n_rect.y += 1
    n_rect.width -= 2
    n_rect.height -= 2
    b_bitmap.gradient_fill_rect(n_rect,PHI.color(:LTGREY),PHI.color(:WHITE))
    n_rect.x += 1
    n_rect.y += 1
    n_rect.width -= 2
    n_rect.height -= 2
    color = PHI.color(:BLACK)
    color.alpha = 50
    b_bitmap.fill_rect(n_rect,color)
    @background.bitmap = b_bitmap
  end
  
  def visible=(bool)
    super
    if !@background.nil?
      @background.visible = bool
    end
  end
  
  def rect=(new_rect)
    self.x=n_rect.x-12
    self.y=n_rect.y-12
    self.z=z+1
    @background.x = n_rect.x+10
    @background.y = n_rect.y+8
    @background.z = z
    create_background(n_rect)
    @n_rect = n_rect
  end
  
  def rect
    return @n_rect
  end
  
  def dispose
    self.bitmap.dispose
    @background.bitmap.dispose if !@background.bitmap.nil?
    @background.dispose
    super
  end
  
  def update
    update_cursor
    super
  end
  
  def opacity=(new_opacity)
    super
    @background.opacity = new_opacity
  end
    
  def update_cursor
    @o_counter += 1
    if @o_down
      if @o_counter % 7 == 0
        self.oy += 1
        @background.opacity += 25
      end
      if self.oy >= 8
        @o_down = false
        @o_up = true
        @o_counter = 0
      end
    elsif @o_up
      if @o_counter % 7 == 0
        self.oy -= 1
        @background.opacity -= 25
      end
      if self.oy <= 0
        @o_down = true
        @o_up = false
        @o_counter = 0
      end
    end
  end

end