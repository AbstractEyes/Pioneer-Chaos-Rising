#==============================================================================
# ** Cache
#------------------------------------------------------------------------------
#  This module loads each of graphics, creates a Bitmap object, and retains it.
# To speed up load times and conserve memory, this module holds the created
# Bitmap object in the internal hash, allowing the program to return
# preexisting objects when the same bitmap is requested again.
#==============================================================================

module Cache
  #--------------------------------------------------------------------------
  # * Get Animation Graphic
  #     filename : Filename
  #     hue      : Hue change value
  #--------------------------------------------------------------------------
  def self.animation(filename, hue)
    load_bitmap("Graphics/Animations/", filename, hue)
  end
  #--------------------------------------------------------------------------
  # * Get Battler Graphic
  #     filename : Filename
  #     hue      : Hue change value
  #--------------------------------------------------------------------------
  def self.battler(filename, hue)
    load_bitmap("Graphics/Battlers/", filename, hue)
  end
  #--------------------------------------------------------------------------
  # * Get Character Graphic
  #     filename : Filename
  #--------------------------------------------------------------------------
  def self.character(filename)
    load_bitmap("Graphics/Characters/", filename)
  end
  #--------------------------------------------------------------------------
  # * Get Face Graphic
  #     filename : Filename
  #--------------------------------------------------------------------------
  def self.face(filename)
    load_bitmap("Graphics/Faces/", filename)
  end
  def self.element
    load_bitmap("Graphics/System/", "elements.png")
  end
  #--------------------------------------------------------------------------
  # * Get Parallax Background Graphic
  #     filename : Filename
  #--------------------------------------------------------------------------
  def self.parallax(filename)
    load_bitmap("Graphics/Parallaxes/", filename)
  end
  #--------------------------------------------------------------------------
  # * Get Picture Graphic
  #     filename : Filename
  #--------------------------------------------------------------------------
  def self.picture(filename)
    load_bitmap("Graphics/Pictures/", filename)
  end
  #--------------------------------------------------------------------------
  # * Get System Graphic
  #     filename : Filename
  #--------------------------------------------------------------------------
  def self.system(filename)
    load_bitmap("Graphics/System/", filename)
  end
  
  def self.new_bitmap(tag,width,height)
    load_bitmap_2(tag,width,height)
  end

  #--------------------------------------------------------------------------
  # * Clear Cache
  #--------------------------------------------------------------------------
  def self.clear
    @cache = {} if @cache == nil
    @new_cache = {} if @new_cache == nil
    @cache.clear
    @new_cache.clear
    GC.start
  end
  #--------------------------------------------------------------------------
  # * Load Bitmap
  #--------------------------------------------------------------------------
  def self.load_bitmap(folder_name, filename, hue = 0)
    @cache = {} if @cache == nil
    path = folder_name + filename
    if not @cache.include?(path) or @cache[path].disposed?
      if filename.empty?
        @cache[path] = Bitmap.new(32, 32)
      else
        @cache[path] = Bitmap.new(path)
      end
    end
    if hue == 0
      return @cache[path]
    else
      key = [path, hue]
      if not @cache.include?(key) or @cache[key].disposed?
        @cache[key] = @cache[path].clone
        @cache[key].hue_change(hue)
      end
      return @cache[key]
    end
  end
  
  #--------------------------------------------------------------------------
  # New Bitmap
  #--------------------------------------------------------------------------
  def self.load_bitmap_2(tag,width,height)
    @new_cache = [] if @new_cache == nil
    tag = tag.to_sym
    if !@new_cache.keys.include?(tag)
      bitmap = Bitmap.new(width,height)
      @new_cache[tag] = bitmap
    else
      current_bitmaps = @new_cache[tag]
      current_bitmaps[tag]
      if get.color != color or 
            get.width != width or
            get.height != height
        get.width = width
        get.height = height
      end
    end
    return @new_cache[tag]
  end
  
end
