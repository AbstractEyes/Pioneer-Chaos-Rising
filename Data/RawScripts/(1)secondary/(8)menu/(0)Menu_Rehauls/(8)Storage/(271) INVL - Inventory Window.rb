################################################################################
# Window_Item                                                                  #
#------------------------------------------------------------------------------#

class Invl_Window_Item < Window_Selectable
  
  alias initialize_INVL initialize
  def initialize(x, y, width, height)
    super(x, y, width, height,0)
    @column_max = 5
    self.z = 100
    self.index = 0
    @spacing = 0
    @wlh2 = 32
    refresh
  end
  
  def item
    return @data[self.index]
  end
  
  def enable?(item)
#~     return false if item.stack_max + item.stack_plus <= $game_party.item_number(item)
    return true
  end
  
  def draw_item(index)
    rect = item_rect(index)
    self.contents.clear_rect(rect)
    item = @data[index]
    if item != nil
      number = $game_party.item_number(item)
      stack_count = $game_party.full_stack_shop(item)
      enabled = enable?(item)
      self.contents.font.size = 14
      self.contents.font.color = system_color
      self.draw_map_icon(item.icon_index, rect.x, rect.y, enabled)
      rect.x += 10
      rect.y += 10
      self.contents.draw_text(rect, "#{number}/#{$game_party.full_stack_size(item)}")
    end
  end
  
  def refresh
    self.contents.clear
    @data = []
    for item in $game_party.items
      next unless item != nil
      @data.push(item)
    end
    @data.push(nil) if item == nil or $game_party.item_number(item) <= 0
    sort_items
    @item_max = @data.size
    create_contents
    for i in 0...@item_max
      draw_item(i)
    end
  end
  
  def sort_items
    return if @data.empty?
    data = @data
    data.sort! { |a,b| a.item_type <=> b.item_type }
    @data = data
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
  #--------------------------------------------------------------------------
  # * Update Help Text
  #--------------------------------------------------------------------------
  def update_help
    @help_window.set_text(item == nil ? "" : item.description)
  end

end

################################################################################
# Window_Item                                                                  #
#------------------------------------------------------------------------------#

class Window_Item < Window_Selectable
  
  alias initialize_INVL initialize
  def initialize(x, y, width, height)
    super(x, y, width, height)
    @column_max = 1
    self.index = 0
    @wlh2 = 32
    refresh
  end
  
  def item
    return @data[self.index]
  end
  
#~   alias enable_INVL? enable?
  def enable?(item)
    return true
#~     enable_INVL?(item)
  end

  def draw_item(index)
    rect = item_rect(index)
    self.contents.clear_rect(rect)
    item = @data[index]
    if item != nil
      if $box_sell == true
        number = $game_party.stored_item_number(item)
        enabled = enable?(item)
        rect.width -= 4
        draw_item_name(item, rect.x, rect.y, enabled)
#~         if number > 99 and number < 1000
#~           self.contents.draw_text(rect, number, 2)
#~         elsif number >= 1000
#~           self.contents.draw_text(rect, number, 2)
#~         else
#~           self.contents.draw_text(rect, number, 2)
#~         end
      elsif $box_sell == false
        rect = item_rect(index)
        self.contents.clear_rect(rect)
        item = @data[index]
        return if item == nil
        number = $game_party.item_number(item)
        stack_count = $game_party.full_stack_shop(item)
        enabled = enable?(item)
        if ($scene.is_a?(Scene_Battle) and $scene.smaller_obj_window)
          rect.width -= 28
          draw_item_name(item, rect.x, rect.y, enabled)
          dx = rect.x + rect.width - 4
          dw = ($scene.is_a?(Scene_Battle) and $scene.smaller_obj_window) ? 24 : 80
          self.contents.draw_text(dx, rect.y, dw, WLH, sprintf(":%2d", number), 2)
        else
          rect.width -= 4
          draw_item_name(item, rect.x, rect.y, enabled)
          self.contents.draw_text(rect, sprintf(":%2d/%2d", number, stack_count), 2)
        end
      else
        number = $game_party.item_number(item)
        stack_count = $game_party.full_stack_shop(item)
        enabled = enable?(item)
        rect.width -= 4
        draw_item_name(item, rect.x, rect.y, enabled)
        self.contents.draw_text(rect, sprintf(":%2d/%2d", number, stack_count), 2)
      end
    end
  end
  
  def refresh
    if $box_sell == false
      @data = []
      for item in $game_party.items
        next unless include?(item)
        @data.push(item)
        if item.is_a?(RPG::Item) and item.id == $game_party.last_item_id
          self.index = @data.size - 1
        end
      end
      @data.push(nil) if include?(nil)
      @item_max = @data.size
      create_contents
      for i in 0...@item_max
        draw_item(i)
      end
    elsif $box_sell == true
      @data = []
      for item in $game_party.stored_items
        next unless include?(item)
        @data.push(item)
        if item.is_a?(RPG::Item) and item.id == $game_party.last_item_id
          self.index = @data.size - 1
        end
      end
      @data.push(nil) if include?(nil)
      @item_max = @data.size
      create_contents
      for i in 0...@item_max
        draw_item(i)
      end
    end
  end

end