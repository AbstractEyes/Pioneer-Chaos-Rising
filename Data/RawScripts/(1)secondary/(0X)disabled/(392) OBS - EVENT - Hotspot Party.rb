=begin
class Game_Party < Game_Unit
  attr_accessor :hotspot_type
  attr_reader :hotspot_tool
  attr_accessor :hotspot_spot_level
  attr_reader :hotspot_item_reward
  attr_reader :hotspot_tool_broken
  attr_reader :saved_hotspot_string
  attr_reader :saved_hotspot_tool_string
  
  def initialize_hotspot_variables
    @hotspot_tool = ""
    @hotspot_type = ""
    @hotspot_spot_level = 0
    @hotspot_item_reward = nil
    @hotspot_item = nil
  end
  
  # Eventing for the script functions, all in order.
  # Run this to use the hotspot.
  def spot_activate(type = "", level = 0)#, switch_id = 0)
    $hotspot_saved_hotspot_string = ""
    $hotspot_saved_hotspot_tool_string = ""
    $hotspot_reward_exp = false
    # Set Level for spot use
    @hotspot_spot_level = level
    # Set Type for spot use
    @hotspot_type = type
    # Set Tool for spot use
    @hotspot_tool = set_tool
    # Checks if you have the required tool
    unless @hotspot_tool == nil
      # Run the item randomizer
      spot_item_check
      # Check if can carry
#~       $data_switches[switch_id] = can_carry? if switch_id > 0
      # Run tool break checks, and add item.  Include message window
      #   and use for item reward on map.
      if can_carry?(@hotspot_item)
        # Save the displayed message for the window and gain the item
        $hotspot_saved_hotspot_string = "You have acquired #{@hotspot_item.name}!"
        $game_party.gain_item(@hotspot_item,1)
        # Check the tool odds to determine if it breaks or not
        tool_odds
        # If tool is broken, else return nil
        $hotspot_reward_exp = true
        if @hotspot_tool_broken == true
          # Create tool broken string, then remove item
          $hotspot_saved_hotspot_tool_string = "Your #{@hotspot_tool.name} broke."
          $game_party.gain_item(@hotspot_tool,-1)
        else
          # Nil the string if tool isn't broken
          $hotspot_saved_hotspot_tool_string = ""
        end
      else
        # Nil the hotspot string, should happen if you can't carry the item
        # Will complete this section after testing for carry items
        space_compare = $game_party.current_total_size - $game_party.current_space
        if space_compare <= 0
          $hotspot_saved_hotspot_string = "Your pack is full, you cannot add #{@hotspot_item.name}."
          $hotspot_reward_exp = false
        else
          $hotspot_saved_hotspot_string = "You cannot carry any more #{@hotspot_item.name}, item stack has peaked."
          $hotspot_reward_exp = false
        end
      end
    # If you don't have any tools to work with the spot
    else
      $hotspot_saved_hotspot_tool_string = "You don't have the required tool."
      $hotspot_reward_exp = false
    end
  end
  
  def spot_item_check
    if @hotspot_type == "mining"
      @hotspot_item = PHI::HOTSPOT.ore_spot(@hotspot_spot_level)
    elsif @hotspot_type == "stone"
      @hotspot_item = PHI::HOTSPOT.stone_spot(@hotspot_spot_level)
    elsif @hotspot_type == "fishing"
      # Unfinished
      @hotspot_item = PHI::HOTSPOT.fish_spot(@hotspot_spot_level)
    elsif @hotspot_type == "chopping"
      @hotspot_item = PHI::HOTSPOT.tree_spot(@hotspot_spot_level)
    elsif @hotspot_type == "carving"
      
    elsif @hotspot_type == "picking"
      
    elsif @hotspot_type == "artifact"
      
    elsif @hotspot_type == "chest"
      
    end
  end
  
  def tool_odds
    tool = @hotspot_tool
    @hotspot_tool_broken = false
    if tool.name == "Diamond Pickaxe"
      
    elsif tool.name == "Mithril Pickaxe"
      val = rand(15)
      @hotspot_tool_broken = true if val == 1
    elsif tool.name == "Iron Pickaxe"
      val = rand(10)
      @hotspot_tool_broken = true if val == 1
    elsif tool.name == "Old Pickaxe"
      val = rand(6)
      @hotspot_tool_broken = true if val == 1
    elsif tool.name == "Diamond Fishing Spear"
      
    elsif tool.name == "Mithril Fishing Spear"
      val = rand(15)
      @hotspot_tool_broken = true if val == 1
    elsif tool.name == "Iron Fishing Spear"
      val = rand(10)
      @hotspot_tool_broken = true if val == 1
    elsif tool.name == "Old Fishing Spear"
      val = rand(6)
      @hotspot_tool_broken = true if val == 1
    elsif tool.name == "Diamond Hatchet"
      
    elsif tool.name == "Mithril Hatchet"
      val = rand(15)
      @hotspot_tool_broken = true if val == 1
    elsif tool.name == "Iron Hatchet"
      val = rand(10)
      @hotspot_tool_broken = true if val == 1
    elsif tool.name == "Old Hatchet"
      val = rand(6)
      @hotspot_tool_broken = true if val == 1
    end
  end
  
  def can_carry?(item)
    return $game_party.overall_checker(item,1)
  end
  
  # this entire job is to check if you have the tools
  def set_tool
    type = @hotspot_type
    if type == "mining" or type == "stone"
      if $game_party.has_item?($data_items[12])
        return $data_items[12]
      elsif $game_party.has_item?($data_items[11])
        return $data_items[11]
      elsif $game_party.has_item?($data_items[10])
        return $data_items[10]
      elsif $game_party.has_item?($data_items[9])
        return $data_items[9]
      end
    elsif type == "fishing"
      if $game_party.has_item?($data_items[4])
        return $data_items[4]
      elsif $game_party.has_item?($data_items[3])
        return $data_items[3]
      elsif $game_party.has_item?($data_items[2])
        return $data_items[2]
      elsif $game_party.has_item?($data_items[1])
        return $data_items[1]
      end
    elsif type == "chopping"
      if $game_party.has_item?($data_items[8])
        return $data_items[8]
      elsif $game_party.has_item?($data_items[7])
        return $data_items[7]
      elsif $game_party.has_item?($data_items[6])
        return $data_items[6]
      elsif $game_party.has_item?($data_items[5])
        return $data_items[5]
      end
    elsif type == "carving"
#~       return true
    elsif type == "picking"
#~       return true
    elsif type == "artifact"
#~       return true
    elsif type == "chest"
#~       return true
    end
#~     return false
  end
    
end
=end