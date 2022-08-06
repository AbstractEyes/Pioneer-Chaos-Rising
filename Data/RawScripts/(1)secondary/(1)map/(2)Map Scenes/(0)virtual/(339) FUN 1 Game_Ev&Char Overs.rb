# ----------------------------- #
# Event Overwrites (incomplete) #
# ------------------------------------------------ #
# These overwrites do not impact main event usage. #
#   These are for TAG inclusion via comment.       #
#     If the tags are present, runs the loop to    #
#     create the external tag structure for the    #
#     main algorithm to read the type and tags of  #
#     each created event on the "EVENT" level.     #
# ------------------------------------------------ #
module RPG
  class Event
    @ident = ""
    @tags = []
    @battler_id = 0
    @party_name = ''
    @disposed_manually = false
    attr_accessor :ident
    attr_accessor :tags
    attr_accessor :battler_id
    attr_accessor :party_name
    attr_accessor :disposed_manually
  end
end
# ------------------ #
# Game Character Mod #
# -------------------------------------------------------------------------- #
# This is a semi simple rehaul of the original.  
# 
# ALL changes only apply to when inside the designated virtual maps.
# 
# Place BELOW any overwrites to Game_Character that conflict.
#  Alias:
#    initialize
#    passable?
#    map_passable?
#    move_up
#    move_down
#    move_left
#    move_right
#    collide_with_characters?
#
# -------------------------------------------------------------------------- #
class Game_Character
  attr_accessor :x
  attr_accessor :y
  attr_accessor :new_x
  attr_accessor :new_y
  attr_accessor :move_speed
  attr_accessor :move_frequency
  attr_accessor :map_id
  
  alias initialize_old initialize
  def initialize(map_id = nil)
    initialize_old
    @map_id = map_id
    @new_x = x
    @new_y = y
    @monster = false
  end
  #--------------------------------------------------------------------------
  # * OVERWRITES Passable?
  #     x : x-coordinate
  #     y : y-coordinate
  #--------------------------------------------------------------------------
  alias old_passable? passable?
  def passable?(x, y)
    return old_passable?(x, y) unless inside_vmap?
    x = $v_maps.maps[@map_id].round_x(x)                        # Horizontal loop adj.
    y = $v_maps.maps[@map_id].round_y(y)                        # Vertical loop adj.
    return false unless $v_maps.maps[@map_id].valid?(x, y)      # Outside map?
    return true if @through or debug_through?       # Through ON?
    return true if passable_tag_check?(x, y) and self.is_a?(Game_Event)
    return false unless map_passable?(x, y)         # Map Impassable?
    return false if collide_with_characters?(x, y)  # Collide with (0)character?
    return true                                     # Passable
  end
  #--------------------------------------------------------------------------
  # * Determine if Map is Passable
  #     x : x-coordinate
  #     y : y-coordinate
  #    Gets whether the tile at the designated coordinates is passable.
  #--------------------------------------------------------------------------
  alias old_map_passable? map_passable?
  def map_passable?(x, y)
    return old_map_passable?(x, y) unless inside_vmap?
    return $v_maps.maps[@map_id].passable?(x, y)
  end
  #--------------------------------------------------------------------------
  # * Determine Character Collision
  #     x : x-coordinate
  #     y : y-coordinate
  #    Detects normal (0)character collision, including the player and vehicles.
  #--------------------------------------------------------------------------
  alias old_collide_with_characters? collide_with_characters?
  def collide_with_characters?(x, y, map_id = @map_id)
    return old_collide_with_characters?(x, y) unless inside_vmap?
    for event in $v_maps.maps[map_id].events_xy(x, y)          # Matches event position
      unless event.through                          # Passage OFF?
        return true if self.is_a?(Game_Event)       # Self is event
        return true if event.priority_type == 1     # Target is normal char
      end
    end
    return false
  end

  def passable_tag_check?(x,y)
    for event in $game_map.events_xy(x, y)
      p "Passable tag method not working" if $enable_console and event.passable_tag.nil?
      next if event.passable_tag.nil?
      return true if event.passable_tag
    end
    return false
  end


  def inside_vmap?
    return false if @map_id.nil?
    return false if $game_map.map_id == @map_id
    return false if !$v_maps.exists?(@map_id)
    return true if $v_maps._all.has_key?(@map_id)
  end
  
end
# ---------------- #
# Game Event ALIAS #
# -------------------------------------------------------- #
# This is a set of tag elements I included to allow use    #
# of more features with your events.                       #
# -------------------------------------------------------- #
class Game_Event < Game_Character
  attr_reader :boss_params
  attr_reader :event_tag
  attr_reader :tags
  attr_accessor :remove_event
  attr_accessor :event
  attr_accessor :id
  attr_accessor :new_event
  attr_accessor :boss_event
  attr_accessor :map_id
  attr_accessor :interpreter
  attr_accessor :passable_tag
  attr_accessor :touchable
  attr_accessor :sight_visible
  attr_accessor :battler_id
  attr_accessor :itemids
  attr_reader :automatic_replacement
  attr_accessor :resource_host
  #--------------------------------------------------------------------------
  # * Event page setup
  #--------------------------------------------------------------------------
  alias setup_stuff setup
  def setup(new_page)
    @remove_event = false
    @new_event = false
    @boss_event = false
#~     @new_event = true if @id > 999
#~     @boss_event = true if @id > 4999
    @passable_tag = false
    @touchable = false
    @sight_visible = false
    @automatic_replacement = ''
    @resource_host = -1
#~     @sight_visible = true if @priority_type > 0
    setup_stuff(new_page)
    if @page != nil
      @tags = tag
      @itemids = get_items
      passable_tag_setup
      battler_tag_setup
      automatic_event_setup
    end
  end

  def reset_self_switches
    $game_map.ev_handler.clear_self_switches(@map_id, @id)
  end
  
  def passable_tag_setup
    if !@list.nil?
      for i in 0...@list.size
        next if @list[i].code != 108
        if @list[i].parameters[0].include?("PASSABLE")
          @passable_tag = true
        elsif @list[i].parameters[0].include?("TOUCHABLE")
          @touchable = true
        elsif @list[i].parameters[0].include?("INVISIBLE")
          @sight_visible = false
        end
      end
    end
  end
  
  def battler_tag_setup
    if !@list.nil?
      for i in 0...@list.size
        next if @list[i].nil?
        next if @list[i].code != 108
        if @list[i].parameters[0].include?("monsterid")
          @battler_id = @list[i].parameters[0].scan(/\d+/)[0].to_i
          @monster = true
        elsif @list[i].parameters[0].include?("monsterstring")
          @battler_id = @list[i].parameters[0].split[1][0...@list[i].parameters[0].split[1].size - 1]
          @monster = true
        else
          @monster = false
          @battler_id = 0 if @battler_id.nil?
          @actor_id = 0 if @actor_id.nil?
        end
      end
    end
  end

  def automatic_event_setup
    for i in 0...@list.size
      next if @list[i].nil?
      next if @list[i].code != 108
      if @list[i].parameters[0].include?('new')
        @automatic_replacement = @list[i].parameters[0][6...(@list[i].parameters[0].size - 2)]
        p 'replacement event ' + @automatic_replacement.to_s
      end
    end
  end
  
  # Returns the converted array using gsub and split,
  #  Used for parameters only.
  def convert_param_data(key = nil,raw_data = '')
    return if key.nil? or raw_data == ''
    starting_data = raw_data.gsub(/#{key}/){}
    data_array = starting_data.split(' ')
    return data_array
  end
  
  # This will set up the event tag for active use
  def tag
    output_list = {}
    if !@list.nil?
      for i in 0...@list.size
        next if @list[i].code != 108
        event_keys = EVENT_TAGS::EVENT_IDENTS
        for category in event_keys.keys
          if @list[i].parameters[0].include?(category)
            for x in 0...event_keys[category].size
              if @list[i].parameters[0].include?(event_keys[category][x])
                return [category,event_keys[category][x]]
              end
            end
          end
        end
      end
    end
    return ['None','']
  end
  
  def get_items
    output = []
    if !@list.nil?
      for i in 0...@list.size
        next if @list[i].code != 108
        row = @list[i].parameters[0]
        if row.include?("itemid")
          row[0] = ''
          row[row.size-1] = ''
          output.push [row.split(' ')[1].to_i, row.split(' ')[2].to_i]
        end
      end
    end
    return output
  end
  
  def monster?
    return @monster
  end

  def boss?
    return @boss_event
  end
  def new?
    return @new_event
  end
end