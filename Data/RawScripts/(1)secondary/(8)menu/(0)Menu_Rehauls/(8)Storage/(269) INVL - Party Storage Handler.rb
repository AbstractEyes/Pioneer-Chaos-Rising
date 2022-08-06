################################################################################
# Game_Party                                                                   #
#------------------------------------------------------------------------------#

class Game_Party < Game_Unit
  
#--------------------#
# Initialize (Alias) #
#--------------------------------#
# Adds hashes for storage items. #
#--------------------------------#
  alias initialize_INVL initialize
  def initialize
    initialize_INVL
    @storage = {}
  end
  
#--------------------#
# Current Total Size #
#-----------------------------------------------#
# Returns the current total size of your items. #
#-----------------------------------------------#
  def current_total_size
    result = 0
    
    for item in $game_party.items
      if item != nil
        result += 1
      end
    end
    
    $current_total_size = result
    $saved_current_size = $current_total_size
    return result
  end
  
#---------------#
# Current Space #
#----------------------------------------------#
# Returns the current space of your inventory. #
#----------------------------------------------#
  def current_space
    result = FC::INVL_CUSTOM::DEFAULT_SPACE
    result = FC::INVL_CUSTOM::MAX_SPACE if result > FC::INVL_CUSTOM::MAX_SPACE
    $current_space = result + $game_variables[123]
    return result + $game_variables[123]
  end
  
  def item_full(item, number)
    return (item_number(item) >= item.stack_max)
  end
  
#-------------#
# Stack Check #
#--------------------------------------------------------------------------#
# Checks the amount of the item, then returns true if you can hold the     #
# selected item, false if you can't hold it.                               #
#--------------------------------------------------------------------------#  
  def stack_remainder(item)
    number = 0 + stack_item_number(@item) - item_number(@item)
    return number
  end
    

#------------#
# Lose Check #
#-------------------------------------------------------------------------#
# This method checks whether or not the player is allowed to lose an item #
# (as in dropping or selling an item that gives used space).              #
# A 'true' result means that the player will/can NOT lose the item.       #
#-------------------------------------------------------------------------#  
  def lose_check(item, number)
#~     return (item.item_size * number > 0 and current_space - item.item_size * number < current_total_size - 1 * number)
  end
  
  # Return true if you can carry an item
  def overall_checker(item, number = 0)
    return false if item.nil?
    current_space
    current_total_size
    gain_checker = $current_total_size < $current_space
    stack_checker = (item_number(item)) < full_stack_size(item)
    if gain_checker and stack_checker
      return true
    elsif gain_checker and stack_checker == false
      return false
    elsif gain_checker == false and item_number(item) >= 1 and stack_checker
      return true
    elsif gain_checker == false and item_number(item) >= 1 and stack_checker == false
      return false  
    end
  end
#-----------------#
# Full Stack Size #
#-------------------------------------------------#
# Adds up your stack size into a returned number. #
#-------------------------------------------------#
  def full_stack_size(item)
    return 99 if item == nil
    return (item.stack_max + (item.stack_plus * $game_variables[410]))
  end

#-----------------#
# Full Stack Shop #
#-------------------------------------------------#
# Adds up your stack size into a returned number. #
#-------------------------------------------------#
  def full_stack_shop(item)
    return 99 if item == nil
    return (item.stack_max + (item.stack_plus * $game_variables[410]))
  end
  
#-------------------#
# Gain Item (Alias) #
#----------------------------------------------------------------------------#
# Gives or takes items or equips. Automatically checks size/space and runs a #
# mandatory Use/Drop screen if space is past full.                           #
#----------------------------------------------------------------------------#
  alias gain_item_INVL gain_item
  def gain_item(item, n, include_equip = false)
    number = item_number(item)
    stack_size = full_stack_shop(item)
    case item
    when RPG::Item
      @items[item.id] = [[number + n, 0].max, stack_size].min
    #when RPG::Weapon
    #  @weapons[item.id] = [[number + n, 0].max, stack_size].min
    #when RPG::Armor
    #  @armors[item.id] = [[number + n, 0].max, stack_size].min
    end
  end
  
  def mass_store_items
    for i in 0...200
      $game_party.store_item($data_items[i],100)
    end
  end
  def store_weapons
    $game_party.store_item($data_weapons[1],100)
  end
#-----------#
# Can Hold? #
#----------------------------------------------------#
# Checks whether or not the player can hold an item. #
#----------------------------------------------------#
  def can_hold?(kind, item_id, number=1)
    if kind == 'item'
      item = $data_items[item_id]
    #elsif kind == 'weapon'
    #  item = $data_weapons[item_id]
    #elsif kind == 'armor'
    #  item = $data_armors[item_id]
    end
    if overall_checker(item, 1)
      return true
    else
      return false
    end
  end

  def item_vars(item1, item2, item3)
    $game_variables[341] = $game_party.combined_item_number(item1)
    $game_variables[342] = $game_party.combined_item_number(item2)
    $game_variables[343] = $game_party.combined_item_number(item3)
  end
  
#--------------#
# Stored Items #
#----------------------------#
# Returns your stored items. #
#----------------------------#
  def stored_items
    result = []
    for i in @storage.keys.sort
      result.push($data_items[i]) if @storage[i] > 0
    end
    return result
  end

  def stored_equipment
    result = []
    return result
  end
  
#-------------------#
# Stack Item Number #
#--------------------------------------------------#
# Returns the quantity of an item's stack maximum. #
#--------------------------------------------------#  
  def stack_item_number(item)
    number = @items[item.stack_max]
    return number == nil ? 0 : number
  end
  
#----------------#
# Item Max Carry #
#-------------------------------------------------------#
# Checks if you can carry any more of the current item. #
#-------------------------------------------------------#
  def item_max_carry(item)
    number = @items[item.stack_max]
    return number == nil ? 0 : number
  end
  

  
#--------------------#
# Stored Item Number #
#------------------------------------------------------#
# Returns the quantity of an item you have in storage. #
#------------------------------------------------------#
  def stored_item_number(item)
    number = @storage[item.id]
    return number == nil ? 0 : number
  end
  
#----------------------#
# Combined Item Number #
#----------------------------------------------------------------------------#
# Returns the quantity of an item you have in storage and in your inventory, #
# combining the two numbers into one, returning a single variable.           #
#----------------------------------------------------------------------------#
  def combined_item_number(item)
    number = item_number(item) + stored_item_number(item)
    return number == nil ? 0 : number
  end
  
#--------------------#
# Combined Item Lose #
#--------------------------------------------------------------------#
# Removes items from inventory and storage, for the crafting script. #
#--------------------------------------------------------------------#
  def combined_item_lose(item, n)
    if item_number(item) > 0
      lose_item(item, n)
    elsif stored_item_number(item) > 0
      unstore_item(item, n)
    else
      print "Error, overlapping values below 0.  Submit location of bug"
    end
  end
  
#--------------------#
# Combined Item Lose #
#--------------------------------------------------------------------#
# Removes items from inventory and storage, for the crafting script. #
#--------------------------------------------------------------------#
  def both_lose(item, n)
    if item_number(item) > 0
      lose_item(item, n)
    elsif stored_item_number(item) > 0
      unstore_item(item, n)
    end
  end
  
#------------#
# Store Item #
#--------------------------#
# Adds an item to storage. #
#--------------------------#
  def store_item(item, n)
    number = stored_item_number(item)
    @storage[item.id] = [[number + n, 0].max, 9999].min
  end
  

#---------------------------------#
# Store Item From Variable Amount #
#---------------------------------------------------------------#
# Adds an item to storage, based on a database variable amount. #
#---------------------------------------------------------------#
  def storev(item, n)
    number = stored_item_number(item)
    derp = $game_variables[n]
    @storage[item.id] = [[number + derp, 0].max, 9999].min
  end
  
#--------------#
# Unstore Item #
#-----------------------------#
# Takes an item from storage. #
#-----------------------------#
  def unstore_item(item, n)
    store_item(item, -n)
  end

#------------#
# Do Storage #
#--------------------------#
# Runs the storage window. #
#--------------------------#  
  def do_storage
    $game_temp.next_scene = "storage"
  end


end
