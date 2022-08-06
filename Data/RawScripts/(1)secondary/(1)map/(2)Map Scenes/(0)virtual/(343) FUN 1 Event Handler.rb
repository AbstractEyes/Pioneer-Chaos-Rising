# ---------------------------------------------------------------------------- #
# Event Handler
# ---------------------------------------------------------------------------- #
# This class is tacked onto every map on setup, but beforehand is nil.
# call with $game_map.ev_handler
# ---------------------------------------------------------------------------- #
# Created by:
#   Funplayer
#     Use, mod, share, steal, I don't care.  Just put my name in the credits.
# ---------------------------------------------------------------------------- #

class Fun_Event_Handler
  attr_accessor :map_id
  attr_accessor :newest_event
  def initialize(map_id)
    @map_id = map_id
    @placeholder_map = nil
    @newest_event = nil
  end
  # Standard create event handler.  Allows for the 3 types of events
  # to be greated.  See interpreter for details.
  def create_ev(x,y,map_id = @map_id, *params)
    @current_created_event = nil
    #return if at_capacity?(map_id)
    type = params[0]
    unless type.nil?
      if type == 'name'
        if params.size > 2; param2 = params[2]; else; param2 = nil; end
        create_ev_by_name(x,y,params[1],param2)
      elsif type == 'tags'
        create_ev_by_tags(x,y,params[1][0],params[1][1])
      elsif type == 'xny'
        create_ev_by_xny(x,y,params[1][0],params[1][1])
      end
      p "Event Created: X:#{x} Y: #{y} Map_ID: #{map_id} #{params.inspect}" if $enable_console
    end
  end

  # ----------------- #
  # create_ev_by_tags #
  # ---------------------------------------------------------- #
  # This creates an event by direct tags, without using the ev #
  # handler, or by using the handler directly to fork to it.   #
  # ---------------------------------------------------------- #
  # x,y = position for new event                               #
  # map_id = destination map for event                         #
  # main_tag = "MAIN_TAG"                                      #
  # sub_tag = "sub_tag"                                        #
  # ---------------------------------------------------------- #
  def create_ev_by_tags(x,y,main_tag,sub_tag)
    @placeholder_map = Game_Map.new(false)
    @placeholder_map.setup(MAP_DATA::PLACEHOLDER_MAP)
    for ev in @placeholder_map.events.values
      if ev.tag[0] == main_tag and ev.tag[1] == sub_tag
        $map_extra_events[@map_id] = {} if $map_extra_events[@map_id].nil?
        new_ev = new_event(x,y,@map_id,ev)
        $map_extra_events[@map_id][new_ev.event.id] = new_ev
        place_event(new_ev, @map_id)
      end
    end
    p "New Event ID: #{new_ev.event.id}" if $enable_console
  end
  # ----------------- #
  # create_ev_by_name #
  # -------------------------------------------------------- #
  # This creates an event by its name, without using the ev  #
  # handler, or by using the handler directly to fork to it. #
  # -------------------------------------------------------- #
  # x,y = position for new event                             #
  # map_id = destination map for event                       #
  # name of the event inside placeholder map.                #
  # -------------------------------------------------------- #
  def create_ev_by_name(x,y,name,item=nil)
    @placeholder_map = Game_Map.new(false)
    @placeholder_map.setup(MAP_DATA::PLACEHOLDER_MAP)
    for ev in @placeholder_map.events.values
      if ev.event.name == name
        $map_extra_events[@map_id] = {} if $map_extra_events[@map_id].nil?
        new_ev = new_event(x,y,@map_id,ev)
        p 'item number: ' + item.to_s
        p new_ev.list.inspect
        if item != nil
          # Todo: Prepare the interpreter forks.
          new_ev.list.each { |command|
            case command.code
              when 126
                command.parameters[0] = item
              when 111
                if command.parameters[1].include?('$game_party.can_hold?')
                  command.parameters[1] = command.parameters[1] + "('item'," + item.to_s + ')'
                end
              when 355
                if command.parameters[0].include?('display_item')
                  command.parameters[0] = 'display_item("' + item.to_s + '")'
                elsif command.parameters[0].include?('display_full')
                  command.parameters[0] = 'display_full("' + item.to_s + '")'
                end
              when 401
                if command.parameters[0].include?('Cannot pick up')
                  command.parameters[0] = command.parameters[0] + " \\ii[" + item.to_s + ']' + " \\ni[" + item.to_s + "] inventory full.\\^"
                else
                  command.parameters[0] = command.parameters[0] + " \\ii[" + item.to_s + ']' + " \\ni[" + item.to_s + "].\\^"
                end
            end
          }
        end
        new_ev.item_id = item
        $map_extra_events[@map_id][new_ev.event.id] = new_ev
        place_event(new_ev, @map_id)
      end
    end
    p "New Event ID: #{new_ev.event.id}" if $enable_console
  end

  def snag_ev(name, item=false)
    @placeholder_map = Game_Map.new(false)
    @placeholder_map.setup(MAP_DATA::PLACEHOLDER_MAP)
    for ev in @placeholder_map.events.values
      if ev.event.name == name
        if item
          ev.list.each { |command|
            case command.code
              when 126
                command.parameters[0] = item
              when 111
                if command.parameters[1].include?('$game_party.can_hold?')
                  command.parameters[1] = command.parameters[1] + "('item'," + item.to_s + ')'
                end
              when 355
                if command.parameters[0].include?('display_item')
                  command.parameters[0] = 'display_item("' + item.to_s + '")'
                elsif command.parameters[0].include?('display_full')
                  command.parameters[0] = 'display_full("' + item.to_s + '")'
                end
              when 401
                if command.parameters[0].include?('Cannot pick up')
                  command.parameters[0] = command.parameters[0] + " \\ii[" + item.to_s + ']' + " \\ni[" + item.to_s + "] inventory full.\\^"
                else
                  command.parameters[0] = command.parameters[0] + " \\ii[" + item.to_s + ']' + " \\ni[" + item.to_s + "].\\^"
                end
            end
          }
        end
        return ev.clone
      end
    end
  end
  # ---------------- #
  # create_ev_by_xny #
  # -------------------------------------------------------- #
  # This creates an event by its name, without using the ev  #
  # handler, or by using the handler directly to fork to it. #
  # -------------------------------------------------------- #
  # x,y = position for new event                             #
  # map_id = destination map for event                       #
  # x2,y2 = template event x,y                               #
  # -------------------------------------------------------- #
  def create_ev_by_xny(x,y,x2,y2)
    @placeholder_map = Game_Map.new(false)
    @placeholder_map.setup(MAP_DATA::PLACEHOLDER_MAP)
    ev_array = find_event_for_xny(x2,y2,@placeholder_map)
    for ev in ev_array
      $map_extra_events[map_id] = {} if $map_extra_events[map_id].nil?
      new_ev = new_event(x,y,@map_id,ev)
      $map_extra_events[@map_id][new_ev.event.id] = new_ev
      place_event(new_ev, @map_id)
    end
    p "New Event ID: #{new_ev.event.id}" if $enable_console
  end
  # --------- #
  # new_event #
  # ---------------------------------------------------- #
  # This is a function method for the create_ev methods. #
  # ---------------------------------------------------- #
  def new_event(x,y,map_id,ev)
    raw_event = ev.event
    raw_event.x = x
    raw_event.y = y
    raw_event.id = find_new_id(map_id)
    new_ev = Game_Event.new(map_id,raw_event)
    new_ev.new_event = true
    new_ev.new_x = x 
    new_ev.new_y = y
    new_ev.refresh
    @current_created_event = new_ev
    return new_ev
  end


  def find_new_id(map_id)
    (1000...2000).each do |key|
      return key unless $game_map.events.keys.include?(key)
    end
    #return $map_extra_events[map_id].keys.size + 1000
  end

  def place_event(new_ev, map_id)
    if map_active?(map_id)
      # Map is active map.
      $game_map.events[new_ev.event.id] = new_ev
      @newest_event = $game_map.events[new_ev.event.id]
      $game_map.refresh if $scene.is_a?(Scene_Map)
      $new_events = true
    elsif map_virtual?(map_id)
      # Map is virtual map.
      $v_maps.maps[map_id].events[new_ev.event.id] = new_ev
      $v_maps.maps[map_id].refresh if $scene.is_a?(Scene_Map)
      @newest_event = $game_map.events[new_ev.event.id]
      $new_events = true
    end
  end
  
  # Fully dependant
  def clear_self(event_id)
    ev = $game_map.events[event_id] if map_active?(@map_id)
    ev = $v_maps.maps[@map_id].events[event_id] if map_virtual?(@map_id)
    p "Critical error, event not found." if $enable_console and ev.nil?
    p "Missing id: #{event_id}" if $enable_console and ev.nil?
    return if ev.nil?
    #p "Error, cannot destroy map specific event.  Only new or boss." if $enable_console and !(ev.boss? or ev.new?)
    #return unless (ev.boss? or ev.new?)
    clear_self_switches(@map_id, ev.event.id)
    $removed_events.push ev.__id__
    if map_active?(@map_id)
      p "Error, cannot remove event.  Bad id." if $enable_console and !$game_map.events.include?(event_id)
      $game_map.events[event_id].remove_event = true
    else
      $v_maps[@map_id].events[event_id].remove_event = true unless $v_maps[@map_id].events.keys.include?(event_id)
    end
  end

  # Clears all extra events from map.
  def clear_extra_events(map_id)
    #todo: include fork to clear when a map is left
    if map_active?(map_id)
      for ev in $game_map.events.values
        if ev.event.id > 999
          $map_extra_events[map_id].clear
          $removed_events.push ev.__id__
          $game_map.events.delete(ev.event.id)
          clear_self_switches(map_id, ev.event.id)
        end
      end
      $game_map.refresh
      $game_map.update
      return
    else
      for ev in $v_maps.maps[map_id].events.values
        if ev.event.id > 999
          $map_extra_events[map_id].clear
          $v_maps.maps[map_id].events.delete(ev.event.id)
          clear_self_switches(map_id, ev.event.id)
        end
      end
      $new_events = true
      return if $v_maps.maps[map_id].no_change
      $v_maps.maps[map_id].refresh
      $v_maps.maps[map_id].update
      return
    end
  end

  def clear_all_named_events(name)
    if map_active?(map_id)
      for ev in $game_map.events.values
        if ev.event.id > 999
          next unless ev.name == name
          $map_extra_events[map_id][ev.event.id] = nil
          $game_map.events.delete(ev.event.id)
          clear_self_switches(map_id, ev.event.id)
        end
      end
      $new_events = true
      $game_map.refresh
      $game_map.update
      return
    else
      for ev in $v_maps.maps[map_id].events.values
        if ev.event.id > 999
          next unless ev.name == name
          $map_extra_events[map_id][ev.event.id] = nil
          $v_maps.maps[map_id].events.delete(ev.event.id)
          clear_self_switches(map_id, ev.event.id)
        end
      end
      $new_events = true
      return if $v_maps.maps[map_id].no_change
      $v_maps.maps[map_id].refresh
      $v_maps.maps[map_id].update
      return
    end  
  end
  
  # ------------------------------- #
  # IMPORTANT Convenience functions #
  # ------------------------------- #
  def map_active?(map_id)
    return $game_map.map_id == map_id
  end
  def map_virtual?(map_id)
    return false if $v_maps.nil?
    return false if $v_maps.maps.nil?
    return false if $v_maps.maps.empty?
    return $v_maps.maps.keys.include?(map_id)
  end
  def find_event_for_xny(x,y,map)
    result = []
    for ev in map.events.values
      result.push(ev) if ev.pos?(x, y)
    end
    return result
  end
  def find_event_xy(x,y,map_id)
    if map_active?(map_id)
      return $game_map.events_xy(x,y)
    else
      return $v_maps.maps[map_id].events_xy(x,y)
    end
  end
  # Checks the placeholder map for the event. #
  def find_event_name(name,map)
    for ev in map.events.values
      if ev.name == name
        return ev
      end
    end
    p "Attempted event name not found in map." if $enable_console
  end
  def at_capacity?(map_id)
    return false if $map_extra_events[map_id].nil?
    p "Event capacity reached." if $map_extra_events[map_id].keys.size > EVENT_CONFIG::EVENT_CAPACITY and $enable_console
    return true if $map_extra_events[map_id].keys.size > EVENT_CONFIG::EVENT_CAPACITY
    return false
  end

  def set_death_switch(map_id, event_id)
    key = [map_id, event_id, "A"]
    $game_self_switches[key] = true# unless $game_self_switches[key].nil?
    $game_map.need_refresh = true
  end

  def clear_self_switches(map_id, event_id)
    key = [map_id, event_id, "A"]
    $game_self_switches[key] = false unless $game_self_switches[key].nil?
    key = [map_id, event_id, "B"]
    $game_self_switches[key] = false unless $game_self_switches[key].nil?
    key = [map_id, event_id, "C"]
    $game_self_switches[key] = false unless $game_self_switches[key].nil?
    key = [map_id, event_id, "D"]
    $game_self_switches[key] = false unless $game_self_switches[key].nil?
    $game_map.need_refresh
  end
  
end