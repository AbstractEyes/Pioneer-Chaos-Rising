module PHI
  
  # Battler traits
  SAFE_DISTANCE = 5 # 10 tiles safe distance
  
  DIR8_DIRECTIONS = [[-1,-1],[1,-1],[-1,1],[1,1],[0,-1],[0,1],[-1,0],[1,0]]
end

class Game_Player < Game_Character

  alias flag_initialize_actions initialize
  def initialize
    flag_initialize_actions
    clear_actions
  end
  
#~   # -------------------------------------------------------------------------- #
#~   # action is being performed
#~   def performing_action?
#~     return false if @active_action.nil?
#~     return !@active_action.not_running?
#~   end
  
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  def update
    last_real_x = @real_x
    last_real_y = @real_y
    last_moving = moving?
    move_by_input
    super
    update_auto_actions #unless any_action?
    update_actions
    #update_sight if @attack_grid
    update_scroll(last_real_x, last_real_y) if leader?
    update_nonmoving(last_moving)
  end

  def member_moving?
    if self.is_a?(Game_Player)
      return self.get_member.battle_movement
    elsif self.is_a?(Game_Character)
      return !self.member.nil? && self.member.battle_movement
    end
  end
  # -------------------------------------------------------------------------- #
  # update the player's sight
  #def update_sight
  #  @attack_range.move(@x,@y,@direction)
  #end
  
  # -------------------------------------------------------------------------- #
  # did move from old position using input
  def did_move(direction)
    @moved = true if moving? and leader?
    @trail.push(direction) unless @move_failed
    if @trail.size - 1 > $game_party.players.size
      @trail.shift
    end
  end
  
  # -------------------------------------------------------------------------- #
  # updates by frame, the action sequence
  def update_actions
    @action_wait = 0 if @action_wait.nil?
    # Waiting another frame for the action wait timer.
    if @action_wait > 0
      @action_wait -= 1
      return
    end
    if done_moving_to_target_location?
      set_action
      return
    else
      # If the action has already cycled, and persists,
      if any_action? and action_active?
        if @active_action.done? and !@actions.empty?
          set_action
          return
        else
          clear_action
          return
        end
      # Else get new action.
      else
        set_action
        return
      end
    end
  end
  
  def set_action
    clear_action
    get_action
    begin_action
  end

  def done_moving_to_target_location?
    return false if @active_action.nil?
    return false unless @moved_to
    if in_range?(@active_action.params.target)
      return true
    end
    return false
  end
  # -------------------------------------------------------------------------- #
  # gets an action based on the possible actions
  def get_action
    # Action is being forced.
    if !@force_action.nil?
      @active_action = @force_action
      @force_action = nil
    # Actions in the priority queue.
    elsif !@actions.empty?
      @active_action = @actions.next
    end
  end
  
  # -------------------------------------------------------------------------- #
  # check if an action exists.
  def no_action
    return true if @actions.empty? and @active_action.nil? and @force_action.nil?
    return false
  end
  
  def action_active?
    !@active_action.nil?
  end
  
  def performing_action?
    return false #running_action
  end

  # -------------------------------------------------------------------------- #
  # clears all actions
  def clear_actions
    @actions = Priority_Queue.new
    @current_action = nil
    @active_action = nil
    @force_action = nil
    clear_flags
  end
    
  # -------------------------------------------------------------------------- #
  # clears current action
  def clear_action
    @active_action = nil
    clear_flags
  end
  
  # -------------------------------------------------------------------------- #
  # clears all appropriate flags of use
  def clear_flags
    @evading = false
    @force_moving = false
    @moving = false
    @moved_to = false
    @attacking = false
    @interacting = false
    @gather_spot = false
    @action_wait = 0
  end
  
  def any_action?
    return (@evading or @force_moving or @moving or
            @moved_to or @attacking or @interacting or
            @gather_spot or moving?)
  end
  
  def action_moving?
    return (@moved_to or @moving or @force_moving)
  end
  
  # -------------------------------------------------------------------------- #
  # begins action sequence after an active action is determined
  def begin_action
    return if @active_action.nil?
    @active_action.start
    case @active_action.option
      when :move_direction
        action_movedirection
      when :moveto
        action_moveto
      when :move_random
        action_moverandom
      when :spot
        action_spot
      when :destroy
        action_destroy
      when :create
        action_create
      when :use_item
        action_useitem
      when :battle_command
        action_battlecommand
      when :gather
        action_gather_resource
      else

    end
  end
  
  # -------------------------------------------------------------------------- #
  # action determined movedirection
  def action_movedirection
    #(0X)todo write action
    return if @moving
    @moving = true
    case @active_action.params.direction
    when 1    # Move Down
      move_down
    when 2    # Move Left
      move_left
    when 3    # Move Right
      move_right
    when 4    # Move Up
      move_up
    when 5    # Move Lower Left
      move_lower_left
    when 6    # Move Lower Right
      move_lower_right
    when 7    # Move Upper Left
      move_upper_left
    when 8    # Move Upper Right
      move_upper_right
    end
  end
  
  def action_moveto
    return if @active_action.params.target.nil?
    p "#{$game_actors[self.actor_id].name} Moving to."
    params = @active_action.params
    event, tx, ty = params.target, params.x, params.y
    tile = find_nearby_tile(tx,ty)
    @moved_to = true
    return if in_range?(@active_action.params.target)
    self.force_path(tile[0],tile[1])
  end
  
  def in_range?(event)
    PHI::DIR8_DIRECTIONS.each do |d|
      xd = event.x + d[0]
      yd = event.y + d[1]
      p "#{$game_actors[self.actor_id].name} in range" if self.x == xd and self.y == yd
      return true if self.x == xd and self.y == yd
    end
    return false
  end
  
  def find_nearby_tile(x,y)
    PHI::DIR8_DIRECTIONS.each do |d|
      xd = x + d[0]
      yd = y + d[1]
      if self.passable?(xd,yd)
        return [xd,yd]
      end
    end
    return nil
  end
  
  def action_moverandom
    move_random
  end
  
  def action_spot
    #(0X)todo write action
  end
  
  def action_destroy
    #(0X)todo write action
    params = @active_action.params
    skey = [$game_map.map_id, @active_action.target.event.id, "A"]
    $game_self_switches[skey] = true
    @active_action = nil
    @moved_to = false
    @action_wait += 60
  end
  
  def action_create
    #(0X)todo write action
  end
  
  def action_evadebattle
    tile_hash = {}
    params = @active_action.params
    dx = (self.x - params.x).abs    # difference of x
    dy = (self.y - params.y).abs    # difference of y
    for x in dx...dx+PHI::SAFE_DISTANCE
      for y in dy...dy+PHI::SAFE_DISTANCE
        next unless ($game_map.passable?(x,y) and self.passable?(x,y))
        tile_hash[[x,y]] = ($game_map.passable?(x,y) and self.passable?(x,y))
      end
    end
    # Travel and evade in a random direction.
    k = tile_hash.keys[rand(tile_hash.size)]
    self.force_path(k[0],k[1])
    @evading = true
    @active_action.finished = true
    @action_wait += 60
  end
  
  def action_gather_resource
    @gather_spot = true
    event = @active_action.params.target
    items = event.itemids
    if items.empty?
      $game_self_switches[[event.map_id, event.event.id, "A"]] = true
      @gather_spot = false
      @moved_to = false
      @active_action.finished = true
      return
    end
    if $scene.is_a?(Scene_Map)
      item = $data_items[items[0][0]]
      s = ("#{item.name} gathered by #{$game_actors[self.actor_id].name}.")
      $scene.add_scroller(s)
      self.added_item = item
    end
    items[0][1] -= 1
    $game_party.gain_item(item,1)
    if items[0][1] <= 0
      items[0] = nil
      items.compact!
    end
    @action_wait += 60
    $game_map.events[event.id].itemids = items
    Sound.play_equip
  end
  
  def action_useitem
    #(0X)todo write action
  end
  
  def action_battlecommand
    #(0X)todo write action
  end
  
end