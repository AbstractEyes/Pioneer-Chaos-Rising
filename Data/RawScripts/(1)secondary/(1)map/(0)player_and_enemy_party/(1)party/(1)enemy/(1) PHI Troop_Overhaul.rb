#==============================================================================
# ** Game_Troop
#------------------------------------------------------------------------------
#  This class handles battle-related data.
#  The instance of this class is referenced by $game_troop.
#==============================================================================

class Game_Troop < Game_Unit
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize
    super
  end
  #--------------------------------------------------------------------------
  # * Gets battler Members
  #--------------------------------------------------------------------------
  def members
    out = []
    for event in troop
      out.push(event.battler)
    end
    return out
  end

  def members_in_range
    out = []
    for event in troop
      out.push(event.battler) if $game_player.battle_range.inside?(event.x, event.y)
    end
    return out
  end
  
  def get_character(battler)
    for event in troop
      return event if battler == event.battler
    end
    return nil
  end
  
  def get_member(event_id)
    out = []
    for event in troop
      out.push(event) if event.event.id == event_id
    end
    return out
  end

  def get_enemies_xy(x, y)
    out = []
    for enemy in troop
      out.push enemy if enemy.x == x && enemy.y == y && !enemy.battler.dead?
    end
    return out
  end

  def enemy_here?(x, y)
    return !get_enemies_xy(x,y).empty?
  end
  
  #--------------------------------------------------------------------------
  # * Get all of nearby Troop Member events from map.
  #   returns array of events
  #--------------------------------------------------------------------------
  def troop
    output = []
    $game_map.events.values.each { |event| 
      next if event.battler == nil
      output.push(event)
    }
    return output
  end
  #--------------------------------------------------------------------------
  # * Setup
  #     troop_id : troop ID
  #--------------------------------------------------------------------------
  def setup
    # Every time you enter a map, it wipes every enemy.
    for ev in $game_map.events.values
      next unless ev.is_enemy?
      #p "iterating past"
      if PHI::ENTITY_DATA::ENTITIES.keys.include?(ev.battler_id)
        p 'got past the lock'
        #next unless PHI::ENTITY_DATA::ENTITIES.keys.include?(ev.battler_id)
        ev.battler = Game_Enemy.new(ev.battler_id, ev, true)
      end
      #else
      #  ev.battler_id = ev.battler_id.to_i
      #  next if $data_enemies[ev.battler_id] == nil
      #  ev.battler = Game_Enemy.new(ev.battler_id, ev, false)
      #end
    end
  end
  
  def get_enemy(id)
    for battler in troop
      return battler if battler.id == id
    end
    return nil
  end
#~   #--------------------------------------------------------------------------
#~   # * Determine if battle event (page) meets conditions
#~   #     page : battle event page
#~   #--------------------------------------------------------------------------
#~   def conditions_met?(page)
#~     c = page.condition
#~     if not c.turn_ending and not c.turn_valid and not c.enemy_valid and
#~        not c.actor_valid and not c.switch_valid
#~       return false      # Conditions not set: Not executed
#~     end
#~     if @event_flags[page]
#~       return false      # Executed
#~     end
#~     if c.turn_ending    # At turn end
#~       return false unless @turn_ending
#~     end
#~     if c.turn_valid     # Number of turns
#~       n = @turn_count
#~       a = c.turn_a
#~       b = c.turn_b
#~       return false if (b == 0 and n != a)
#~       return false if (b > 0 and (n < 1 or n < a or n % b != a % b))
#~     end
#~     if c.enemy_valid    # Enemy
#~       enemy = $game_troop.members[c.enemy_index]
#~       return false if enemy == nil
#~       return false if enemy.hp * 100.0 / enemy.maxhp > c.enemy_hp
#~     end
#~     if c.actor_valid    # Actor
#~       actor = $game_actors[c.actor_id]
#~       return false if actor == nil 
#~       return false if actor.hp * 100.0 / actor.maxhp > c.actor_hp
#~     end
#~     if c.switch_valid   # Switch
#~       return false if $game_switches[c.switch_id] == false
#~     end
#~     return true         # Condition met
#~   end
#~   #--------------------------------------------------------------------------
#~   # * Battle Event Setup
#~   #--------------------------------------------------------------------------
#~   def setup_battle_event
#~     return if @interpreter.running?
#~     if $game_temp.common_event_id > 0
#~       common_event = $data_common_events[$game_temp.common_event_id]
#~       @interpreter.setup(common_event.list)
#~       $game_temp.common_event_id = 0
#~       return
#~     end
#~     for page in troop.pages
#~       next unless conditions_met?(page)
#~       @interpreter.setup(page.list)
#~       if page.span <= 1
#~         @event_flags[page] = true
#~       end
#~       return
#~     end
#~   end
#~   #--------------------------------------------------------------------------
#~   # * Increase Turns
#~   #--------------------------------------------------------------------------
#~   def increase_turn
#~     for page in troop.pages
#~       if page.span == 1
#~         @event_flags[page] = false
#~       end
#~     end
#~     @turn_count += 1
#~   end
#~   #--------------------------------------------------------------------------
#~   # * Create Battle Action
#~   #--------------------------------------------------------------------------
#~   def make_actions
#~     if @preemptive
#~       clear_actions
#~     else
#~       for enemy in members
#~         enemy.make_action
#~       end
#~     end
#~   end
#~   #--------------------------------------------------------------------------
#~   # * Determine Everyone is Dead
#~   #--------------------------------------------------------------------------
#~   def all_dead?
#~     return existing_members.empty?
#~   end
  
  def get_exp(event_id)
    
  end
  #--------------------------------------------------------------------------
  # * Calculate Total Experience
  #--------------------------------------------------------------------------
  def exp_total
  end
  #--------------------------------------------------------------------------
  # * Calculate Total Gold
  #--------------------------------------------------------------------------
  def gold_total
  end
  #--------------------------------------------------------------------------
  # * Create Array of Dropped Items
  #--------------------------------------------------------------------------
  def make_drop_items
#~     drop_items = []
#~     for enemy in dead_members
#~       for di in [enemy.drop_item1, enemy.drop_item2]
#~         next if di.kind == 0
#~         next if rand(di.denominator) != 0
#~         if di.kind == 1
#~           drop_items.push($data_items[di.item_id])
#~         elsif di.kind == 2
#~           drop_items.push($data_weapons[di.weapon_id])
#~         elsif di.kind == 3
#~           drop_items.push($data_armors[di.armor_id])
#~         end
#~       end
#~     end
#~     return drop_items
  end
end
