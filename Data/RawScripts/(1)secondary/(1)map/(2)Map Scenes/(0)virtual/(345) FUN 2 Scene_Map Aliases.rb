# ----------------- #
# Scene_Map Changes #
# --------------------------------------------------------------- #
# 
# Alias:
#   start
#   update_basic
#   update
# Overwrite:
#   update_player_transfer
# --------------------------------------------------------------- #

class Scene_Map < Scene_Base
  attr_reader :vm_handler
  #--------------------------------------------------------------------------
  # * Start processing
  #--------------------------------------------------------------------------
  alias old_start start
  def start(*args)
    old_start(*args)
    # Required refresh of virtualized maps on start.
    $v_maps.update unless $v_maps.nil?
  end
  #--------------------------------------------------------------------------
  # * ALIAS Basic Update Processing
  #--------------------------------------------------------------------------
  alias old_update_basic update_basic
  def update_basic
    old_update_basic
    $v_maps.update  unless $v_maps.nil?               # *Updates virtual map after game map
  end
  #--------------------------------------------------------------------------
  # * ALIAS Frame Update
  #--------------------------------------------------------------------------
  alias old_update update
  def update
    old_update
    unless $game_message.visible      # Unless displaying a message
      $v_maps.update if MAP_DATA::VIRTUAL_ENABLED  && !$v_maps.nil?
      #update_bosses if MAP_DATA::VIRTUAL_ENABLED
      #update_added_events if $new_events
    end
  end
  
  def combine_virtual_to_active
    # replace the game map events with the virtual map events
    $game_map.events = $v_maps.map($game_map.map_id).events
    $game_map.interpreter = Game_Interpreter.new(0, true)
    # dispose virtual
    $v_maps.halt($game_map.map_id)
  end
  
  def combine_active_to_virtual
    # Create a new virtual map if the game map has the tag "virtual"
    $v_maps.replace_events($game_map.map_id, $game_map.events)
    $v_maps.new_interpreter($game_map.map_id)
#~     $virtual_maps[$game_map.map_id].interpreter = Game_Interpreter.new(0, false)
    $v_maps.resume($game_map.map_id)
    # dispose virtual
  end
  
  # ------------- #
  # update_bosses #
  # ----------------------------------------------------------------- #
  # This updates the boss loops stored in the $boss_list variable.    #
  #   These are required to be updated, unless you want to halt them. #
  # ----------------------------------------------------------------- #
  def update_bosses
    $boss_list = {} if $boss_list.nil?
    return if $boss_list.empty?
    for boss in $boss_list.keys
      if $boss_list[boss].nil?
        $boss_list.delete(boss)
        next
      end
      $boss_list[boss].update
    end
  end
  
  #--------------------------------------------------------------------------
  # * OVERWRITE Player Transfer  Processing
  #--------------------------------------------------------------------------
  def update_transfer_player
    return unless $game_player.transfer?
    fade = (Graphics.brightness > 0)
    fadeout(30) if fade
    $game_player.perform_transfer   # Execute player transfer
    if MAP_DATA::VIRTUAL_ENABLED
      p 'virtual map transfer enabled and functional'
      # Make the active map contain virtual events.
      combine_virtual_to_active if $v_maps != nil && $v_maps.exists?($game_map.map_id)
      # Create a virtual map, if the map exists with a tag for virtualization.
      combine_active_to_virtual if $v_maps != nil &&  $v_maps.exists?($game_map.map_id)
      $v_maps.refresh if $v_maps != nil
      $v_maps.update if $v_maps != nil
    end
    $game_map.autoplay              # Automatically switch BGM and BGS
    $game_map.update
    $new_events = false
    @spriteset.dispose              # Dispose of sprite set
    Graphics.wait(15)
    @spriteset = Spriteset_Map.new  # Recreate sprite set
    fadein(30) if fade
    Input.update
  end
#~   
  def update_added_events
    $game_map.refresh
    #@spriteset.dispose
    #@spriteset = Spriteset_Map.new  # Recreate sprite set
    $new_events = false
  end
  
end
