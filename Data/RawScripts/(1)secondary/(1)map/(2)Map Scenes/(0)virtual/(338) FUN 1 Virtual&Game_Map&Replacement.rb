# ------------------------------------- #
# ** Game_Map / Virtual Map Replacement #
#-----------------------------------------------------------------------------#
#  This is the replacement for the virtual map.
#  This is a self encapsulating class, that only updates certain things
#  if the map is a virtual map.  Many of these are overwritten methods,
#  so this isn't exactly an easy integration.
#  
#  Alias Methods:
#  alias refresh
#  alias update
#  alias update_events
#  alias initialize(active bool)
#  alias setup(map_id,active)
#  alias setup_events(map_id)
#  alias setup_events
#  alias events_xy(x,y)
#
#==============================================================================
class Game_Map
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_accessor :events                   # events
  attr_accessor :need_refresh
  attr_accessor :halt
  attr_accessor :map_active
  attr_accessor :interpreter
  attr_reader   :ev_handler
  alias old_initialize initialize
  alias old_setup setup
  alias old_events_xy events_xy
  alias old_refresh refresh
  alias old_update update
  alias old_update_events update_events
  #--------------------------------------------------------------------------
  # * Alias Object Initialization
  #--------------------------------------------------------------------------
  def initialize(active = true)
    @map_active = active
    @halt = false
    old_initialize
  end
  #--------------------------------------------------------------------------
  # *ALIAS map Setup
  #     map_id : map ID
  #--------------------------------------------------------------------------
  def setup(map_id)
    @ev_handler = Fun_Event_Handler.new(map_id)
    old_setup(map_id) if @map_active
    new_setup(map_id) unless @map_active
  end
  def new_setup(map_id)
    @map_id = map_id
    @map = load_data(sprintf("Data/Map%03d.rvdata", @map_id))
    @display_x = 0
    @display_y = 0
    @passages = $data_system.passages
    setup_events
    @need_refresh = false
  end
  #--------------------------------------------------------------------------
  # * ALIAS Event Setup
  #--------------------------------------------------------------------------
  def setup_events
    @events = {}          # Map event
    for i in @map.events.keys
      @events[i] = Game_Event.new(@map_id, @map.events[i])
      ev = @events[i]
      next if ev.nil? or is_map_extra?(ev.event.id)
      if ev.automatic_replacement != ''
        temp = @ev_handler.snag_ev(ev.automatic_replacement)
        #temp.event = ev.event.clone
        temp.event.id = ev.event.id
        temp.id = i
        temp.moveto(ev.x, ev.y)
        temp.event.x = ev.event.x
        temp.event.y = ev.event.y
        temp.map_id = @map_id
        #temp.event.pages = ev.event.pages.clone
        @events[i] = temp
      end
    end
    if @map_active
      @common_events = {}   # Common event
      for i in 1...$data_common_events.size
        @common_events[i] = Game_CommonEvent.new(i)
      end
    end
    $map_extra_events = {} if $map_extra_events.nil?
    $map_extra_events[@map_id] = {} unless $map_extra_events[@map_id].is_a?(Hash)
    for key in $map_extra_events[@map_id].keys
      next if $map_extra_events[@map_id][key].nil?
      ev = $map_extra_events[@map_id][key].event
      p "New Event: #{ev.id}" if $enable_console
      @events[ev.id] = Game_Event.new(@map_id, ev)
      saved_event = $map_extra_events[@map_id][key]
      @events[ev.id].moveto(saved_event.new_x,saved_event.new_y)
    end

  end

  def replacement_event_count
    out = 0
    for key in @events.keys
      ev = @events[key]
      next if ev.nil? or is_map_extra?(ev.event.id)
      if ev.automatic_replacement != ''
        out += 1
      end
    end
    return out
  end

  def is_map_extra?(id)
    return false if $map_extra_events.nil?
    return false unless $map_extra_events.keys.include?(@map_id)
    return false unless $map_extra_events[@map_id].is_a?(Hash)
    $map_extra_events[@map_id].each_value do |ev|
      return true if ev.event.id == id
    end
    # p 'is not map extra'
    return false
  end

  def create_item(x, y, item)
    @ev_handler.create_ev(x, y, @map_id, 'name', 'item', item)
  end

#-----------------------------------------------------------------------------------
#~   def setup_new_events
#~     p "Maps: ",$map_extra_events.keys
#~     return if $map_extra_events.nil?
#~     return if $map_extra_events[@map_id].nil?
#~     $map_extra_events[@map_id] = {} if $map_extra_events[@map_id].is_a?(Array)
#~     return unless $map_extra_events[@map_id].keys.size > 0
#~     if @map_active
#~       return if $game_map.events.keys.size + $map_extra_events[@map_id].keys.size == $game_map.events.keys.size
#~     end
#~     p "@map_id: ",@map_id
#~     p "$map_extra_events[@map_id]: ",$map_extra_events[@map_id]
#~     for key in $map_extra_events[@map_id].keys
#~       next if $map_extra_events[@map_id][key].nil?
#~       ev = $map_extra_events[@map_id][key].event
#~       p "New Event: #{ev.id}" if $enable_console
#~       @events[ev.id] = Game_Event.new(@map_id, ev)
#~       saved_event = $map_extra_events[@map_id][key]
#~       @events[ev.id].moveto(saved_event.new_x,saved_event.new_y)
#~     end
#~     $boss_events = {} if $boss_events.nil?
#~     return if $boss_events[@map_id].nil?
#~     return if $boss_events[@map_id].empty?
#~     for key in $boss_events[@map_id].keys
#~       ev = $boss_events[@map_id][key].event
#~       @events[i+5000] = Game_Event.new(@map_id, ev)
#~       saved_event = $boss_events[@map_id][key]
#~       @events[i+5000].moveto(saved_event.new_x,saved_event.new_y)
#~     end
#~   end
  #--------------------------------------------------------------------------
  # * ALIAS Get array of event at designated coordinates
  #     x : x-coordinate
  #     y : y-coordinate
  #--------------------------------------------------------------------------
  def events_xyc(xy)
    return events_xy(xy.x,xy.y)
  end
  def events_xy(x, y)
    return old_events_xy(x, y) if @map_active
    return new_events_xy(x, y)
  end
  def new_events_xy(x, y)
    result = []
    for event in $v_maps.map(@map_id).events.values
      result.push(event) if event.pos?(x, y)
    end
    return result
  end
  def monsters_xy(x, y)
    result = []
    if @map_active
      for event in $game_map.events.values
        result.push event if event.x == x and event.y == y and event.is_monster?
      end
    else
      for event in $v_maps.map(@map_id).events.values
        result.push event if event.pos?(x, y) and event.is_monster?
      end
    end
    return result
  end
  # ------------------------ #
  # Find event by event name #
  # ------------------------------------------------------------------ #
  # Used to find unique events on the current map this is called from. #
  #   name : string                                                    #
  # ------------------------------------------------------------------ #
  def find_by_name(name)
    p name.inspect if $enable_console
    evs = $game_map.events.values if @map_active
    evs = $v_maps.map(@map_id).events.values unless @map_active
    for ev in evs
      return ev if ev.event.name == name
    end
  end
  #--------------------------------------------------------------------------
  # * ALIAS Refresh
  #--------------------------------------------------------------------------
  def refresh(*args)
    old_refresh(*args) if @map_active
    new_refresh(*args) unless @map_active
  end
  def new_refresh
    if @map_id > 0
      for event in @events.values
        event.refresh
      end
    end
    @need_refresh = false
  end
  #--------------------------------------------------------------------------
  # * ALIAS Frame Update
  #--------------------------------------------------------------------------
  def update
    old_update if @map_active
    new_update unless @map_active
  end
  def new_update
    refresh if @need_refresh
    update_events
  end
  #--------------------------------------------------------------------------
  # * ALIAS Update Events
  #--------------------------------------------------------------------------
  def update_events
    old_update_events if @map_active
    new_update_events unless @map_active
  end
  def new_update_events
    for event in @events.values
      event.update
    end
  end
end