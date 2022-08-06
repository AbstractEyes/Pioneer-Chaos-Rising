

class Resource_Chest < Window_Item
  
  #--------------------------------------------------------------------------
  # * Object Initialization
  #     x      : window x-coordinate
  #     y      : window y-coordinate
  #     width  : window width
  #     height : window height
  #--------------------------------------------------------------------------
  def initialize(x, y, width, height)
    super(x, y, width, height)
    @column_max = 1
    self.index = 0
    refresh
  end
  
  def item
    return @data[self.index]
  end
  
  def include?(item)
    return false if item == nil
    return true
  end
  
  def enable?(item)
    if $game_party.overall_checker(item, 1)
      return true
    else
      return false
    end
  end

  
  def refresh
    @data = []
    for item in $game_party.resource_items
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

  #--------------------------------------------------------------------------
  # * Draw Item
  #     index : item number
  #--------------------------------------------------------------------------
  def draw_item(index)
    rect = item_rect(index)
    self.contents.clear_rect(rect)
    item = @data[index]
    if item != nil
      res_number = $game_party.res_item_number(item)
      inv_number = $game_party.item_number(item)
      max_item = $game_party.full_stack_size(item)
      enabled = enable?(item)
      rect.width -= 4
      draw_item_name(item, rect.x, rect.y, enabled)
      self.contents.draw_text(rect, sprintf(":%2d - %2d/%2d", res_number, inv_number, max_item), 2)
    end
  end

  #--------------------------------------------------------------------------
  # * Update Help Text
  #--------------------------------------------------------------------------
  def update_help
    @help_window.set_text(item == nil ? "" : item.description)
  end
  
end
class Resource_Window_Name < Window_Base
  #--------------------------------------------------------------------------
  # * Object Initialization
  #     x : window X coordinate
  #     y : window Y coordinate
  #--------------------------------------------------------------------------
  def initialize(x, y, width, height)
    super(0, 354, $screen_width, 62)
    refresh
  end
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh
    self.contents.font.color = system_color
    self.contents.draw_text(ox, oy, $screen_width, WLH, "Supplies: --- Press: C - 1, X - All --- Chest - Pack / Max")
  end
end