#==============================================================================
# ** Game_Map
#------------------------------------------------------------------------------
#  This class handles maps. It includes scrolling and passage determination
# functions. The instance of this class is referenced by $game_map.
#==============================================================================

class Game_Map
  CENTER_X = ($screen_width / 2 - 16) * 8     # Screen center X coordinate * 8
  CENTER_Y = ($screen_height / 2 - 16) * 8     # Screen center Y coordinate * 8

  alias new_initialize_for_stuffs initialize
  def initialize(*params)
    new_initialize_for_stuffs
    @scroll_rest2 = 0
    @scroll_direction2 = 0
    @scroll_speed = 0
  end

  def snap_to_event(event_id)
    event = $game_player if event_id == -1
    event = @events[event_id] if event_id >= 0
    x1 = event.x
    y1 = event.y
    display_x = x1 * 256 - CENTER_X                    # Calculate coordinates
    unless loop_horizontal?                 # No loop horizontally?
      max_x = (width - 20) * 256            # Calculate max value
      display_x = [0, [display_x, max_x].min].max     # Adjust coordinates
    end
    display_y = y1 * 256 - CENTER_Y                    # Calculate coordinates
    unless loop_vertical?                   # No loop vertically?
      max_y = (height - 15) * 256           # Calculate max value
      display_y = [0, [display_y, max_y].min].max     # Adjust coordinates
    end
    set_display_pos(display_x, display_y)
  end

  def snap_to_player(player=$game_player)
    return if @map.nil?
    x1 = player.x
    y1 = player.y
    display_x = x1 * 256 - CENTER_X                    # Calculate coordinates
    unless loop_horizontal?                 # No loop horizontally?
      max_x = (width - 20) * 256            # Calculate max value
      display_x = [0, [display_x, max_x].min].max     # Adjust coordinates
    end
    display_y = y1 * 256 - CENTER_Y                    # Calculate coordinates
    unless loop_vertical?                   # No loop vertically?
      max_y = (height - 15) * 256           # Calculate max value
      display_y = [0, [display_y, max_y].min].max     # Adjust coordinates
    end
    set_display_pos(display_x, display_y)
  end
    
end