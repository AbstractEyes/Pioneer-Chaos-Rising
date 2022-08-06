################################################################################
# Game_Party                                                                   #
#------------------------------------------------------------------------------#

class Game_Party < Game_Unit
  
#--------------------#
# Initialize (Alias) #
#--------------------------------#
# Adds hashes for storage items. #
#--------------------------------#
  alias initialize_RES initialize
  def initialize
    initialize_RES
    @res_items = {}
    @res_weapons = {}
    @res_armors = {}
  end

  def initialize_check
    @res_items = {} if @res_items.nil?
    @res_weapons = {} if @res_weapons.nil?
    @res_armors = {} if @res_armors.nil?
    @reward_items = {} if @reward_items.nil?
    @reward_weapons = {} if @reward_weapons.nil?
    @reward_armors = {} if @reward_armors.nil?
    @req_items = {} if @req_items.nil?
    @req_weapons = {} if @req_weapons.nil?
    @req_armors = {} if @req_armors.nil?
  end
  
  def res_hash_clear
    @res_items.clear
    @res_weapons.clear
    @res_armors.clear
  end
#----------------------#
# Resource Chest Items #
#------------------------------------#
# Returns your resource chest items. #
#------------------------------------#
  def resource_items
    initialize_check
    result = []
    for i in @res_items.keys.sort
      result.push($data_items[i]) if @res_items[i] > 0
    end
    for i in @res_weapons.keys.sort
      result.push($data_weapons[i]) if @res_weapons[i] > 0
    end
    for i in @res_armors.keys.sort
      result.push($data_armors[i]) if @res_armors[i] > 0
    end
    return result
  end
  
#----------------------------#
# Resource Chest Item Number #
#-----------------------------------------------------------------#
# Returns the quantity of an item you have in the resource chest. #
#-----------------------------------------------------------------#
  def res_item_number(item)
    case item
    when RPG::Item
      number = @res_items[item.id]
    when RPG::Weapon
      number = @res_weapons[item.id]
    when RPG::Armor
      number = @res_armors[item.id]
    end
    return number == nil ? 0 : number
  end
  
#------------------------#
# Add Reource Chest Item #
#-----------------------------------------------#
# Adds an item to the resource chest inventory. #
#-----------------------------------------------#
  def add_res_item(item, n)
    number = res_item_number(item)
    case item
    when RPG::Item
      @res_items[item.id] = [[number + n, 0].max, 99].min
    when RPG::Weapon
      @res_weapons[item.id] = [[number + n, 0].max, 99].min
    when RPG::Armor
      @res_armors[item.id] = [[number + n, 0].max, 99].min
    end
  end

#-----------------------------------------------#
# Adds Resource chest Item From Variable Amount #
#--------------------------------------------------------------------------#
# Adds an item to the resource chest, based on a database variable amount. #
#--------------------------------------------------------------------------#
  def resv(item, n)
    number = res_item_number(item)
    derp = $game_variables[n]
    case item
    when RPG::Item
      @res_items[item.id] = [[number + derp, 0].max, 99].min
    when RPG::Weapon
      @res_weapons[item.id] = [[number + derp, 0].max, 99].min
    when RPG::Armor
      @res_armors[item.id] = [[number + derp, 0].max, 99].min
    end
  end
  
#----------------------------#
# Remove resource chest Item #
#----------------------------------------#
# Takes an item from the resource chest. #
#----------------------------------------#
  def remove_res_item(item, n)
    add_res_item(item, -n)
  end

  def do_resource
    $game_temp.next_scene = "resource"
  end
  
end
