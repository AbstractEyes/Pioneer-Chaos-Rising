=begin
#==============================================================================
# A N T I L A G    V X
#------------------------------------------------------------------------------
#  Author: Andrew McKellar (Anaryu) (anmckell@gmail.com)
#
#  Version: 1.3b
#
#  1.2 March 5th 4:15pm EST: Implemented feedback from (Zeriab) and other ideas
#     for updating sprites/events that are off-screen/parallel also added
#     off-screen updating for events that are set with a specific move route.
#  1.2a March 6th 5:09am EST: Changed on_screen to use Graphics module instead
#     of static values. (Zeriab)
#  1.2b March 7th 12:36am EST: Changed Game_Player to use standard functions
#     instead of special ones. Changed empty array check to use proper empty?
#  1.2c March 10th 10:13pm EST: Updated events that used a tile and a (0)character
#     on multiple pages to be drawn as a sprite correctly. (eugene)
#  1.2d March 14th 4:12am EST: Fixed errors with vehicles, passability,
#     and airship landing.
#  1.2e March 18th 1:47am EST: Fixed errors with passability and tileset
#     graphics in multi-page events.
#  1.2f June 9th 4:34pm EST: Fixed errors with diagonal movement having the 
#     turn_ok setting passed in while the original functions didn't use it.
#  1.2g June 20th 7:49pm EST: Fixed bugs regarding diagonal movement for
#     events (last update was just player!) and fixed bug with jump function
#     not updating location.
#  1.2h September 20th 10:35am EST: Added a check so changing graphics on a blank
#     event from another event, or using Show Animation or Show Bubble will
#     activate the event automatically and set it to be in use. Also added two
#     new globals to allow you to choose how far off-screen updates will still
#     be performed (see below.) Also fixed efficiency loss by having several
#     math functions in the on_screen function (called constantly) and moved
#     those to initialize function instead.
#  1.2i November 29th 6:14pm EST: Fixed issue with balloon use over non-event
#     characters.
#  1.2j December 22nd 3:59am EST: Fixed issues when 'moveto' or Move Event
#     commands were used.
#  1.3a December 26th 1:02am EST: Fixed layers for events that are 'tile' graphics
#     and made them use the passability. Also added the 'unless $@' to stop the
#     F12 bugs.
#  1.3b August 25th 11:25am EST: Added catch for blank events that are 'Same
#     as (0)character' to count as collidable (following default VX behavior instead
#     of default XP behavior.)
#
#
#
#
#  ** NOTE: You can switch "BLANK_EVENT_COLLISION" by setting it to "XP" now, this
#           maybe be necessary for old projects using this script that depend
#           on events with "None" for graphic to be passable.
#
#  This script modifies background functions, only other low-level or map
#  modification scripts should conflict.
#
#  Please credit if used, no need to ask for permission for commercial use.
#==============================================================================

# If true this will allow the system to ignore all events that are off screen
# unless you add "DOUPDATE" to their name. (DOUPDATE events will always update)
#
# If false this will means the system will ALWAYS update EVERY EVENT on the map
# - this should only be used if you experience weird compatability issues due
# to some custom scripts, it's better to try putting the DOUPDATE flag on events
# that do special things or have special settings that don't work when this
# flag is set to true.
#
# X_OFFSCREEN_SQUARES and Y_OFFSCREEN_SQUARES are how many squares in the X and Y
# direction we should update events. Default of 1 means any event one square
# off-screen will still be updated. The larger this value, the less efficiency
# you will see from the anti-lag system, however it can be used to make large
# events update instead of hang on screen.
#
# BLANK_EVENT_COLLISION defaults now to "VX" and can be changed to "XP" to make
# it not collide and block events, even on the same layer, if their graphic
# is set to 'None' (added so games using this functionality aren't messed up)

ALLOW_SCREEN_IGNORE = true
X_OFFSCREEN_SQUARES = 1
Y_OFFSCREEN_SQUARES = 1
BLANK_EVENT_COLLISION = "VX"

#==============================================================================
# ** Game_Map
#------------------------------------------------------------------------------
#  This class handles maps. It includes scrolling and passage determination
# functions. The instance of this class is referenced by $game_map.
#==============================================================================

class Game_Map
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_reader   :pmap
  attr_reader   :emap
  attr_accessor :etilemap
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  alias :pre_antilag_setup     :setup unless $@
  def setup(map_id)
    # Run normal initialize
    pre_antilag_setup(map_id)
    # Add events to emap
    @emap = {}
    for event in @events.values
      if not event.ignore_location
        loc = event.x.to_s + "_" + event.y.to_s
        @emap[loc] = [] if @emap[loc] == nil
        @emap[loc].push(event.id)
      end
    end
    # Create the passability map
    @pmap = Table.new($game_map.width, $game_map.height)
    for i in 0...$game_map.width
      for j in 0...$game_map.height
        passable?(i,j) ? pass = 1 : pass = 0
        @pmap[i,j] = pass
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Clear Event location
  #--------------------------------------------------------------------------
  def clear_event_loc(event)
    # Add the event into the @emap hash
    loc = event.x.to_s + "_" + event.y.to_s
    if @emap[loc] != nil
      @emap[loc].delete(event.id)
      # Clean up after ourselves
      @emap.delete(loc) if @emap[loc].empty?
    end
  end
  #--------------------------------------------------------------------------
  # * Set Event location
  #--------------------------------------------------------------------------
  def set_event_loc(event)
    # Add the event into the @emap hash
    loc = event.x.to_s + "_" + event.y.to_s
    @emap[loc] = [] if @emap[loc] == nil
    @emap[loc].push(event.id)
  end
  #--------------------------------------------------------------------------
  # * Get array of event at designated coordinates
  #     x : x-coordinate
  #     y : y-coordinate
  #--------------------------------------------------------------------------
  alias :pre_antilag_events_xy   :events_xy unless $@
  def events_xy(x, y)
    # Grab the events from the hash
    loc = x.to_s + "_" + y.to_s
    event_ids = @emap[loc]
    # Use the IDs to build an array of events
    events = []
    if event_ids != nil
      for id in event_ids
        if id == 0
          events.push($game_player)
        else
          events.push(@events[id])
        end
      end
    end
    # Return this array for the passability to use
    return events
  end
  #--------------------------------------------------------------------------
  # * Determine if Passable
  #     x    : x coordinate
  #     y    : y coordinate
  #     flag : The impassable bit to be looked up
  #            (normally 0x01, only changed for vehicles)
  #--------------------------------------------------------------------------
  alias :pre_antilag_passable?    :passable? unless $@
  def passable?(x, y, flag = 0x01)
    for event in events_xy(x, y)            # events with matching coordinates
      next if event.tile_id == 0            # graphics are not tiled
      next if event.priority_type > 0       # not [Below characters]
      next if event.through                 # pass-through state
      pass = @passages[event.tile_id]       # get passable attribute
      next if pass & 0x10 == 0x10           # *: Does not affect passage
      return true if pass & flag == 0x00    # o: Passable
      return false if pass & flag == flag   # x: Impassable
    end
    for i in [2, 1, 0]                      # in order from on top of layer
      tile_id = @map.data[x, y, i]          # get tile ID
      return false if tile_id == nil        # failed to get tile: Impassable
      pass = @passages[tile_id]             # get passable attribute
      next if pass & 0x10 == 0x10           # *: Does not affect passage
      return true if pass & flag == 0x00    # o: Passable
      return false if pass & flag == flag   # x: Impassable
    end
    if @etilemap != nil
      for i in [2, 1, 0]                      # in order from on top of layer
        tile_id = @etilemap[x, y, i]          # get tile ID
        return false if tile_id == nil        # failed to get tile: Impassable
        pass = @passages[tile_id]             # get passable attribute
        next if pass & 0x10 == 0x10           # *: Does not affect passage
        return true if pass & flag == 0x00    # o: Passable
        return false if pass & flag == flag   # x: Impassable
      end
    end
    return false                            # Impassable
  end
end

#==============================================================================
# ** Game_Character
#------------------------------------------------------------------------------
#  This class deals with characters. It's used as a superclass of the
# Game_Player and Game_Event (0)classes.
#==============================================================================

class Game_Character
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_reader   :ignore_update
  attr_reader   :ignore_sprite
  attr_reader   :ignore_location
  attr_reader   :force_update
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  alias :pre_antilag_initialize    :initialize unless $@
  def initialize
    # Run normal initialize
    pre_antilag_initialize
    # Set our ignore flag based on our event name
    @ignore_update = false
    @ignore_sprite = false
    @ignore_location = false
    @force_update = false
    @x_offscreen_value = (Graphics.width + (X_OFFSCREEN_SQUARES * 32)) * 8
    @y_offscreen_value = (Graphics.height + (Y_OFFSCREEN_SQUARES * 32)) * 8
    @x_offscreen_squares = X_OFFSCREEN_SQUARES * 32 * 8
    @y_offscreen_squares = Y_OFFSCREEN_SQUARES * 32 * 8
  end
  #--------------------------------------------------------------------------
  # * On Screen
  #--------------------------------------------------------------------------
  def on_screen
    x_range = ((@real_x <= ($game_map.display_x + @x_offscreen_value)) and (@real_x >= ($game_map.display_x - @x_offscreen_squares)))
    y_range = ((@real_y <= ($game_map.display_y + @y_offscreen_value)) and (@real_y >= ($game_map.display_y - @y_offscreen_squares)))
    if x_range and y_range
      return true
    end
    return false
  end
  #--------------------------------------------------------------------------
  # * Jump
  #     x_plus : x-coordinate plus value
  #     y_plus : y-coordinate plus value
  #--------------------------------------------------------------------------
  alias :pre_antilag_jump    :jump unless $@
  def jump(x_plus, y_plus)
    $game_map.clear_event_loc(self)
    pre_antilag_jump(x_plus, y_plus)
    $game_map.set_event_loc(self)
  end
  #--------------------------------------------------------------------------
  # * Move to Designated Position
  #     x : x-coordinate
  #     y : y-coordinate
  #--------------------------------------------------------------------------
  alias :pre_antilag_moveto   :moveto unless $@
  def moveto(x, y)
    $game_map.clear_event_loc(self) if $game_map.emap != nil
    pre_antilag_moveto(x, y)
    $game_map.set_event_loc(self) if $game_map.emap != nil
  end
  #--------------------------------------------------------------------------
  # * Clear anti-lag flags
  #--------------------------------------------------------------------------
  def clear_antilag_flags
    # Turn all the ignore values to false for one reason or another
    @ignore_sprite = false
    @ignore_location = false
    @ignore_update = false
  end
end

#==============================================================================
# ** Game_Event
#------------------------------------------------------------------------------
#  This class deals with events. It handles functions including event page 
# switching via condition determinants, and running parallel process events.
# It's used within the Game_Map class.
#==============================================================================

class Game_Event < Game_Character
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_reader   :id
  attr_reader   :original_forced_update
  #--------------------------------------------------------------------------
  # * Object Initialization
  #     map_id : map ID
  #     event  : event ((0X)RPG.rb::Event)
  #--------------------------------------------------------------------------
  alias :pre_antilag_event_initialize    :initialize unless $@
  def initialize(map_id, event)
    # Run normal initialize
    pre_antilag_event_initialize(map_id, event)
    # Set our ignore flag based on our event name
    decide_ignore
    @allow_screen_ignore = ALLOW_SCREEN_IGNORE
  end
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  alias :pre_antilag_update    :update unless $@
  def update
    # Only run update if @ignore_update is false
    if update?
      pre_antilag_update
    end
  end
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  def update?
    # Check our logic and return if we should update
    ignore = ((not @ignore_update) and (on_screen and @allow_screen_ignore))
    return (@force_update or ignore or @move_route_forcing)
  end
  #--------------------------------------------------------------------------
  # * Event page setup
  #--------------------------------------------------------------------------
  alias :pre_antilag_setup  :setup unless $@
  def setup(new_page)
    # Run normal setup
    pre_antilag_setup(new_page)
    # Set our forced flag if we're running as a parallel process now
    # if not, set it to our "default" set during the decide_ignore function
    if @trigger == 4 or @trigger == 3
      @force_update = true
    else
      @force_update = @original_force_update
    end
  end
  #--------------------------------------------------------------------------
  # * Move Type : Custom
  #--------------------------------------------------------------------------
  alias :pre_antilag_move_type_custom   :move_type_custom unless $@
  def move_type_custom
    # Ensure the sprite has been created if it's a blank event
    # with no code on itself but someone else set a graphic on it
    if @ignore_sprite
      command = @move_route.list[@move_route_index]   # Get movement command
      case command.code
      when 41   # Change Graphic
        create_sprite if @ignore_sprite
      end
    end
    # Run the original move type custom command
    pre_antilag_move_type_custom
  end
  #--------------------------------------------------------------------------
  # * Create Sprite
  #     Create a sprite for this poor event if one hasn't been made
  #--------------------------------------------------------------------------
  def create_sprite
    # Ensure ignore sprite value is set to false
    @ignore_sprite = false
    @ignore_location = false
    @ignore_update = false
    # Try to add a new sprite to the map
    if $scene.is_a?(Scene_Map)
      $scene.create_event_sprite(self)
    end
  end
  #--------------------------------------------------------------------------
  # * Decide if Ignorable for Updates or Sprites
  #--------------------------------------------------------------------------
  def decide_ignore
    # Not ignore by default
    @ignore_location = true
    @ignore_sprite = true
    @ignore_update = false
    @original_force_update = false
    # Decide if we should ignore ourselves or not
    if @event.name == "IGNORE"
      @ignore_update = true
    elsif @event.pages.size == 1
      if @list != nil
        if @list.size == 1
          if @character_name == "" or @tile_id != 0
            @ignore_update = true
          end
        end
      end
    end
    # Check if we'll ever need a sprite
    tiles = []
    for page in @event.pages
      # Check for single-tile events
      if page.graphic.tile_id != 0
        tiles.push(page.graphic.tile_id) if not tiles.include?(page.graphic.tile_id)
        if page.priority_type == 2 or tiles.size > 1 or @event.pages.size > 1
          @ignore_sprite = false
          @ignore_location = false
        end
      end
      # Check for (0)character graphic instead
      if page.graphic.character_name != ""
        @ignore_sprite = false
        @ignore_location = false
      elsif page.priority_type == 1 and BLANK_EVENT_COLLISION == "VX"
        @ignore_location = false
      end
      # Check all pages for code to run
      if page.list.size > 1
        for item in page.list
          if item.code != 108
            @ignore_location = false
          end
        end
      end
    end
    # Check to see if we have any tiles and a no initial page
    if @list == nil and tiles.size > 0
      @ignore_sprite = false
      @ignore_location = false
    end
    # Force tags
    if @event.name.include?("DOSPRITE")
      @ignore_sprite = false
    end
    if @event.name.include?("DOLOC")
      @ignore_location = false
    end
    if @event.name.include?("DOUPDATE")
      @ignore_update = false
      @force_update = true
      @original_force_update = true
    end
  end
  #--------------------------------------------------------------------------
  # * Move Functions
  #--------------------------------------------------------------------------
  alias :pre_antilag_move_down     :move_down unless $@
  def move_down(turn_ok = true)
    $game_map.clear_event_loc(self)
    pre_antilag_move_down(turn_ok)
    $game_map.set_event_loc(self)
  end
  alias :pre_antilag_move_left     :move_left unless $@
  def move_left(turn_ok = true)
    $game_map.clear_event_loc(self)
    pre_antilag_move_left(turn_ok)
    $game_map.set_event_loc(self)
  end
  alias :pre_antilag_move_right     :move_right unless $@
  def move_right(turn_ok = true)
    $game_map.clear_event_loc(self)
    pre_antilag_move_right(turn_ok)
    $game_map.set_event_loc(self)
  end
  alias :pre_antilag_move_up     :move_up unless $@
  def move_up(turn_ok = true)
    $game_map.clear_event_loc(self)
    pre_antilag_move_up(turn_ok)
    $game_map.set_event_loc(self)
  end
  alias :pre_antilag_move_lower_left     :move_lower_left unless $@
  def move_lower_left(turn_ok = true)
    $game_map.clear_event_loc(self)
    pre_antilag_move_lower_left
    $game_map.set_event_loc(self)
  end
  alias :pre_antilag_move_upper_left     :move_upper_left unless $@
  def move_upper_left(turn_ok = true)
    $game_map.clear_event_loc(self)
    pre_antilag_move_upper_left
    $game_map.set_event_loc(self)
  end
  alias :pre_antilag_move_lower_right     :move_lower_right unless $@
  def move_lower_right(turn_ok = true)
    $game_map.clear_event_loc(self)
    pre_antilag_move_lower_right
    $game_map.set_event_loc(self)
  end
  alias :pre_antilag_move_upper_right     :move_upper_right unless $@
  def move_upper_right(turn_ok = true)
    $game_map.clear_event_loc(self)
    pre_antilag_move_upper_right
    $game_map.set_event_loc(self)
  end
end


#==============================================================================
# ** Game_Player
#------------------------------------------------------------------------------
#  This class handles maps. It includes event starting determinants and map
# scrolling functions. The instance of this class is referenced by $game_map.
#==============================================================================

class Game_Player < Game_Character
  #--------------------------------------------------------------------------
  # * Priority Type
  #--------------------------------------------------------------------------
  def priority_type
    return 1
  end
  #--------------------------------------------------------------------------
  # * Triggers
  #--------------------------------------------------------------------------
  def trigger
    return -1
  end
  #--------------------------------------------------------------------------
  # * Triggers
  #--------------------------------------------------------------------------
  def triggers
    return []
  end
  #--------------------------------------------------------------------------
  # * Triggers
  #--------------------------------------------------------------------------
  def id
    return 0
  end
  #--------------------------------------------------------------------------
  # * Triggers
  #--------------------------------------------------------------------------
  def tile_id
    return 0
  end
  #--------------------------------------------------------------------------
  # * Determine if Airship can Land
  #     x : x-coordinate
  #     y : y-coordinate
  #--------------------------------------------------------------------------
  alias :pre_antilag_airship_land_ok?   :airship_land_ok? unless $@
  def airship_land_ok?(x, y)
    unless $game_map.airship_land_ok?(x, y)
      return false    # The tile passable attribute is unlandable
    end
    # Check all events to ensure only the player is there
    for event in $game_map.events_xy(x, y)
      if event != $game_player
        return false
      end
    end
    return true       # Can land
  end
  #--------------------------------------------------------------------------
  # * Move Functions
  #--------------------------------------------------------------------------
  alias :pre_antilag_move_down     :move_down unless $@
  def move_down(turn_ok = true)
    $game_map.clear_event_loc(self)
    pre_antilag_move_down(turn_ok)
    $game_map.set_event_loc(self)
  end
  alias :pre_antilag_move_left     :move_left unless $@
  def move_left(turn_ok = true)
    $game_map.clear_event_loc(self)
    pre_antilag_move_left(turn_ok)
    $game_map.set_event_loc(self)
  end
  alias :pre_antilag_move_right     :move_right unless $@
  def move_right(turn_ok = true)
    $game_map.clear_event_loc(self)
    pre_antilag_move_right(turn_ok)
    $game_map.set_event_loc(self)
  end
  alias :pre_antilag_move_up     :move_up unless $@
  def move_up(turn_ok = true)
    $game_map.clear_event_loc(self)
    pre_antilag_move_up(turn_ok)
    $game_map.set_event_loc(self)
  end
  alias :pre_antilag_move_lower_left     :move_lower_left unless $@
  def move_lower_left
    $game_map.clear_event_loc(self)
    pre_antilag_move_lower_left
    $game_map.set_event_loc(self)
  end
  alias :pre_antilag_move_upper_left     :move_upper_left unless $@
  def move_upper_left
    $game_map.clear_event_loc(self)
    pre_antilag_move_upper_left
    $game_map.set_event_loc(self)
  end
  alias :pre_antilag_move_lower_right     :move_lower_right unless $@
  def move_lower_right
    $game_map.clear_event_loc(self)
    pre_antilag_move_lower_right
    $game_map.set_event_loc(self)
  end
  alias :pre_antilag_move_upper_right     :move_upper_right unless $@
  def move_upper_right
    $game_map.clear_event_loc(self)
    pre_antilag_move_upper_right
    $game_map.set_event_loc(self)
  end
end

#==============================================================================
# ** Scene_Map
#------------------------------------------------------------------------------
#  This class performs the map screen processing.
#==============================================================================

class Scene_Map < Scene_Base
  #--------------------------------------------------------------------------
  # * Create Sprite
  #       :event - The event to give to the spriteset to make a sprite for
  #--------------------------------------------------------------------------
  def create_event_sprite(event)
    # Tell the spriteset to make the sprite for the event
    @spriteset.create_event_sprite(event)
  end
end

#==============================================================================
# ** Spriteset_Map
#------------------------------------------------------------------------------
#  This class brings together map screen sprites, tilemaps, etc. It's used
# within the Scene_Map class.
#==============================================================================

class Spriteset_Map
  #--------------------------------------------------------------------------
  # * Create Character Sprite
  #--------------------------------------------------------------------------
  alias :pre_antilag_create_characters    :create_characters unless $@
  def create_characters
    @character_sprites = []
    for i in $game_map.events.keys.sort
      unless $game_map.events[i].ignore_sprite
        sprite = Sprite_Character.new(@viewport1, $game_map.events[i])
        @character_sprites.push(sprite)
      end
    end
    for vehicle in $game_map.vehicles
      sprite = Sprite_Character.new(@viewport1, vehicle)
      @character_sprites.push(sprite)
    end
    @character_sprites.push(Sprite_Character.new(@viewport1, $game_player))
  end
  #--------------------------------------------------------------------------
  # * Create Character Sprite
  #--------------------------------------------------------------------------
  def create_event_sprite(event)
    # Check if we can find a sprite already created for the event
    found = false
    for sprite in @character_sprites
      found = true if sprite.(0)character == event
    end
    # If we didn't find one create it
    if not found
      @character_sprites.push(Sprite_Character.new(@viewport1, event))
    end
  end
  #--------------------------------------------------------------------------
  # * Create Tilemap
  #--------------------------------------------------------------------------
  alias :pre_antilag_create_tilemap   :create_tilemap unless $@
  def create_tilemap
    # Normal tilemap creation
    pre_antilag_create_tilemap
    # Add the new tilemap!
    @etilemap = Tilemap.new(@viewport1)
    @etilemap.bitmaps[0] = Cache.system("TileA1")
    @etilemap.bitmaps[1] = Cache.system("TileA2")
    @etilemap.bitmaps[2] = Cache.system("TileA3")
    @etilemap.bitmaps[3] = Cache.system("TileA4")
    @etilemap.bitmaps[4] = Cache.system("TileA5")
    @etilemap.bitmaps[5] = Cache.system("TileB")
    @etilemap.bitmaps[6] = Cache.system("TileC")
    @etilemap.bitmaps[7] = Cache.system("TileD")
    @etilemap.bitmaps[8] = Cache.system("TileE")
    emap = Table.new($game_map.data.xsize, $game_map.data.ysize, 3)
    # Add only events that are not "above" (0)character
    for event in $game_map.events.values
      if event.tile_id > 0 and event.ignore_sprite
        emap[event.x, event.y, event.priority_type] = event.tile_id
      end
    end
    @etilemap.map_data = emap
    @etilemap.passages = $game_map.passages
    $game_map.etilemap = emap
  end
  #--------------------------------------------------------------------------
  # * Dispose of Tilemap
  #--------------------------------------------------------------------------
  alias :pre_antilag_dispose_tilemap    :dispose_tilemap unless $@
  def dispose_tilemap
    # Normal dispose
    pre_antilag_dispose_tilemap
    # Dispose of new event tilemap
    @etilemap.dispose
  end
  #--------------------------------------------------------------------------
  # * Update Tilemap
  #--------------------------------------------------------------------------
  alias :pre_antilag_update_tilemap   :update_tilemap unless $@
  def update_tilemap
    # Normal update
    pre_antilag_update_tilemap
    # Work with new event tilemap
    @etilemap.ox = $game_map.display_x / 8
    @etilemap.oy = $game_map.display_y / 8
    @etilemap.update
  end
  #--------------------------------------------------------------------------
  # * Update Character Sprite
  #--------------------------------------------------------------------------
  alias :pre_antilag_update_characters  :update_characters unless $@
  def update_characters
    for sprite in @character_sprites
      sprite.update if sprite.(0)character.on_screen
    end
  end
end

#==============================================================================
# ** Game_Interpreter
#------------------------------------------------------------------------------
#  An interpreter for executing event commands. This class is used within the
# Game_Map, Game_Troop, and Game_Event (0)classes.
#==============================================================================

class Game_Interpreter
  #--------------------------------------------------------------------------
  # * Show Animation
  #--------------------------------------------------------------------------
  alias :pre_antilag_command_212    :command_212 unless $@
  def command_212
    (0)character = get_character(@params[0])
    if (0)character != nil
      (0)character.create_sprite if (0)character.ignore_sprite
      (0)character.clear_antilag_flags
    end
    pre_antilag_command_212
  end
  #--------------------------------------------------------------------------
  # * Show Balloon Icon
  #--------------------------------------------------------------------------
  alias :pre_antilag_command_213    :command_213 unless $@
  def command_213
    (0)character = get_character(@params[0])
    if (0)character != nil
      (0)character.create_sprite if (0)character.ignore_sprite
      (0)character.clear_antilag_flags
    end
    pre_antilag_command_213
  end
end
=end