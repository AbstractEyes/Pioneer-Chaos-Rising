#==============================================================================
# ** Window_Selectable
#------------------------------------------------------------------------------
#  This window contains cursor movement and scroll functions.
#==============================================================================

class Window_Selectable < Window_Base
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_reader   :item_max                 # item count
  attr_reader   :column_max               # digit count
  attr_reader   :index                    # cursor position
  attr_reader   :help_window              # help window
  attr_accessor :new_cursor
  #--------------------------------------------------------------------------
  # * Object Initialization
  #     x       : window X coordinate
  #     y       : window Y coordinate
  #     width   : window width
  #     height  : window height
  #     spacing : width of empty space when items are arranged horizontally
  #--------------------------------------------------------------------------
  def initialize(x, y, width, height, spacing = 32)
    @item_max = 1
    @column_max = 1
    @index = -1
    @spacing = spacing                               
    @wlh2 = WLH
    super(x, y, width, height)
  end
  #--------------------------------------------------------------------------
  # * Create Window Contents
  #--------------------------------------------------------------------------
  def create_contents
    self.contents.dispose
    maxbitmap = 8192
    dw = [width - 32, maxbitmap].min
    dw = 1 if dw <= 0
    dh = [[height - 32, row_max * @wlh2].max, maxbitmap].min
    dh = 1 if dh <= 0
    bitmap = Bitmap.new(dw, dh)
    self.contents = bitmap
    self.contents.font.color = normal_color
  end
  #--------------------------------------------------------------------------
  # * Get Top Row
  #--------------------------------------------------------------------------
  def top_row
    return self.oy / @wlh2
  end
  #--------------------------------------------------------------------------
  # * Set Top Row
  #     row : row shown on top
  #--------------------------------------------------------------------------
  def top_row=(row)
    row = 0 if row < 0
    row = row_max - 1 if row > row_max - 1
    self.oy = row * @wlh2
  end
  #--------------------------------------------------------------------------
  # * Get Number of Rows Displayable on 1 Page
  #--------------------------------------------------------------------------
  def page_row_max
    return (self.height - 32) / @wlh2
  end
  #--------------------------------------------------------------------------
  # * Get rectangle for displaying items
  #     index : item number
  #--------------------------------------------------------------------------
  def item_rect(index)
    rect = Rect.new(0, 0, 0, 0)
    rect.width = (contents.width + @spacing) / @column_max - @spacing
    rect.height = @wlh2
    rect.x = index % @column_max * (rect.width + @spacing)
    rect.y = index / @column_max * @wlh2
    return rect
  end
  
  def map_rect(index)
    rect = Rect.new(0, 0, 0, 0)
    rect.width = (contents.width + @spacing) / @column_max - @spacing
    rect.height = @wlh2
    rect.x = index % @column_max * (rect.width + @spacing)
    rect.y = index / @column_max * @wlh2
    return rect
  end
  # Overwrites the main draw_icon to return draw_map_icon
  def draw_map_icon(icon_index, x, y, enabled = true)
    bitmap = Cache.system("Iconset2")
    rect = Rect.new(icon_index % 16 * 32, icon_index / 16 * 32, 32, 32)
    self.contents.blt(x, y, bitmap, rect, enabled ? 255 : 100)
  end

end
