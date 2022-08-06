def load_data(filename)
end
def save_data(filename)
end

class Bitmap
  def initialize(width=nil,height=nil)
  end
  def dispose
  end
  def disposed?
  end
  def width
  end
  def height
  end
  def rect
  end
  def blt(x,y,src_bitmap,src_rect,opacity)
  end
  def stretch_blt(dest_rect, src_bitmap, src_rect)
  end
  def fill_rect(x=nil, y=nil, width=nil, height=nil, color=nil)
  end
  def gradient_fill_rect(x=nil, y=nil, width=nil, height=nil, color1=nil, color2=nil)
  end
  def clear
  end
  def clear_rect(x,y=nil,width=nil,height=nil)
  end
  def get_pixel(x,y)
  end
  def set_pixel(x,y,color)
  end
  def hue_change(hue)
  end
  def blur
  end
  def radial_blur(angle,division)
  end
  def draw_text(x,y,width,height,text)
  end
  def text_size(text)
  end
  attr_accessor :font
end

class Color
  def initialize(red,green,blue,alpha=255)
  end
  attr_accessor :red
  attr_accessor :green
  attr_accessor :blue
  attr_accessor :alpha
end

class Font
  def initialize(name, size)
  end
  def exist?(name)
  end
  attr_accessor :name
  attr_accessor :size
  attr_accessor :bold
  attr_accessor :italic
  attr_accessor :shadow
  attr_accessor :color
  attr_accessor :default_name
  attr_accessor :default_size
  attr_accessor :default_bold
  attr_accessor :default_italic
  attr_accessor :default_shadow
  attr_accessor :default_color
end

class Plane
  def initialize(viewport)
  end
  def dispose
  end
  def disposed?
  end
  attr_accessor :bitmap
  attr_accessor :viewport
  attr_accessor :visible
  attr_accessor :z
  attr_accessor :ox
  attr_accessor :oy
  attr_accessor :zoom_x
  attr_accessor :zoom_y
  attr_accessor :opacity
  attr_accessor :blend_type
  attr_accessor :color
  attr_accessor :tone
end

class Rect
  def initialize(x,y,width,height)
  end
  def set(x,y,width,height)
  end
  attr_accessor :x
  attr_accessor :y
  attr_accessor :width
  attr_accessor :height
end

class Sprite
  def initialize(viewport=nil)
  end
  def dispose
  end
  def disposed?
  end
  def flash(color,duration)
  end
  def update
  end
  def width
  end
  def height
  end
  attr_accessor :bitmap
  attr_accessor :src_rect
  attr_accessor :viewport
  attr_accessor :visible
  attr_accessor :x
  attr_accessor :y
  attr_accessor :z
  attr_accessor :ox
  attr_accessor :oy
  attr_accessor :zoom_x
  attr_accessor :zoom_y
  attr_accessor :angle
  attr_accessor :wave_amp
  attr_accessor :wave_length
  attr_accessor :wave_speed
  attr_accessor :wave_phase
  attr_accessor :mirror
  attr_accessor :bush_depth
  attr_accessor :bush_opacity
  attr_accessor :opacity
  attr_accessor :blend_type
  attr_accessor :color
  attr_accessor :tone
end

class Table
  def initialize(xsize,ysize=1,zsize=1)
  end
  def resize(xsize,ysize=1,zsize=1)
  end
  def xsize
  end
  def ysize
  end
  def zsize
  end
  def []
  end
end

class Tilemap
  def initialize(viewport)
  end
  def dispose
  end
  def disposed?
  end
  def update
  end
  attr_accessor :bitmaps
  attr_accessor :map_data
  attr_accessor :flash_data
  attr_accessor :passages
  attr_accessor :viewport
  attr_accessor :visible
  attr_accessor :ox
  attr_accessor :oy
end

class Tone
  def initialize(red,green,blue,grey=255)
  end
  def set(red,green,blue,grey=255)
  end
  attr_accessor :red
  attr_accessor :green
  attr_accessor :blue
  attr_accessor :grey
end

class Viewport
  def initialize(x,y,width,height)
  end
  def dispose
  end
  def disposed?
  end
  def flash(color,duration)
  end
  def update
  end
  attr_accessor :rect
  attr_accessor :visible
  attr_accessor :z
  attr_accessor :ox
  attr_accessor :oy
  attr_accessor :color
  attr_accessor :tone
end

class Window
  def initialize(viewport=nil)
  end
  def dispose
  end
  def disposed?
  end
  def update
  end
  attr_accessor :windowskin
  attr_accessor :contents
  attr_accessor :viewport
  attr_accessor :cursor_rect
  attr_accessor :active
  attr_accessor :visible
  attr_accessor :pause
  attr_accessor :x
  attr_accessor :y
  attr_accessor :width
  attr_accessor :height
  attr_accessor :z
  attr_accessor :ox
  attr_accessor :oy
  attr_accessor :opacity
  attr_accessor :back_opacity
  attr_accessor :contents_opacity
  attr_accessor :openness
end