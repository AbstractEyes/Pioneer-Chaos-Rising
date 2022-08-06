# ---------------------------------------------------------------------------- #
# Interpreter Commands For Event Control #
# -------------------------------------- #  
# These are the add-ons for the interpreter to allow for full event creation
# control, built natively into the interpreter, to allow for full use of
# event creation, movement, and cleanup for said event handlers.
#
# ALL of these are based on your placeholder map_id, that you set inside
# the module CONFIG_SET
#
# Main Commands:
#
#   create_ev(x,y,map_id,*params)
#     x,y = destination of event                                     
#     map_id = destination map for event                             
#     params fork:                                                   
#     param[0] = type of fork                                        
#       Fork Types:                                                  
#         "name"                                                    
#           params[1] = "event name" in string   
#         "tags"                                                     
#           params[1] = ["MAIN_TAG","sub_tag"]                       
#         "xny" # Created using the placeholder map for xny.                                             
#           params[1] = [x(int),y(int)]                              
#     This handles the creation of an event using the parameters listed.
#
#   clear_self
#     Destroys the event this method is called from, but only after
#     its event list has concluded.  It continues its list until its demise.
# OVERWRITES command_end
#
#   clear_map_events(map_id):
#     This clears all the map extra events from the map_id.
#     You can use this to clean up maps manually, or to force
#     an active cleanup of these maps if you want to wipe the events.
#   
#   clear_all_virtual_extra_events
#     This clears all the extra events from ALL virtual maps.
#
#   clear_virtual_map_extra_events(map_id)
#     This clears all the extra events from the map id specified, if the
#     map has been designated as virtual from the clear_map_events(map_id).
#
#   clear_active_extra_events:
#     Clears all active extra events, removing them from the event array
#     and including an update to allow for cleanup with the spritesheet.
#
#   ###EX:###
#     create_ev(1,5,"name","1plant")
#     create_ev(5,7,"xny",[0,0])
#     create_ev(7,2,"tags",["RESOURCE","ore"]
#
# ---------------------------------------------------------------------------- #
# Created by Funplayer
#    You can use this in your public or commercial games, just give me credit.
# ---------------------------------------------------------------------------- # 

class Game_Interpreter
  alias old_setup setup
  def setup(list, event_id = 0)
    old_setup(list, event_id)
    @ev_handler = Fun_Event_Handler.new(@map_id)
  end

  def get_event
    return $game_map.events[@event_id]
  end
  # ---------------------------- #
  # Create Ev Handler (from tag) #
  # -------------------------------------------------------------- #
  # This handles the creation of an event using a tag based in the #
  # placeholder map.                                               #
  # -------------------------------------------------------------- #
  # x,y = destination of event                                     #
  # map_id = destination map for event                             #
  # params fork:                                                   #
  # param[0] = type of fork                                        #
  #   Fork Types:                                                  #
  #     "name"                                                     #
  #       params[1] = "event name" in string                       #
  #       params[2] = item number, if item                         #
  #     "tags"                                                     #
  #       params[1] = ["MAIN_TAG","sub_tag"]                       #
  #     "xny"                                                      #
  #       params[1] = [x(int),y(int)]                              #
  # -------------------------------------------------------------- #
  def create_ev(x,y,map_id, *params)
    map_id = @map_id if map_id == nil
    return @ev_handler.create_ev(x,y,map_id, *params)
  end
  # ---------- #
  # clear_self #
  # -------------------------------------------------------------------------- #
  # This interpreter script call destroys the event that calls it, but only    #
  # if the event is a new or boss type event.  Native events are not affected. #
  # Note:                                                                      #
  # *The event concludes its list before clearing itself from the event hash.  #
  # *This also destroys all future instances of this event in that map,        #
  # *to use the same event again you need to create it.                        #
  # -------------------------------------------------------------------------- #
  def clear_self
    p 'cleared self'
    @ev_handler.clear_self(@event_id)
  end
  # ---------------- #
  # clear_map_events #
  # -------------------------------------------- #
  # Clears all the extra events from the map_id. #
  # -------------------------------------------- #
  def clear_map_events(map_id)
    return if $map_extra_events[map_id].nil?
    @ev_handler.clear_extra_events(map_id)
  end
  # ---------------------- #
  # clear_individual_event #
  # -------------------------------------------------------------- #
  # This destroys all associated self switches with event as well. #
  #    This is POST PROCESSING:                                    #
  #      Do not call on its own.                                   #
  # -------------------------------------------------------------- #
  def clear_individual_active_event(event_id)
    return p 'Event is nil.' if $game_map.events[@event_id].nil?
    p "Event destroyed: #{@event_id} - In Map: #{@map_id}" if $enable_console and $game_map.events[@event_id].remove_event
    $removed_events.push $game_map.events[event_id].__id__
    $game_map.events.delete(@event_id) if $game_map.events[@event_id].remove_event
    for key in $map_extra_events[@map_id].keys
      ev = $map_extra_events[@map_id][key]
      p ev.id if ev.id == @event_id and $enable_console
      if ev.id == @event_id
        skey = [@map_id, ev.id, "A"]
        $game_self_switches[skey] = false if !$game_self_switches[skey].nil?
        skey = [@map_id, ev.id, "B"]
        $game_self_switches[skey] = false if !$game_self_switches[skey].nil?
        skey = [@map_id, ev.id, "C"]
        $game_self_switches[skey] = false if !$game_self_switches[skey].nil?
        skey = [@map_id, ev.id, "D"]
        $game_self_switches[skey] = false if !$game_self_switches[skey].nil?
        $game_map.events.delete(ev.event.id)
        $map_extra_events[@map_id].delete(key)
        break
      end
    end
  end
  
  def clear_individual_virtual_event(event_id)
    return p "Event is nil." if $v_maps.maps[@map_id].events[@event_id].nil?
    p "Event destroyed: #{@event_id} - In Map: #{@map_id}" if $enable_console and $virtual_maps[@map_id].events[@event_id].remove_event
    $removed_events.push $v_maps.maps[@map_id].events[event_id].__id__
    $v_maps.maps[@map_id].events.delete(@event_id) if $v_maps.maps[@map_id].events[@event_id].remove_event
    for key in $map_extra_events[@map_id].keys
      ev = $map_extra_events[@map_id][key]
      p ev.id if ev.id == @event_id and $enable_console
      if ev.id == @event_id
        skey = [@map_id, ev.id, "A"]
        $game_self_switches[skey] = false if !$game_self_switches[skey].nil?
        skey = [@map_id, ev.id, "B"]
        $game_self_switches[skey] = false if !$game_self_switches[skey].nil?
        skey = [@map_id, ev.id, "C"]
        $game_self_switches[skey] = false if !$game_self_switches[skey].nil?
        skey = [@map_id, ev.id, "D"]
        $game_self_switches[skey] = false if !$game_self_switches[skey].nil?
        $game_map.events.delete(ev.event.id)
        $map_extra_events[@map_id][key] = nil
        break
      end
    end
  end
  
end