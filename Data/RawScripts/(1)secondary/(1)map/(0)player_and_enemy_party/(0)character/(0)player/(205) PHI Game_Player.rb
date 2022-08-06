#==============================================================================
# ** Game_Player
#------------------------------------------------------------------------------
#  This class handles maps. It includes event starting determinants and map
# scrolling functions. The instance of this class is referenced by $game_map.
#==============================================================================

class Game_Player < Game_Character
  #--------------------------------------------------------------------------
  # * Constants
  #--------------------------------------------------------------------------
  CENTER_X = ($screen_width / 2 - 16) * 8     # Screen center X coordinate * 8
  CENTER_Y = ($screen_height / 2 - 16) * 8     # Screen center Y coordinate * 8
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_reader   :vehicle_type       # type of vehicle currenting being ridden
  attr_accessor :actor_id           # player's actor id
  attr_accessor :active_member      # flag for player's control
  attr_accessor :transferring       # flag for transferring or not
  attr_accessor :x                  # direct manipulation of x
  attr_accessor :y                  # direct manipulation of y
  attr_accessor :direction          # direct manipulation of direction
  attr_accessor :ai_config          # external configuration for map ai
  attr_accessor :ai_stored          # external configuration id stored for map ai
  attr_accessor :force_action
  attr_accessor :moved
  attr_accessor :in_line
  attr_accessor :locked
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  alias old_initialization_paste initialize if self.methods.include?('initialize')
  def initialize
    self.methods.include?('old_initialization_paste') ? old_initialization_paste : super

    @transferring = false           # Player transfer flag
    @new_map_id = 0                 # Destination map ID
    @new_x = 0                      # Destination X coordinate
    @new_y = 0                      # Destination Y coordinate
    @new_direction = 0              # Post-movement direction
    @walking_bgm = nil              # For walking BGM memory
    
    @battle_bgm = nil               # Battle BGM
    @next_x = 0                     # Next X
    @next_y = 0                     # Next Y
    @actor_id = -1                  # Actor id attached to this player.
    
    @in_line = true                 # Player is in the unit caterpillar line
    @unit = 0                       # Unit number
    @moved = false

    @locked = false                 # Unit movement locked
    
    @current_action = nil           # Action object
    @force_action = nil             # Forced action object
    @action_target = nil            # The target for an action.
  end
  
  #--------------------------------------------------------------------------
  # * Determine if Stopping
  #--------------------------------------------------------------------------
  def stopping?
    return false if @vehicle_getting_on
    return false if @vehicle_getting_off
    return super
  end
  
  def set_player(actor_id)
    @actor_id = actor_id
    refresh
  end
  #--------------------------------------------------------------------------
  # * Determine Character Collision
  #     x : x-coordinate
  #     y : y-coordinate
  #    Detects normal (0)character collision, including the player and vehicles.
  #--------------------------------------------------------------------------
  def collide_with_characters?(x, y)
    unless $game_temp.in_battle
      for event in $game_map.events_xy(x, y)            # Matches event position
        unless event.through                                   # Passage OFF?
          return true if self.is_a?(Game_Event)             # Self is event
          return true if event.priority_type == 1           # Target is normal char
        end
      end
    end
    if @priority_type == 1 && !$game_temp.in_battle          # Self is normal char
      return false if $game_player.pos_nt?(x, y)                # Matches player position
      return true if $game_map.boat.pos_nt?(x, y)               # Matches boat position
      return true if $game_map.ship.pos_nt?(x, y)               # Matches ship position
    end
    return false
  end

  #--------------------------------------------------------------------------
  # * Determine if Passable
  #     x : x-coordinate
  #     y : y-coordinate
  #--------------------------------------------------------------------------
  def passable?(x, y)
    x = $game_map.round_x(x)                        # Horizontal loop adj.
    y = $game_map.round_y(y)                        # Vertical loop adj.
    #return false if $game_temp.in_battle && !in_battle_grid_range?(x,y)
    return false unless $game_map.valid?(x, y)      # Outside map?
    return true if @through or debug_through?       # Through ON?
    return false unless map_passable?(x, y)         # Map Impassable?
    return false if collide_with_characters?(x, y)  # Collide with (0)character?
    return true                                     # Passable
  end

  def in_battle_grid_range?(x,y)
    if self != $game_party.leader
      return $game_party.leader.battle_range.inside?(x, y)
    else
      cloned_range = @battle_range.clone
      cloned_range.move(x,y)
      $game_party.get_active_alive_players.each do |pl|
        next if pl == self
        unless cloned_range.inside?(pl.x, pl.y)
          return false
        end
      end
      return true
    end
  end
  #--------------------------------------------------------------------------
  # * Player Transfer Reservation
  #     map_id    : Map ID
  #     x         : x-coordinate
  #     y         : y coordinate
  #     direction : post-movement direction
  #--------------------------------------------------------------------------
  def reserve_transfer(map_id, x, y, direction)
    return if $game_temp.in_battle # Forbids map transfer when in battle.
    @transferring = true
    @new_map_id = map_id
    @new_x = x
    @new_y = y
    @new_direction = direction
  end
  #--------------------------------------------------------------------------
  # * Determine if Player Transfer is Reserved
  #--------------------------------------------------------------------------
  def transfer?
    return @transferring
  end
  #--------------------------------------------------------------------------
  # * Execute Player Transfer
  #--------------------------------------------------------------------------
  def perform_transfer
    return unless @transferring && leader?
    @transferring = false
    set_direction(@new_direction)
    if $game_map.map_id != @new_map_id
      $game_map.setup(@new_map_id)     # Move to other map
    end
    $game_party.transfer_players
    moveto(@new_x, @new_y)
  end
  #--------------------------------------------------------------------------
  # * Determine if Map is Passable
  #     x : x-coordinate
  #     y : y-coordinate
  #--------------------------------------------------------------------------
  def map_passable?(x, y)
    return $game_map.passable?(x, y)
  end
  #--------------------------------------------------------------------------
  # * Determine if Walking is Possible
  #     x : x-coordinate
  #     y : y-coordinate
  #--------------------------------------------------------------------------
  def can_walk?(x, y)
    result = passable?(x, y)            # Determine if passable
    return result
  end
  #--------------------------------------------------------------------------
  # * Determine if Dashing
  #--------------------------------------------------------------------------
  def dash?
    return false if @move_route_forcing
    return false if $game_map.disable_dash?
    return Input.press?(PadConfig.dash)
  end
  #--------------------------------------------------------------------------
  # * Determine if Debug Pass-through State
  #--------------------------------------------------------------------------
  def debug_through?
    #return false unless @passive
    return Input.press?(Input.CTRL) 
  end
  #--------------------------------------------------------------------------
  # * Set Map Display Position to Center of Screen
  #     x : x-coordinate
  #     y : y-coordinate
  #--------------------------------------------------------------------------
  def center(x, y)
    display_x = x * 256 - CENTER_X                    # Calculate coordinates
    unless $game_map.loop_horizontal?                 # No loop horizontally?
      max_x = ($game_map.width - 20) * 256            # Calculate max value
      display_x = [0, [display_x, max_x].min].max     # Adjust coordinates
    end
    display_y = y * 256 - CENTER_Y                    # Calculate coordinates
    unless $game_map.loop_vertical?                   # No loop vertically?
      max_y = ($game_map.height - 15) * 256           # Calculate max value
      display_y = [0, [display_y, max_y].min].max     # Adjust coordinates
    end
    $game_map.set_display_pos(display_x, display_y)   # Change map location
  end
  #--------------------------------------------------------------------------
  # * Move to Designated Position
  #     x : x-coordinate
  #     y : y-coordinate
  #--------------------------------------------------------------------------
  def moveto(x, y)
    super
    center(x, y) if leader?                       # Centering
  end
  #--------------------------------------------------------------------------
  # * Increase Steps
  #--------------------------------------------------------------------------
  def increase_steps
    super
    return if @move_route_forcing
    $game_party.increase_steps
  end
  #--------------------------------------------------------------------------
  # * Get Encounter Count
  #--------------------------------------------------------------------------
  def encounter_count
  end
  #--------------------------------------------------------------------------
  # * Make Encounter Count
  #--------------------------------------------------------------------------
  def make_encounter_count
  end
  #--------------------------------------------------------------------------
  # * Determine if in Area
  #     area : Area data ((0X)RPG.rb::Area)
  #--------------------------------------------------------------------------
  def in_area?(area)
    return false if area == nil
    return false if $game_map.map_id != area.map_id
    return false if @x < area.rect.x
    return false if @y < area.rect.y
    return false if @x >= area.rect.x + area.rect.width
    return false if @y >= area.rect.y + area.rect.height
    return true
  end
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh
    if $game_party.members.size == 0 or member.nil?
      @character_name = ""
      @character_index = 0
    else
      @character_name = member.character_name
      @character_index = member.character_index
      set_special_sprite
      if special?
        reset_o_animation
      end
    end
  end
  
  def get_member
    for member in $game_party.all_members
      return member if member.id == @actor_id
    end
    return nil
  end
  def member
    get_member
  end

  def battler
    return get_member
  end

  def find_member(actor_id)
    for member in $game_party.all_members
      return member if member.id == actor_id
    end
    return nil
  end
  #--------------------------------------------------------------------------
  # * Determine if Same Position Event is Triggered
  #     triggers : Trigger array
  #--------------------------------------------------------------------------
  def check_event_trigger_here(triggers)
    return false unless leader?
    return false if $game_map.interpreter.running?
    result = false
    for event in $game_map.events_xy(@x, @y)
      if triggers.include?(event.trigger) and event.priority_type != 1
        event.start
        result = true if event.starting
      end
    end
    return result
  end
  #--------------------------------------------------------------------------
  # * Determine if Front Event is Triggered
  #     triggers : Trigger array
  #--------------------------------------------------------------------------
  def check_event_trigger_there(triggers)
    return false unless leader?
    return false if $game_map.interpreter.running?
    result = false
    front_x = $game_map.x_with_direction(@x, @direction)
    front_y = $game_map.y_with_direction(@y, @direction)
    for event in $game_map.events_xy(front_x, front_y)
      if triggers.include?(event.trigger) and event.priority_type == 1
        event.start
        result = true
      end
    end
    if result == false and $game_map.counter?(front_x, front_y)
      front_x = $game_map.x_with_direction(front_x, @direction)
      front_y = $game_map.y_with_direction(front_y, @direction)
      for event in $game_map.events_xy(front_x, front_y)
        if triggers.include?(event.trigger) and event.priority_type == 1
          event.start
          result = true
        end
      end
    end
    return result
  end
  #--------------------------------------------------------------------------
  # * Determine if Touch Event is Triggered
  #     x : x-coordinate
  #     y : y-coordinate
  #--------------------------------------------------------------------------
  def check_event_trigger_touch(x, y)
    return false unless leader?
    return false if $game_map.interpreter.running?
    result = false
    for event in $game_map.events_xy(x, y)
      if [1,2].include?(event.trigger) and event.priority_type == 1
        event.start
        result = true
      end
    end
    return result
  end
  
  def ready_to_move?
    return (movable? and !$game_map.interpreter.running?)
  end
  #--------------------------------------------------------------------------
  # * Determine if Movement is Possible
  #--------------------------------------------------------------------------
  def movable?
    return false if $game_temp.in_battle &&  (@locked || !get_member.battle_movement)
    return false if !$game_temp.in_battle && !leader?
    return false if moving?                     # Moving
    return false if @move_route_forcing         # On forced move route
    return false if $game_message.visible       # Displaying a message
    return true
  end
  
  def leader?
    return self == $game_party.get_leader
  end
  #--------------------------------------------------------------------------
  # * Update Scroll
  #--------------------------------------------------------------------------
  def update_scroll(last_real_x, last_real_y)
    ax1 = $game_map.adjust_x(last_real_x)
    ay1 = $game_map.adjust_y(last_real_y)
    ax2 = $game_map.adjust_x(@real_x)
    ay2 = $game_map.adjust_y(@real_y)
    if ay2 > ay1 and ay2 > CENTER_Y
      $game_map.scroll_down(ay2 - ay1)
    end
    if ax2 < ax1 and ax2 < CENTER_X
      $game_map.scroll_left(ax1 - ax2)
    end
    if ax2 > ax1 and ax2 > CENTER_X
      $game_map.scroll_right(ax2 - ax1)
    end
    if ay2 < ay1 and ay2 < CENTER_Y
      $game_map.scroll_up(ay1 - ay2)
    end
  end
  #--------------------------------------------------------------------------
  # * Processing when not moving
  #     last_moving : Was it moving previously?
  #--------------------------------------------------------------------------
  def update_nonmoving(last_moving)
    return if $game_map.interpreter.running?
    return if moving?
    return if check_touch_event if last_moving
    if not $game_message.visible and Input.trigger?(PadConfig.decision)
      return if check_action_event
    end
  end
  #--------------------------------------------------------------------------
  # * Determine Event Start Caused by Touch (overlap)
  #--------------------------------------------------------------------------
  def check_touch_event
    return check_event_trigger_here([1,2])
  end
  #--------------------------------------------------------------------------
  # * Determine Event Start Caused by [OK] Button
  #--------------------------------------------------------------------------
  def check_action_event
    return false if in_airship?
    return true if check_event_trigger_here([0])
    return check_event_trigger_there([0,1,2])
  end
  #--------------------------------------------------------------------------
  # * Force One Step Forward
  #--------------------------------------------------------------------------
  def force_move_forward
    @through = true         # Passage ON
    move_forward            # Move one step forward
    @through = false        # Passage OFF
  end
  
  #--------------------------------------------------------------------------
  # * Get Screen Z-Coordinates
  #--------------------------------------------------------------------------
  def screen_z
    return 100
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: move_by_input
  #--------------------------------------------------------------------------
  def move_by_input
    return unless movable?
    return if $game_map.interpreter.running?
    @tap_counter = YEM::MOVEMENT::TAP_COUNTER if @tap_counter == nil
    @idle_frames = 0 if @idle_frames == nil
    if Input.dir8 != 0
      break_pose
      @tap_counter -= 1
      @direction = Input.dir8
      @idle_frames = 0
      return if @tap_counter > 0
    else
      @idle_frames += 1
      @tap_counter = YEM::MOVEMENT::TAP_COUNTER
    end
    if @idle_frames > YEM::MOVEMENT::IDLE_FRAMES and (@pose == nil or @pose == "")
      @pose = YEM::MOVEMENT::IDLE_POSE[rand(YEM::MOVEMENT::IDLE_POSE.size + 1)]
    end
    case Input.dir8
    when 2
      move_down
      did_move(1)
    when 4
      move_left
      did_move(2)
    when 6
      move_right
      did_move(3)
    when 8
      move_up
      did_move(4)
    when 1
      if !dir8_passable?(1) and dir8_passable?(4)
        move_left
        did_move(2)
      elsif !dir8_passable?(1) and dir8_passable?(2)
        move_down
        did_move(1)
      elsif dir8_passable?(4) and dir8_passable?(1) or
          dir8_passable?(2) and dir8_passable?(1)
        move_lower_left
        @direction = Input.dir8
        did_move(5)
      end
    when 3
      if !dir8_passable?(3) and dir8_passable?(6)
        move_right
        did_move(3)
      elsif !dir8_passable?(3) and dir8_passable?(2)
        move_down
        did_move(1)
      elsif dir8_passable?(2) and dir8_passable?(3) or
          dir8_passable?(6) and dir8_passable?(3)
        move_lower_right
        @direction = Input.dir8
        did_move(6)
      end
    when 7
      if !dir8_passable?(7) and dir8_passable?(4)
        move_left
        did_move(2)
      elsif !dir8_passable?(7) and dir8_passable?(8)
        move_up
        did_move(4)
      elsif dir8_passable?(8) and dir8_passable?(7) or
          dir8_passable?(4) and dir8_passable?(7)
        move_upper_left
        @direction = Input.dir8
        did_move(7)
      end
    when 9
      if !dir8_passable?(9) and dir8_passable?(6)
        move_right
        did_move(3)
      elsif !dir8_passable?(9) and dir8_passable?(8)
        move_up
        did_move(4)
      elsif dir8_passable?(8) and dir8_passable?(9) or
          dir8_passable?(6) and dir8_passable?(9)
        move_upper_right
        @direction = Input.dir8
        did_move(8)
      end
    end
  end
  # -------------------------------------------------------------------------- #
  # adjusted input get dir8
  def get_dir8(input)
    case input
    when 5
      return 1
    when 6
      return 3
    when 7
      return 7
    when 8
      return 9
    else
      return input
    end
  end
  
end
