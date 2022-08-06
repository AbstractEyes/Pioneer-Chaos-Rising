#==============================================================================
# ** Window_ShopBuy
#------------------------------------------------------------------------------
#  This window displays buyable goods on the shop screen.
#==============================================================================

class Window_ShopBuy < Window_Selectable
  #--------------------------------------------------------------------------
  # * Object Initialization
  #     x : window X coordinate
  #     y : window Y coordinate
  #--------------------------------------------------------------------------
  def initialize(x, y)
    super(x, y, 304, 304,0)
    @shop_goods = $game_temp.shop_goods
    print @shop_goods.inspect
    refresh
    self.index = 0
  end
  #--------------------------------------------------------------------------
  # * Get Item
  #--------------------------------------------------------------------------
  def item
    return @data[self.index]
  end
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
#~   def refresh
#~     @data = []
#~     for goods_item in @shop_goods
#~       case goods_item[0]
#~       when 0
#~         item = $data_items[goods_item[1]]
#~       when 1
#~         item = $data_weapons[goods_item[1]]
#~       when 2
#~         item = $data_armors[goods_item[1]]
#~       end
#~       if item != nil
#~         @data.push(item)
#~       end
#~     end
#~     @item_max = @data.size
#~     create_contents
#~     for i in 0...@item_max
#~       draw_item(i)
#~     end
#~   end
  #--------------------------------------------------------------------------
  # * Draw Item
  #     index : item number
  #--------------------------------------------------------------------------
#~   def draw_item(index)
#~     item = @data[index]
#~     rect = item_rect(index)
#~     if $game_temp.shop_purchase_only
#~       #~       if $box_sell == false
#~       if $box_buy == false
#~         number = $game_party.item_number(item)
#~         enabled = ((item.price / $resource_buy) <= $game_variables[6] and number < $game_party.full_stack_size(item) and $game_party.overall_checker(item, 1))
#~         draw_item_name(item, rect.x, rect.y, enabled)
#~         self.contents.draw_text(rect, (item.price / $resource_buy), 2)
#~       elsif $box_buy == true
#~         number = $game_party.stored_item_number(item)
#~         enabled = ((item.price / $resource_buy) <= $game_variables[6] and number < 9999)
#~         draw_item_name(item, rect.x, rect.y, enabled)
#~         self.contents.draw_text(rect, (item.price / $resource_buy), 2)
#~       end
#~     else
#~       if $box_buy == false
#~         number = $game_party.item_number(item)
#~         enabled = ((item.price * $coin_buy) <= $game_party.gold and number < $game_party.full_stack_size(item))
#~         draw_item_name(item, rect.x, rect.y, enabled)
#~         self.contents.draw_text(rect, item.price * $coin_buy, 2)
#~       elsif $box_buy == true
#~         number = $game_party.stored_item_number(item)
#~         enabled = ((item.price $coin_buy) <= $game_party.gold and number < 9999)
#~         draw_item_name(item, rect.x, rect.y, enabled)
#~         self.contents.draw_text(rect, (item.price * $coin_buy), 2)
#~       end
#~     end
#~     self.contents.clear_rect(rect)
#~     rect.width -= 4
#~   end
  
  def draw_item(index)
    if $game_temp.shop_purchase_only
      #~       if $box_sell == false
      if $box_buy == false
        item = @data[index]
        number = $game_party.item_number(item)
        enabled = ((item.price / $resource_buy) <= $game_variables[6] and number < $game_party.full_stack_size(item) and $game_party.overall_checker(item, 1))
        rect = item_rect(index)
        self.contents.clear_rect(rect)
        draw_item_name(item, rect.x, rect.y, enabled)
        rect.width -= 4
        self.contents.draw_text(rect, (item.price / $resource_buy), 2)
      elsif $box_buy == true
        item = @data[index]
        number = $game_party.stored_item_number(item)
        enabled = ((item.price / $resource_buy) <= $game_variables[6] and number < 9999)
        rect = item_rect(index)
        self.contents.clear_rect(rect)
        draw_item_name(item, rect.x, rect.y, enabled)
        rect.width -= 4
        self.contents.draw_text(rect, (item.price / $resource_buy), 2)
      end
    else
      if $box_buy == false
        item = @data[index]
        number = $game_party.item_number(item)
        enabled = ((item.price * $coin_buy) <= $game_party.gold and number < $game_party.full_stack_size(item))
        rect = item_rect(index)
        self.contents.clear_rect(rect)
        draw_item_name(item, rect.x, rect.y, enabled)
        rect.width -= 4
        self.contents.draw_text(rect, item.price * $coin_buy, 2)
      elsif $box_buy == true
        item = @data[index]
        number = $game_party.stored_item_number(item)
        enabled = ((item.price * $coin_buy) <= $game_party.gold and number < 9999)
        rect = item_rect(index)
        self.contents.clear_rect(rect)
        draw_item_name(item, rect.x, rect.y, enabled)
        rect.width -= 4
        self.contents.draw_text(rect, (item.price * $coin_buy), 2)
      end
    end
  end

  #--------------------------------------------------------------------------
  # * Help Text Update
  #--------------------------------------------------------------------------
  def update_help
    @help_window.set_text(item == nil ? "" : item.description)
  end

end

################################################################################
# Window_ShopSell                                                              #
#------------------------------------------------------------------------------#

class Window_ShopSell < Window_Item
  
  alias enable_INVL? enable?
  def enable?(item)
    if $game_temp.shop_purchase_only
      if (item.price / $resource_sell) < 1 or item.no_sell or $game_party.lose_check(item, 1)
        return false
      elsif item.resource_item
        enable_INVL?(item)
      else
        return false
      end
    else
      if (item.price / $coin_sell) < 1 or item.no_sell or $game_party.lose_check(item, 1)
        return false
      else
        enable_INVL?(item)
      end
    end
  end

  #--------------------------------------------------------------------------
  # * Whether or not to include in item list
  #     item : item
  #--------------------------------------------------------------------------
  def include?(item)
    return item != nil
  end

end