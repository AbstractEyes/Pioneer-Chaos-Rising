#==============================================================================
# ** Game_Party
#------------------------------------------------------------------------------
#  This class handles the party. It includes information on amount of gold 
# and items. The instance of this class is referenced by $game_party.
#==============================================================================
class Game_Party < Game_Unit
  #--------------------------------------------------------------------------
  # * Constants
  #--------------------------------------------------------------------------
  MAX_MEMBERS = 15                         # Maximum number of party members
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_reader   :gold                     # amount of gold
  attr_reader   :steps                    # number of steps
  attr_accessor :last_item_id             # for cursor memory: Item
  attr_accessor :last_actor_index         # for cursor memory: Actor
  attr_accessor :last_target_index        # for cursor memory: Target
  attr_accessor :last_actor_id
  attr_accessor :actor_id
  attr_accessor :actor_index
  attr_accessor :units
  attr_accessor :line
  attr_accessor :players
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  alias phi_first_initialize_game_party initialize unless $@
  def initialize(*args, &block)
    phi_first_initialize_game_party(*args, &block)
    @players = {}
    @reserve = {}
    # New variables for new functionality.
    @actor_id = 0
    @actor_index = 0
    @sorted_members = []
  end
  #--------------------------------------------------------------------------
  # * Initial Party Setup
  #--------------------------------------------------------------------------
  def setup_starting_members
    @actors = []
    @sorted_members = []
    for i in 0...15
      @sorted_members[i] = -1
    end
    for i in $data_system.party_members
      @actors.push(i)
      add_player(i)
    end
    set_startup_player
    reform_line
  end
  #--------------------------------------------------------------------------
  # * Get Members
  #--------------------------------------------------------------------------
  def members
    result = []
    for i in 0...5
      next if @sorted_members[i] == -1
      result.push($game_actors[@sorted_members[i]])
    end
    return result
  end

  def all_members
    result = []
    for i in 0...15
      if @sorted_members[i] == -1
        result.push nil
      else
        result.push($game_actors[@sorted_members[i]])
      end
    end
    return result
  end

  def all_members_safe
    result = []
    for i in 0...15
      if @sorted_members[i] > -1
        result.push($game_actors[@sorted_members[i]])
      end
    end
    return result
  end

  def sorted_players
    out = []
    for i in 0...5
      pn = @sorted_members[i]
      next if pn == -1
      out.push @players[pn]
    end
    return out
  end

  def sorted_members
    return @sorted_members
  end

  def sorted_member_battlers
    out = []
    for i in 0...@sorted_members.size
      next if @sorted_members[i] == -1
      out.push all_members_safe[@sorted_members[i]]
    end
    return out
  end

  def get_sorted_member(position)
    if @sorted_members[position] >= 0
      return @sorted_members[position]
    end
    return nil
  end

  def set_new_sorted_member(id)
    set_sorted_member(get_empty_sorted_index, id)
  end

  def set_sorted_member(position, id)
    cur_position = position
    if cur_position < 0
      for i in 0...@sorted_members.size
        cur_position = i if @sorted_members[i] == id
      end
    end
    return if cur_position < 0
    return if cur_position > @sorted_members.size
    if @sorted_members.include?(id)
      index = @sorted_members.index(id)
      old_id = @sorted_members[cur_position]
      @sorted_members[cur_position] = id
      @sorted_members[index] = old_id
    else
      @sorted_members[cur_position] = id
    end
  end

  def get_empty_sorted_index
    for i in 0...@sorted_members.size
      return i if @sorted_members[i] == -1
    end
    return -1
  end

  def troop
    return @players.values
  end
  
  def get_active_members
    returns = []
    for actor in members
      if actor.action.ready? && actor.action.nothing_selected?
        returns.push actor
      end
    end
    return returns
  end

  def get_active_alive_members
    temp = get_active_members
    out = []
    for i in 0...temp.size
      out.push temp[i] unless temp[i].dead?
    end
    return out
  end

  def get_active_alive_players
    temp = get_active_alive_members
    out = []
    for i in 0...temp.size
      out.push @players[temp[i].id]
    end
    return out.compact
  end

  # -------------------------------------------------------------------------- #
  # This adds another player to the player array.
  def add_player(actor_id)
    if @reserve.key?(actor_id)
      player = @reserve[actor_id].clone
      @reserve.remove(actor_id)
      set_sorted_member(-1, actor_id)
    else
      player = Game_Player.new
      set_new_sorted_member(actor_id)
    end
    player.set_player(actor_id)
    player.x = $game_player.x
    player.y = $game_player.y
    player.direction = $game_player.direction
    player.in_line = true
    @players[actor_id] = player
    if $game_map.map_id > 0
      @players[actor_id].moveto($game_player.x, $game_player.y)
    end
  end

  def any_alive_enemy_in_range?
    for enemy in $game_troop.troop
      next if enemy == nil
      if !enemy.battler.dead? && $game_party.get_leader.battle_range.inside?(enemy.x, enemy.y)
        return true
      end
    end
    return false
  end

  def any_alive_enemy_spotted?
    for enemy in $game_troop.troop
      next if enemy == nil
      if !enemy.battler.dead? && $game_party.get_leader.sight_range.inside?(enemy.x, enemy.y)
        return true
      end
    end
    return false
  end

  def any_player_battle_moving?
    $game_party.players.values.each { |player|
      return true if !player.get_member.nil? && player.get_member.battle_movement
    }
    return false
  end

  def reset_atb
    for e in members
      e.reset_atb
    end
  end
  #--------------------------------------------------------------------------
  # * Add an Actor
  #     actor_id : actor ID
  #--------------------------------------------------------------------------
  def add_actor(actor_id)
    @actor_id = actor_id if @actor_id < 0
    @actor_index = 0 if @actor_index < 0
    @actors.push(actor_id)
    add_player(actor_id)
    $scene.recreate_spriteset if $scene.is_a?(Scene_Map)
    update
  end
  #--------------------------------------------------------------------------
  # * Remove Actor
  #     actor_id : actor ID
  #--------------------------------------------------------------------------
  def remove_actor(actor_id)
    @actors.delete(actor_id)
    @reserve[actor_id] = @players[actor_id]
    @players.delete(actor_id)
    $game_player.refresh
    update
  end
  # -------------------------------------------------------------------------- #
  # Sets the currently indexed player as active player, opening the update
  # function to allow the sprite and (0)character to update based on input.
  def set_player(id)
    $game_player = @players[id]
    self.update
  end

  def set_startup_player
    for i in 0...5
      return if sorted_members[i] == -1
      $game_player = @players[sorted_members[i]]
      return
    end
  end
  # -------------------------------------------------------------------------- #
  # @deprecated
  def prepare_line
  end
  # -------------------------------------------------------------------------- #
  def snap_line(x=nil,y=nil)
    set_leader
    return if $game_player.nil?# or !$scene.is_a?(Game_Map)
    $game_player.trail.clear
    for i in 0...5
      next if @sorted_members[i] == -1
      player = @players[@sorted_members[i]]
      if x.nil? or y.nil?
        player.force_path($game_player.x, $game_player.y) if $scene.is_a?(Game_Map) or $scene.is_a?(Scene_Party)
      else
        player.force_path(x, y)
      end
    end
  end

  def active_snap_line(x,y)
    for i in 0...5
      next if @sorted_members[i] == -1
      player = @players[@sorted_members[i]]
      player.trail.clear
      player.force_path(x,y)
    end
  end

  def set_leader
    $game_player = @players[@sorted_members[0]]
  end

  def get_leader
    return @players[@sorted_members[0]]
  end

  def leader
    return get_leader
  end

  def halt_movement
    for player in @players.values
      next if player.nil?
      player.halt_movement
      player.force_action = nil
    end
  end

  def any_player_moving?
    @players.values.each do |player|
      return true if player.move_route_forcing || player.moving?
    end
    return false
  end

  def clear_battle_movement
    mems = all_members_safe
    for i in 0...mems.size
      mems[i].battle_movement = false
    end
  end

  # -------------------------------------------------------------------------- #
  # Updates all of the player members.
  def update
    update_players
    update_members
    update_enemies
    update_line
  end
  # -------------------------------------------------------------------------- #
  def update_players
    for i in 0...5
      next if @players[@sorted_members[i]].nil?
      @players[@sorted_members[i]].update
    end
  end

  def update_members
    for i in 0...5
      next if @sorted_members[i] == -1
      $game_actors[@sorted_members[i]].action.update
    end
  end

  def update_enemies
    for i in 0...$game_troop.members.size
      $game_troop.members[i].action.update
    end
  end
  # -------------------------------------------------------------------------- #
  def update_line
    return if $game_player.nil?
    return unless $game_player.moved
    trail = $game_player.trail.clone
    trail.pop unless trail.empty?
    return if trail.empty?
    for position in 0...5
      next if (player = @players[@sorted_members[position]]).nil?
      next if player.actor_id == $game_player.actor_id
      next unless player.in_line
      break if trail.empty?
      player.force_action = Map_Action.new(:move_direction, trail.pop)
    end
    $game_player.moved = false if $game_player.moved
  end
  # -------------------------------------------------------------------------- #
  def break_line
    for k in @players.keys
      @players[k].in_line = false
    end
    $game_player.in_line = false
  end

  def reform_line
    for k in @players.keys
      @players[k].in_line = true
    end
    $game_player.in_line = true
    snap_line
  end
  # -------------------------------------------------------------------------- #
  def refresh
    for player in players.values
      player.refresh
    end
  end
  # -------------------------------------------------------------------------- #
  # Determines if the base actor is the same as the one in the database.
  def actor_the_same?(base_actor)
    return (member_stats_match?($game_actors[base_actor.id], base_actor))
  end

  def member_stats_match?(m1,m2)
    return false if m1.nil? or m2.nil?
    return ( m1.maxhp == m2.maxhp and m1.maxmp == m2.maxmp and
       m1.hp == m2.hp and m1.mp == m2.mp and
       m1.status_update == m2.status_update )
  end
  # -------------------------------------------------------------------------- #
  # Retrieves the battler and player from the actor_id
  def get_player_battler(actor_id)
    players.each { |act_id, player|
      next if act_id != actor_id
      members.values { |member|
        return [player, member] if player.actor_id == member.actor_id
      }
    }
    return nil
  end
  # -------------------------------------------------------------------------- #
  # Retrieves the battler from an actor template
  def get_actor(actor)
    return nil if actor.nil?
    members.each { |member|
      return member if actor.id == member.id
    }
    return nil
  end
  # -------------------------------------------------------------------------- #
  # Retrieves the battler from a player event
  def get_battler(player)
    members.each { |member|
      return member if player.actor_id == member.id
    }
    return nil
  end
  # -------------------------------------------------------------------------- #
  # Retrieves the player from the battler
  def get_player(battler)
    @players.each { |act_id, player|
      return player if act_id == battler.id
    }
  end
  def get_player_id(id)
    @players.each { |act_id, player|
      return player if act_id == id
    }
    return nil
  end
  def get_players_xy(x, y)
    out = []
    @players.each_value { |player|
      out.push player if player.x == x && player.y == y
    }
    return out
  end
  def player_here?(x, y)
    return !get_players_xy(x, y).empty?
  end
  # -------------------------------------------------------------------------- #
  # Transfers all the players, this is a post operation.
  def transfer_players
    for player in players.values
      player.moveto($game_player.new_x, $game_player.new_y)
      player.force_action = nil
    end
    snap_line
    $game_player.trail.clear if $game_player.trail != nil
  end
  # -------------------------------------------------------------------------- #
  # This forces the entire party to be moved to an x and y position.
  def moveto(x,y)
    for player in players.values
      player.moveto(x,y)
    end
  end

  def formations
    return PHI::Formation.formations
  end

  # -------------------------------------------------------------------------- #
  # EXP battle method.
  # -------------------------------------------------------------------------- #

  def distribute_exp(exp)
    for member in @sorted_members
      next if member == -1
      @players[member].get_member.gain_exp(exp, false)
    end
  end

  def get_levels_and_ids
    out = {}
    for i in 0...@sorted_members.size
      id = @sorted_members[i]
      next if id == -1
      out[id] = @players[id].get_member.level
    end
    return out
  end

  def get_levelups(old_levels)
    output = []
    current_levels = get_levels_and_ids
    old_levels.each_pair do |key, level|
      if current_levels[key] != level
        output.push key
      end
    end
    return output
  end

  # -------------------------------------------------------------------------- #
end