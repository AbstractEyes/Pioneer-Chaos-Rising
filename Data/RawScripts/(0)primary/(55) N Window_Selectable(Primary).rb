class Window_Selectable < Window_Base
  #--------------------------------------------------------------------------
  # * initialize
  #--------------------------------------------------------------------------
  alias :phi_pre_window_command_mod_initialize :initialize
  def initialize(x,y,width,height,spacing=12)	
    @arrow_image = Cache.system("bullet_arrow_right")
    @arrow_sprite = Sprite.new
    @arrow_sprite.bitmap = Bitmap.new(@arrow_image.width + 7, @arrow_image.height)
    @arrow_sprite.z = 999
    @sprite_last_draw_x = 0
    @sprite_inc_x = 1
    @intern_frame_count = 0
    @update_pointer = true
    @background_sprite = Sprite.new
#~     @background_sprite.bitmap.clear
    @background_sprite.bitmap = Bitmap.new(32,32)
    @background_sprite.z = 999
    @background_sprite.opacity = 150
    phi_pre_window_command_mod_initialize(x,y,width,height,spacing)
    @arrow_sprite.visible = self.visible
    @background_sprite.visible = self.visible
  end
  
  def create_background_bitmaps(draw_count)
    cur_rect = item_rect(@index)
    # Create bitmap
    b_bitmap = Bitmap.new(cur_rect.width, cur_rect.height)
    # Create vertical gradient base
    n_rect = b_bitmap.rect.clone
    b_bitmap.gradient_fill_rect(b_bitmap.rect,PHI.color(:DRKGREY),PHI.color(:LTGREY),true)
    # Fill the outline with the proper sized rect.
    n_rect.x += 2
    n_rect.width -= 2
    n_rect.height -= cur_rect.height / 5#draw_count
    color = PHI.color(:BLACK)
    color.alpha = 38
    b_bitmap.fill_rect(n_rect,color)
    return b_bitmap if draw_count == 0
    rectangles = n_rect.width / draw_count
    for i in 1...rectangles
      c_rect = n_rect.clone
      c_rect.x += i*rectangles
      c_rect.width -= i
      c_rect.height += i
      b_bitmap.fill_rect(c_rect,color)
    end
    return b_bitmap
  end
  #--------------------------------------------------------------------------
  # * dispose
  #--------------------------------------------------------------------------
  def dispose
		super
    @arrow_sprite.dispose unless @arrow_sprite.nil?
    @background_sprite.dispose unless @background_sprite.nil?
  end
  #--------------------------------------------------------------------------
  # * close
  #--------------------------------------------------------------------------
  def close
    super
    @arrow_sprite.visible = false unless @arrow_sprite.nil?
    @background_sprite.visible = false unless @background_sprite.nil?
  end
  #--------------------------------------------------------------------------
  # * open
  #--------------------------------------------------------------------------
  def open
    super
    @arrow_sprite.visible = true unless @arrow_sprite.nil?
    @background_sprite.visible = true unless @background_sprite.nil?
  end
  #--------------------------------------------------------------------------
  # * visible=
  #--------------------------------------------------------------------------
  def visible=(value)
    super
#~     @update_pointer = value
#~     @arrow_sprite.visible = value ? (@index != -1) : value
#~     @background_sprite.visible = value ? (@index != -1) : value
#~     @background_sprite.opacity = 150
  end
  #--------------------------------------------------------------------------
  # * active=
  #--------------------------------------------------------------------------
  def active=(value)
    super
    @update_pointer = value
    @arrow_sprite.visible = value ? (@index != -1) : value
    @background_sprite.visible = value ? (@index != -1) : value
  end
  #--------------------------------------------------------------------------
  # * cursor_rect= (OVERWRITTEN)
  #--------------------------------------------------------------------------
  def cursor_rect=(rect)
    offset_y = self.viewport.nil? ? 0 : self.viewport.rect.y
    offset_x = self.viewport.nil? ? 0 : self.viewport.rect.x - self.viewport.ox
    boost_y = @arrow_image.height >= 29 ? 0 : 29 - @arrow_image.height
    @arrow_sprite.x = 5 + rect.x + self.x - (@arrow_image.width / 2) + offset_x
    @arrow_sprite.y = rect.y + self.y + (@arrow_image.height / 2) + offset_y  + boost_y
    @background_sprite.x = 16 + rect.x + self.x + offset_x# - (@background_sprite_image.width / 2)
    @background_sprite.y = 16 + rect.y + self.y + offset_y# + (@background_sprite_image.height / 2)
  end
  #--------------------------------------------------------------------------
  # * update_cursor
  #--------------------------------------------------------------------------
  alias phi_window_command_mod_update_cursor update_cursor
  def update_cursor
    if @index.is_a?(Integer)
      phi_window_command_mod_update_cursor
      rect = item_rect(@index)
      @background_sprite.bitmap = Bitmap.new(rect.width, rect.height) if @background_sprite.width != rect.width or @background_sprite.height != rect.height
      @intern_frame_count += 1
      @intern_frame_count = 0 if @intern_frame_count > 2000
      iterate_sprite_update
      draw_cursor_pointer
      draw_cursor_background
    end
  end
  def iterate_sprite_update
    return unless @update_pointer
    return unless (@intern_frame_count % 5) == 0
    @arrow_sprite.bitmap.clear
    return if @index == -1
    return unless self.active or self.visible
    if @sprite_last_draw_x == 7
      @sprite_inc_x = -1
    elsif @sprite_last_draw_x == 0
      @sprite_inc_x = 1
    end
    x = @sprite_last_draw_x + @sprite_inc_x
    @sprite_last_draw_x = x
  end
  #--------------------------------------------------------------------------
  # * draw_pointer
  #--------------------------------------------------------------------------
  def draw_cursor_pointer
    return unless @update_pointer
    return unless (@intern_frame_count % 5) == 0
    @arrow_sprite.bitmap.clear
    return if @index == -1
    return unless self.active or self.visible
    # Pointer
    @arrow_sprite.bitmap.blt(x, 0, @arrow_image, @arrow_image.rect)
  end
  
  def draw_cursor_background
    return unless @update_pointer
    return unless (@intern_frame_count % 5) == 0
    @background_sprite.bitmap.clear
    return if @index == -1
    return unless self.active or self.visible
    # Background
    opacity = @background_sprite.opacity + @sprite_inc_x * 16
    @background_sprite_image = create_background_bitmaps(opacity / 25)
    @background_sprite.bitmap.blt(0, 0, @background_sprite_image, @background_sprite_image.rect)
    @background_sprite.opacity = opacity
  end
  
end