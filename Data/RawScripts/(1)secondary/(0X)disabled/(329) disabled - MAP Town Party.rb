class Game_Party < Game_Unit

  attr_reader :builder_array
  attr_reader :current_town
  attr_reader :builder_list
  attr_reader :town_upgrades
  
  def initialize_town
    town_area_list_initialize
    town_upgrade_list_initialize
    generate_default_map(false)
    builder_array_initialize
    initialize_worker_lists
    initialize_job_list
    hire_workers if $base_worker_hire == nil
  end
  
  def destructive_initialize_town
    town_area_list_initialize
    town_upgrade_list_initialize
    generate_default_map(true)
    builder_array_initialize
    initialize_worker_lists
    destructive_initialize_job_list
    initialize_hotspot_variables
  end
  

  # This list contains all the area numbers and key name.
  def town_area_list_initialize
	# value => ["Name", 
    @town_areas = PHI::AREA_DATA::TOWN_AREA_DATA
  end
  
  # ---------------------------- #
  # town_upgrade_list_initialize #
  # -------------------------------------------------- #
  # Creates the list for the individual area upgrades. #
  # This list contains all data for the sub areas.     #
  # -------------------------------------------------- #
  def town_upgrade_list_initialize
    @town_upgrades = PHI::AREA_DATA::TOWN_AREA_UPGRADES
  end
  
  # ----------------------- #
  # Create Initial Map Data #
  # ----------------------- #
  
  # Creates the arrays for the default town map data
  # making all areas "Empty".
  def generate_default_map(destructive = false)
    return @current_town if !@current_town.nil? and destructive == false
    width = PHI::TOWN_DATA::TOWN_MAX_WIDTH
    height = PHI::TOWN_DATA::TOWN_MAX_HEIGHT
    @current_town = {}
    # Determines town's main width
    for x in 0...width
      # Creates hash for each possible width
      @current_town[x] = {}
      for y in 0...height
        # Destructively includes an array containing "unknown",item_icon,data
        @current_town[x][y]
        @current_town[x][y] = PHI::AREA.new("Unknown Land")
      end
    end
    # Generates default areas destructively
    generate_default_areas
  end
  
  # Generates the default area list based on the moduled data.
  def generate_default_areas
    # Main constants to create default areas
    safehouse_x = PHI::TOWN_DATA::SAFEHOUSE_POSITION_X
    safehouse_y = PHI::TOWN_DATA::SAFEHOUSE_POSITION_Y
    town_exit_x = PHI::TOWN_DATA::TOWN_EXIT_X
    town_exit_y = PHI::TOWN_DATA::TOWN_EXIT_Y
    crystal_x = PHI::TOWN_DATA::DUNGEON_CRYSTAL_X
    crystal_y = PHI::TOWN_DATA::DUNGEON_CRYSTAL_Y
    shop_x = PHI::TOWN_DATA::BASE_SHOP_X
    shop_y = PHI::TOWN_DATA::BASE_SHOP_Y
    workshop_x = PHI::TOWN_DATA::WORKSHOP_X
    workshop_y = PHI::TOWN_DATA::WORKSHOP_Y
    
    # Creates the default areas.
    add_area(safehouse_x,safehouse_y,"Pioneer House") # Add Safehouse
    add_area(town_exit_x,town_exit_y,"Airship Dock") # Add town exit
    add_area(crystal_x,crystal_y,"Dungeon Lord") # Dungeon Lord
    add_area(shop_x,shop_y,"Coin Market") # Base Shop
    add_area(workshop_x,workshop_y,"Workshop") # Workshop
    add_area(4,3,"Town Center")
    add_area(3,3,"Farmland")# Empty Area
#~     add_area(3,3,"Empty Plot")# Empty Area
    add_area(5,3,"Fishing Hole")# Empty Area
#~     add_area(5,3,"Empty Plot")# Empty Area
    add_area(3,5,"Empty Plot")# Empty Area
    add_area(5,5,"Empty Plot")# Empty Area
  end
  
  # Displays an inspected form of the current town array row by row.
  def debug_rows
    width = @current_town.size
    for x in 0...width
      print "Row #{x}: ", @current_town[x].inspect
    end
  end
  
  # ----------------------- #
  # Change Current Town Map #
  # ----------------------- #
  
  # Is the current tile occupied with an area?
  def area_has_building?(index)
    new_x_and_y = convert_index(index)
    x = new_x_and_y[0]
    y = new_x_and_y[1]    
    # Checks if the current area is occupied
    area = @current_town[x][y]
    if area.name != "Empty Plot" and area.name != "Unknown Land"
      # if not empty and not unknkown, return true
      return true
    end
    # Else return false
    return false
  end
  
  def area_building_exists?(index)
    new_x_and_y = convert_index(index)
    x = new_x_and_y[0]
    y = new_x_and_y[1]
    # Checks if the current area is occupied
    area = @current_town[x][y]
    if area.name != "Empty Plot" and area.name != "Unknown Land" and area.name != "Road"
      # if not empty and not unknkown and not a road, return true
      return true
    end
    # Else return false
    return false
  end
  
  # Returns true or false for all 4 locations adjacent to the selected tile.
  # 0 for false, 1 for true - [left,up,right,down]
  def can_clear_area?(index)
    # Left - checks the tile to the left
    if (index - 1) >= 0 and (index - 1 ) <= 80
      index2 = index - 1
      return area_building_exists?(index2) if area_building_exists?(index2)
    end
    # Right - checks the tile to the right
    if (index + 1) >= 0 and (index + 1) <= 80
      index2 = index + 1
      return area_building_exists?(index2) if area_building_exists?(index2)
    end
    # Up - checks the tile above
    if (index - 9) >= 0 and (index - 9) <= 80
      index2 = index - 9
      return area_building_exists?(index2) if area_building_exists?(index2)
    end
    # Down - checks the tile below
    if (index + 9) >= 0 and (index + 9) <= 80
      index2 = index + 9
      return area_building_exists?(index2) if area_building_exists?(index2)
    end
    return false
  end
  
  # Checks if you can build or not
  def area_is_empty?(index)
    new_x_and_y = convert_index(index)
    x = new_x_and_y[0]
    y = new_x_and_y[1]
    area = @current_town[x][y]
    if area.name == "Empty Plot"
      return true
    end
    return false  
  end
  
  # Checks if the area is unknown
  def area_is_unknown?(index)
    new_x_and_y = convert_index(index)
    x = new_x_and_y[0]
    y = new_x_and_y[1]
    area = @current_town[x][y]
    if area.name == "Unknown Land"
      return true
    end
    return false
  end
  
  # Include the selected area desructively.
  def add_area(x,y,type_id)
    # Destroys data in tile
    @current_town[x][y] = PHI::AREA.new(type_id)
  end
  
  def move_area(x1,y1,x2,y2)
    
  end
  
  # Destroys an area replacing it with "Empty" status.
  def demolish_area(x,y)
    # Destructively includes a road into a tile
    @current_town[x][y].clear
    @current_town[x][y] = add_area(x,y,"Unknown Area")
  end
  
  # -------------------------- #
  # View Current Town Map Data #
  # -------------------------- #
  def debug_town
    print @current_town.inspect
  end
  
  def view_current_town
    return @current_town
  end
  
  def view_current_area_data(index)
    new_x_and_y = convert_index(index)
    x = new_x_and_y[0]
    y = new_x_and_y[1]
    return @current_town[x][y]
  end
  
  def view_default_town_area_data
    return @town_areas
  end
  
  def view_default_town_area_upgrades
    return @town_upgrades
  end
  
  def view_current_area_upgrades(index)
    x_and_y = convert_index(index)
    x = x_and_y[0]
    y = x_and_y[1]
    # returns area_upgrades
    area = @current_town[x][y]
    return area.upgrades
  end
  
  def view_current_area_data_index(index)
    x_and_y = convert_index(index)
    x = x_and_y[0]
    y = x_and_y[1]
    # returns area_id
    area = @current_town[x][y]
    return area
  end
  
  # Sort area data
  def sort_area_amount(area)
    amount = 0
    for x in 0...@current_town.size
      for y in 0...@current_town[x].size
        new_area = @current_town[x][y]
        if area.name == new_area.name
          amount += 1
        end
      end
    end  
#~     print "Area Name: ", area.name
#~     print "Amount: ", amount
#~     print "Possible Areas: ", area.possible_areas
#~     Graphics.wait(20)
    return true if amount < area.possible_areas
    return false
  end
  
  # Creates construction (0)options list from area data.
  def construction_options
    options = []
    area_data = @town_areas
    area_keys = area_data.keys
    for i in 0...area_keys.size
      area = PHI::AREA.new(area_keys[i])
      if area.name != "Empty Plot" and area.name != "Unknown Land" and area.name != "Road"
        options.push area if sort_area_amount(area)
      end
    end
    options.sort! {|x,y| x.sort_id <=> y.sort_id}
    return options
  end
  
  # Creates upgrade (0)options list from area data and current area list.
  def upgrade_options(index)
    # converts the index to communicate with accessors
    x_and_y = convert_index(index)
    x = x_and_y[0]
    y = x_and_y[1]
    area = @current_town[x][y]
    upgrades = area.upgrades
    new_options = []
    if !upgrades.empty?
      for upgrade in upgrades
        new_options.push upgrade if upgrade.completed == false
      end
    else
      new_options.push "No Upgrades"
    end
    return new_options
  end
  
  def area_active?(data)
    return data
  end
  
  def area_return_from_type(type)
    return if type.nil? or @current_town.nil?
    for x in 0...@current_town.size
      for y in 0...@current_town[0].size
        if type == @current_town[x][y].name
          return @current_town[x][y]
        end
      end
    end
  end
  
  def convert_index(index)
    x = index % 9
    if index > 0
      y = index / 9
    else
      y = 0
    end
    return [x,y,index]
  end

end
