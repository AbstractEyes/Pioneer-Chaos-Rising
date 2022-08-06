################################################################################
# Scene_Equip                                                                  #
#------------------------------------------------------------------------------#

class Scene_Equip < Scene_Base
  
#-------------#
# Can't Trade #
#------------------------------------------------------------------------------#
# Runs when equipping or unequipping a weapon or armor.                        #
# Checks your size and space and alters your equipment allowances accordingly. #
# 'tradeout' is the currently equipped item (or nil).                          #
# 'tradein' is the item you are trying to equip (or nil, for unequipping).     #
# A 'true' result means you can NOT equip it; 'false' means you can.           #
#------------------------------------------------------------------------------#

  def return_scene
    $scene = Scene_Pioneer_Book.new
  end

  # Return true if you can trade the item out
  def trade_out_item?(equipped_item, inventory_item)  
    equip_number = $game_party.item_number(equipped_item)
    inventory_number = $game_party.item_number(inventory_number)
    equip_bool = $game_party.overall_checker(equipped_item,1) if equipped_item != nil
    inventory_bool = $game_party.overall_checker(inventory_item,1) if inventory_item != nil

    final_total_size = $game_party.current_total_size
    final_space = $game_party.current_space
    
    if equipped_item.id == inventory_item.id
      can_carry = false
    elsif equipped_item.id != inventory_item.id
      if equip_bool != nil and inventory_bool != nil
        can_carry = equip_bool
      elsif equip_bool == nil and inventory_bool != nil
        can_carry = true
      elsif equip_bool != nil and inventory_bool == nil
        can_carry = equip_bool
      elsif equip_bool == nil and inventory_bool == nil
        can_carry = true
        can_carry = false if equip_number == 0
      end
    end
    
    return true if can_carry == true
    return false
  end

end