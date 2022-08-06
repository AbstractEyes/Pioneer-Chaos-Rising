# ---------------------------------------------------------------------------- #
# FUN Game_Interpreter #
#--------------------- #
#  This is an add-on for the interpreter.  It was rather difficult
#  to create this aspect.  Each virtual map has events that
#  can activate if their settings are set to auto-run or parallel processing.
#  Thus making this effectively fork for these events.
#
# Instructions:
#    Place 
#    Any overwrites that conflict should be rewritten.  Contact me if you
#    require a simple rewrite of update or command_end, and you can't do it.
#
#  Alias:
#    clear
#  Overwrites:
#    update * see notes
#    command_end
#  New:
#    setup_virtual(list, event_id, map_id)
#==============================================================================

class Game_Interpreter
  #--------------------------------------------------------------------------
  # * ALIAS Clear
  #--------------------------------------------------------------------------
  alias old_clear clear
  def clear
    old_clear
    @vmap_id = 0
  end
  #--------------------------------------------------------------------------
  # * Virtual Event Setup
  #   This is an automated setup for anything virtual that is running
  #   autostart or parallel processing.
  #--------------------------------------------------------------------------
  def setup_virtual(list, event_id, map_id)
    clear
    @vmap_id = map_id
    @original_event_id = event_id     # Memorize event ID
    @event_id = event_id              # Memorize event ID
    @list = list                      # Memorize execution contents
    @index = 0                        # Initialize index
    cancel_menu_call                  # Cancel menu call
  end
  #--------------------------------------------------------------------------
  # * Starting Event Setup
  #--------------------------------------------------------------------------
  alias old_setup_starting_event setup_starting_event
  def setup_starting_event   
    old_setup_starting_event
    return if $v_maps.nil?
    $v_maps.refresh_force
    unless $v_maps._all.nil?
      unless $v_maps._all.empty?
        for map in $v_maps._all.values
          for event in map.events.values
            if event.starting                   # If a starting event is found
              event.clear_starting              # Clear starting flag
              setup_virtual(event.list, event.id, map.map_id)       # Set up event
              return
            end
          end
        end
      end
    end
  end
  #--------------------------------------------------------------------------
  # * OVERWRITE Frame Update
  # - Only change is added @vmap_id fork, to keep the event id
  #   from shifting to 0 when a virtual map event is using commands.
  #      You can alias this method, place above alias.
  #--------------------------------------------------------------------------
  def update
    loop do
      if $game_map.map_id != @map_id and @vmap_id == 0       # Map is different?
        @event_id = 0                       # Make event ID 0
      end
      if @child_interpreter != nil          # If child interpreter exists
        @child_interpreter.update           # Update child interpreter
        if @child_interpreter.running?      # If running
          return                            # Return
        else                                # After execution has finished
          @child_interpreter = nil          # Erase child interpreter
        end
      end
      if @message_waiting                   # Waiting for message finish
        return
      end
      if @moving_character != nil           # Waiting for move to finish
        if @moving_character.move_route_forcing
          return
        end
        @moving_character = nil
      end
      if @wait_count > 0                    # Waiting
        @wait_count -= 1
        return
      end
      if $game_troop.forcing_battler != nil # Forcing battle action
        return
      end
      if $game_temp.next_scene != nil       # Opening screens
        return
      end
      if @list == nil                       # If content list is empty
        setup_starting_event if @main       # Set up starting event
        return if @list == nil              # Nothing was set up
      end
      return if execute_command == false    # Execute event command
      @index += 1                           # Advance index
    end
  end
  #--------------------------------------------------------------------------
  # * OVERWRITE End Event
  # Required for the virtual maps AND for the normal maps.
  # The events will not function correctly without this method.
  #   Fully changed, alias after, or rewrite for your script inclusions.
  #--------------------------------------------------------------------------
  def command_end
    @list = nil                                       # Clear execution content list
    # If main map event
    if @vmap_id == 0
      $game_map.events[@event_id].unlock unless $game_map.events[@event_id].nil?    # Clear active event lock
    elsif @vmap_id > 0
      $v_maps.maps[@vmap_id].events[@event_id].unlock unless $v_maps.map(@vmap_id).events[@event_id].nil?# Clear virtual event lock
    end
    if @event_id > 999
      unless @virtual
        clear_individual_active_event(@event_id) if $game_map.events[@event_id].remove_event
      else
        clear_individual_virtual_event(@event_id) if $v_maps.map(@vmap_id).events[@event_id].remove_event
      end
    end
  end
  
end
