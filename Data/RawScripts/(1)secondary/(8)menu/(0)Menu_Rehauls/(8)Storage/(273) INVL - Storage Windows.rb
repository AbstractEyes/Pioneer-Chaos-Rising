################################################################################
# Window_UseDrop                                                               #
#------------------------------------------------------------------------------#

class Window_UseDrop < Window_Command
  
  def initialize
    commands = [FC::INVL_CUSTOM::VOCAB_USE, FC::INVL_CUSTOM::VOCAB_DROP,]
    super(FC::INVL_CUSTOM::USE_DROP_WIDTH + 32, commands, 1, 2, 32)
    self.x = (Graphics.width / 2) - (self.width / 2)
    self.y = (Graphics.height / 2) - (self.height / 2)
    self.z = 101
    self.index = 0
  end
  
end

################################################################################
# Window_SpaceGauge                                                            #
#------------------------------------------------------------------------------#

class Window_SpaceGauge < Window_Base

  def initialize(x,y,width,height)
    super(x,y,width,height)#(Graphics.width / 2 - 150, Graphics.height / 2 + WLH * 2, 300, WLH + 32)
    draw_space_gauge(0, 0, width-20)
    self.z = 101
  end
  
  def update
    super
#~     draw_space_gauge(0, 0)
    if @opening
      self.openness += 48
      @opening = false if self.openness == 255
    elsif @closing
      self.openness -= 48
      @closing = false if self.openness == 0
    end
  end
  
  def refresh
    self.contents.clear
    draw_space_gauge(0,0,width-20)
  end
  
  def space_gauge_color1
    return text_color(FC::INVL_CUSTOM::SPACE_GAUGE_COLOR_1)
  end
  
  def space_gauge_color2
    return text_color(FC::INVL_CUSTOM::SPACE_GAUGE_COLOR_2)
  end
  
  def draw_space_gauge(x, y, width)
    draw_space_gauge_bar(x, y, width)
    self.contents.font.color = normal_color
    self.contents.draw_text(x, y, 100, WLH, FC::INVL_CUSTOM::VOCAB_SPACE)
    last_font_size = self.contents.font.size
    xr = x + width
    if $game_party.current_total_size > $game_party.current_space * 2 / 3
      self.contents.font.color = crisis_color
    end
    if $game_party.current_total_size >= $game_party.current_space
      self.contents.font.color = knockout_color
    end
#~     self.contents.draw_text(xr - 99, y, 44, WLH, $current_total_size, 2)
#~     self.contents.draw_text(xr - 55, y, 11, WLH, "/", 2)
    self.contents.draw_text(172, y, width, WLH, sprintf("%2d / %2d", $game_party.current_total_size, $game_party.current_space))
    self.contents.font.color = normal_color
  end
  
  def draw_space_gauge_bar(x, y, width)
    gw = width * $game_party.current_total_size / $game_party.current_space
    gc1 = space_gauge_color1
    gc2 = space_gauge_color2
    self.contents.fill_rect(x, y + WLH - 8, width, 12, gauge_back_color)
    self.contents.gradient_fill_rect(x, y + WLH - 8, gw, 12, gc1, gc2)
  end
  
end

################################################################################
# Window_DropConfirm                                                           #
#------------------------------------------------------------------------------#

class Window_DropConfirm < Window_Command
  
  def initialize
    commands = [FC::INVL_CUSTOM::VOCAB_DONT_DROP, FC::INVL_CUSTOM::VOCAB_DO_DROP]
    super(FC::INVL_CUSTOM::USE_DROP_WIDTH + 32, commands, 1, 2, 32)
    self.x = (Graphics.width / 2) - (self.width / 2)
    self.y = (Graphics.height / 2) - (self.height / 2)
    self.z = 101
    self.index = 0
  end
  
end

################################################################################
# Window_ItemStorage                                                           #
#------------------------------------------------------------------------------#

class Window_ItemStorage < Window_Selectable
  
  def initialize(x, y, width, height,spacing = 2)
    super(x, y, width, height)
    @column_max = 7
    @spacing = spacing
    @wlh2 = 32
    self.index = 0
    self.z = 100
    refresh
  end
  
  def data_size
    return @data.size
  end
  
  def item
    return @data[self.index]
  end
  
  def include?(item)
    return false if item == nil
    return true
  end
  
  def enable?(item)
    return $game_party.overall_checker(item, 1)
  end
  
  def jump_to_index_position(deposited_item)
    index_counter = 0
    return if deposited_item == nil
    for item in $game_party.stored_items
      if item != nil
        index_counter += 1
        if deposited_item.name == item.name
          return index_counter
        end
      end
    end
  end
  
  def refresh
    self.contents.clear
    @data = []
    for item in $game_party.stored_items
      next unless item != nil
      @data.push(item)
    end   
    sort_items
    @data.push(nil) if include?(nil) or $game_party.stored_item_number(item) <= 0
    @item_max = @data.size
    create_contents
    for i in 0...@item_max
      draw_item(i)
    end
  end
  
  def sort_items
    return if @data.empty?
    @data.sort { |a,b| a.item_type <=> b.item_type}
  end

  def draw_item(index)
    item = @data[index]
    if item != nil
      # Creates the rect for i to max area
      rect = map_rect(index)
      enabled = enable?(item)
      number = $game_party.stored_item_number(item)
      # Checks the icon and displays the icon
      self.draw_map_icon(item.icon_index, rect.x, rect.y, enabled)#y*32+@spacing, (x*32),enabled)
      fsize = self.contents.font.size
      if number <= 999
        self.contents.font.size = 14
        rect.x += 9
        rect.y += 10
      elsif number > 999
        self.contents.font.size = 12
        rect.x += 6
        rect.y += 10
      else
        self.contents.font.size = 15
        rect.x += 12
        rect.y += 10
      end
      self.contents.draw_text(rect, sprintf("%2d", number))
      #(y*32+@spacing), x*32+12, width, WLH, sprintf("%2d", number))
      self.contents.font.size = fsize
    end
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
    
  def update_help
    @help_window.set_text(item == nil ? "" : item.description)
  end
  
end
###############################################################################
class Window_ItemStorage_Backing_Window < Window_Base
  
  def initialize(x, y, width, height, type = 'storage')
    super(x, y, width, height)
    @type = type
    self.z = 99
  end
  
  def refresh(item,type)
    self.contents.clear
    return if item == nil
    self.draw_icon(item.icon_index,0,0)
    if type == 'storage'
      number = $game_party.stored_item_number(item)
      fsize = self.contents.font.size
      self.contents.font.size = 16
      self.contents.draw_text(24,0,width,WLH,"#{item.name}")
      self.contents.draw_text($screen_width/2 - 70,0,width,WLH,sprintf(":%2d", number))
      self.contents.font.size = fsize
    elsif type == 'inventory'
      number = $game_party.item_number(item)
      fsize = self.contents.font.size
      self.contents.font.size = 16
      self.contents.draw_text(24,0,width,WLH,"#{item.name}")
      self.contents.draw_text($screen_width/2 - 70,0,width,WLH,"#{number}/#{$game_party.full_stack_size(item)}")
      self.contents.font.size = fsize
    end
  end
  
end


################################################################################
# Window_StoreUnstore                                                          #
#------------------------------------------------------------------------------#

class Window_StoreUnstore < Window_Command
  
  def initialize
    commands = [FC::INVL_CUSTOM::VOCAB_STORE, FC::INVL_CUSTOM::VOCAB_UNSTORE]
    super(FC::INVL_CUSTOM::STORE_UNSTORE_WIDTH + 32, commands, 1, 2, 32)
    self.x = (Graphics.width / 2) - (self.width / 2)
    self.y = (Graphics.height / 2) - (self.height / 2)
    self.z = 102
    self.index = 0
  end
  
end

################################################################################
# Window_EquipItem                                                             #
#------------------------------------------------------------------------------#

class Window_EquipItem < Window_Item
  
  alias enable_INVL? enable?
  def enable?(item)
    if item != nil and item.unequip_for_space and $game_party.lose_check(item, 1)
      return false
    else
      enable_INVL?(item)
    end
  end
  
end
=begin
################################################################################
# Window_ShopBuy                                                               #
#------------------------------------------------------------------------------#

class Window_ShopBuy < Window_Selectable
  
  def enable?(item)
    if $game_party.overall_checker(item, 1)
      return true
    else
      return false
    end
  end
  
  def draw_item(index)
    item = @data[index]
    number = $game_party.item_number(item)
    enabled = enable?(item)
    rect = item_rect(index)
    self.contents.clear_rect(rect)
    draw_item_name(item, rect.x, rect.y, enabled)
    rect.width -= 4
    self.contents.draw_text(rect, item.price, 2)
  end
  
end


################################################################################
# Window_ShopSell                                                              #
#------------------------------------------------------------------------------#

class Window_ShopSell < Window_Item
  
  alias enable_INVL? enable?
  def enable?(item)
    if item.price <= 0 or item.no_sell or $game_party.lose_check(item, 1)
      return false
    else
      enable_INVL?(item)
    end
  end
  
end
=end
#===============================================================================
# Window_ItemNumInput: Item Number Input Window
#===============================================================================
class Window_ItemNumInput < Window_Base
  
  attr_reader :qn
  
  def initialize
    @maxQn = 99
    @qn = 1
    super(200,60,100,100)
    refresh
    self.x = (Graphics.width - 100) / 2
    self.y = (Graphics.height - 100) / 2
    self.z = 101
  end

  def refresh
    self.contents.clear
    self.contents.draw_text(0,0,self.width - 32,WLH,"Amount", 1)
    self.contents.draw_text(0,WLH, self.width - 32, WLH, @qn.to_s + '/' + @maxQn.to_s, 1)
  end
  
  def set_max(number)
    @maxQn = number
    @maxQn = 99 if @maxQn > 99
    @maxQn = 1 if @maxQn < 1
    @qn = 1
  end
  
  def update
    refresh
    if Input.repeat?(PadConfig.up)
      Sound.play_cursor
      @qn += 10
      @qn = @maxQn if @qn > @maxQn
    elsif Input.repeat?(PadConfig.down)
      Sound.play_cursor
      @qn -= 10
      @qn = 1 if @qn < 1
    elsif Input.repeat?(PadConfig.left)
      Sound.play_cursor
      @qn -= 1
      @qn = 1 if @qn < 1
    elsif Input.repeat?(PadConfig.right)
      Sound.play_cursor
      @qn += 1
      @qn = @maxQn if @qn > @maxQn
    elsif Input.repeat?(PadConfig.page_up)
      Sound.play_cursor
      @qn -= 100
      @qn = 1 if @qn < 1
    elsif Input.repeat?(PadConfig.page_down)
      Sound.play_cursor
      @qn += 100
      @qn = @maxQn if @qn > @maxQn
    end
  end

end
