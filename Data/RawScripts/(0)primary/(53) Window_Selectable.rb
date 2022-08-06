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
    dh = [[height - 32, row_max * @wlh2].max, maxbitmap].min
    bitmap = Bitmap.new(dw, dh)
    self.contents = bitmap
    self.contents.font.color = normal_color
  end
  #--------------------------------------------------------------------------
  # * Set Cursor Position
  #     index : new cursor position
  #--------------------------------------------------------------------------
  def index=(index)
    @index = index
    update_cursor
    call_update_help
  end
  #--------------------------------------------------------------------------
  # * Get Row Count
  #--------------------------------------------------------------------------
  def row_max
    return (@item_max + @column_max - 1) / @column_max
  end
  #--------------------------------------------------------------------------
  # * Get Top Row
  #--------------------------------------------------------------------------
  def top_row
    return self.oy / WLH
  end
  #--------------------------------------------------------------------------
  # * Set Top Row
  #     row : row shown on top
  #--------------------------------------------------------------------------
  def top_row=(row)
    row = 0 if row < 0
    row = row_max - 1 if row > row_max - 1
    self.oy = row * WLH
  end
  #--------------------------------------------------------------------------
  # * Get Number of Rows Displayable on 1 Page
  #--------------------------------------------------------------------------
  def page_row_max
    return (self.height - 32) / WLH
  end
  #--------------------------------------------------------------------------
  # * Get Number of Items Displayable on 1 Page
  #--------------------------------------------------------------------------
  def page_item_max
    return page_row_max * @column_max
  end
  #--------------------------------------------------------------------------
  # * Get bottom row
  #--------------------------------------------------------------------------
  def bottom_row
    return top_row + page_row_max - 1
  end
  #--------------------------------------------------------------------------
  # * Set bottom row
  #     row : Row displayed at the bottom
  #--------------------------------------------------------------------------
  def bottom_row=(row)
    self.top_row = row - (page_row_max - 1)
  end
  #--------------------------------------------------------------------------
  # * Get rectangle for displaying items
  #     index : item number
  #--------------------------------------------------------------------------
  def item_rect(index)
    rect = Rect.new(0, 0, 0, 0)
    rect.width = (contents.width + @spacing) / @column_max - @spacing
    rect.height = WLH
    rect.x = index % @column_max * (rect.width + @spacing)
    rect.y = index / @column_max * WLH
    return rect
  end
  #--------------------------------------------------------------------------
  # * Set Help Window
  #     help_window : new help window
  #--------------------------------------------------------------------------
  def help_window=(help_window)
    @help_window = help_window
    call_update_help
  end
  #--------------------------------------------------------------------------
  # * Determine if cursor is moveable
  #--------------------------------------------------------------------------
  def cursor_movable?
    return false if (not visible or not active)
    return false if (@index < 0 or @index > @item_max or @item_max <= 1)
    return false if (@opening or @closing)
    return true
  end
  #--------------------------------------------------------------------------
  # * Move cursor down
  #     wrap : Wraparound allowed
  #--------------------------------------------------------------------------
  def cursor_down(wrap = false)
    return unless row_max > 1 && @item_max > 1
    if (@index < @item_max - @column_max) or (wrap and @column_max == 1)
      @index = (@index + @column_max) % @item_max
    elsif @index + @column_max - 1 > @item_max - 1
      @index = (@column_max - 1) % @item_max - 1
    end
  end
  #--------------------------------------------------------------------------
  # * Move cursor up
  #     wrap : Wraparound allowed
  #--------------------------------------------------------------------------
  def cursor_up(wrap = false)
    return unless row_max > 1 && @item_max > 1
    if (@index >= @column_max) or
        (wrap and @column_max == 1)
      @index = (@index - @column_max + @item_max) % @item_max
    end
  end
  #--------------------------------------------------------------------------
  # * Move cursor right
  #     wrap : Wraparound allowed
  #--------------------------------------------------------------------------
  def cursor_right(wrap = false)
    if @column_max >= 2 or (wrap and page_row_max == 1) && @item_max > 1
      # Fix so out of bounds errors don't occur
      if @index + 1 > @item_max - 1
        @index -= @index % @column_max
      else
        (@index + 1) % @column_max != 0 ?
            @index = (@index + 1) % @item_max :
            @index -= @index % @column_max
      end
      #@index = @item_max - 1 if @index > @item_max - 1
    end
  end
  #--------------------------------------------------------------------------
  # * Move cursor left
  #     wrap : Wraparound allowed
  #--------------------------------------------------------------------------
  def cursor_left(wrap = false)
    if (@column_max >= 2) or (wrap and page_row_max == 1) && @item_max > 1
      # Fix so out of bounds errors don't occur
      if @index - 1 < 0
        if @column_max - 1 > @item_max - 1
          @index = @item_max - 1
        else
          @index = @column_max - 1
        end
      else
        (@index - 1) % @column_max != @column_max - 1 && @index - 1 > -1 ?
            @index = (@index - 1 + @item_max) % @item_max :
            @index += @column_max - 1
        @index = @item_max - 1 if @index > @item_max - 1
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Move cursor one page down
  #--------------------------------------------------------------------------
  def cursor_pagedown
    if top_row + page_row_max < row_max && @item_max > 1
      @index = [@index + page_item_max, @item_max - 1].min
      self.top_row += page_row_max
    end
  end
  #--------------------------------------------------------------------------
  # * Move cursor one page up
  #--------------------------------------------------------------------------
  def cursor_pageup
    if top_row > 0 && @item_max > 1
      @index = [@index - page_item_max, 0].max
      self.top_row -= page_row_max
    end
  end
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  def update
    super
    if cursor_movable?
      last_index = @index
      if Input.repeat?(PadConfig.down) && Input.repeat?(PadConfig.left)
        cursor_down
        cursor_left
      elsif Input.repeat?(PadConfig.down) && Input.repeat?(PadConfig.right)
        cursor_down
        cursor_right
      elsif Input.repeat?(PadConfig.down)
        cursor_down
      elsif Input.repeat?(PadConfig.up) && Input.repeat?(PadConfig.left)
        cursor_up
        cursor_left
      elsif Input.repeat?(PadConfig.up) && Input.repeat?(PadConfig.right)
        cursor_up
        cursor_right
      elsif Input.repeat?(PadConfig.up)
        cursor_up
      elsif Input.repeat?(PadConfig.left)
        cursor_left
      elsif Input.repeat?(PadConfig.right)
        cursor_right
      end

#      if Input.repeat?(PadConfig.down)
#        cursor_down(Input.trigger?(PadConfig.down))
#      end
#      if Input.repeat?(PadConfig.up)
#        cursor_up(Input.trigger?(PadConfig.up))
#      end
#      if Input.repeat?(PadConfig.right)
#        cursor_right(Input.trigger?(PadConfig.right))
#      end
#      if Input.repeat?(PadConfig.left)
#        cursor_left(Input.trigger?(PadConfig.left))
#      end
      if Input.repeat?(PadConfig.page_down)
        cursor_pagedown
      end
      if Input.repeat?(PadConfig.page_up)
        cursor_pageup
      end
      if @index != last_index
        Sound.play_cursor
      end
    end
    update_cursor
    call_update_help
  end
  #--------------------------------------------------------------------------
  # * Update cursor
  #--------------------------------------------------------------------------
  def update_cursor
    if @index < 0                   # If the cursor position is less than 0
      self.cursor_rect.empty        # Empty cursor
    else                            # If the cursor position is 0 or more
      row = @index / @column_max    # Get current row
      if row < top_row              # If before the currently displayed
        self.top_row = row          # Scroll up
      end
      if row > bottom_row           # If after the currently displayed
        self.bottom_row = row       # Scroll down
      end
      rect = item_rect(@index)      # Get rectangle of selected item
      rect.y -= self.oy             # Match rectangle to scroll position
      self.cursor_rect = rect       # Refresh cursor rectangle
    end
  end
  #--------------------------------------------------------------------------
  # * Call help window update method
  #--------------------------------------------------------------------------
  def call_update_help
    if self.active and @help_window != nil
       update_help
    end
  end
  #--------------------------------------------------------------------------
  # * Update help window (contents are defined by the subclasses)
  #--------------------------------------------------------------------------
  def update_help
  end
end
