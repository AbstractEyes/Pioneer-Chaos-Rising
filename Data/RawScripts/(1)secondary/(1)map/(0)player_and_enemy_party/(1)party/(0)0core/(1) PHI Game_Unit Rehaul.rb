#==============================================================================
# ** Game_Unit
#------------------------------------------------------------------------------
#  This class handles units. It's used as a superclass of the Game_Party and
# Game_Troop (0)classes.
#==============================================================================

class Game_Unit
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize
  end
  #--------------------------------------------------------------------------
  # * Get Members (redefine as a subclass)
  #--------------------------------------------------------------------------
  def members
    return []
  end
  def troop
    return []
  end
  #--------------------------------------------------------------------------
  # * @return bool if any event in sight
  #--------------------------------------------------------------------------
  def in_sight?(character)
    for ev in troop
      return true if ev.in_sight?(character)
    end
    return false
  end
  #--------------------------------------------------------------------------
  # * Get Array of Living Members
  #--------------------------------------------------------------------------
  def existing_members
    result = []
    for battler in members
      next unless battler.exist?
      result.push(battler)
    end
    return result
  end
  #--------------------------------------------------------------------------
  # * Get array of Incapacitated Members
  #--------------------------------------------------------------------------
  def dead_members
    result = []
    for battler in members
      next unless battler.dead?
      result.push(battler)
    end
    return result
  end
  #--------------------------------------------------------------------------
  # * Clear all Members' Battle Actions
  #--------------------------------------------------------------------------
  # Deprecated.
  def clear_actions
    for battler in members
      battler.action.clear
    end
  end
  #--------------------------------------------------------------------------
  # * Random Selection of Target
  #--------------------------------------------------------------------------
  # Todo: Replace random target.
  def random_target
    roulette = []
    for member in existing_members
      member.odds.times do
        roulette.push(member)
      end
    end
    return roulette.size > 0 ? roulette[rand(roulette.size)] : nil
  end
  #--------------------------------------------------------------------------
  # * Random Selection of Target (incapacitated)
  #--------------------------------------------------------------------------
  #Todo: Fix random dead target.
  def random_dead_target
    roulette = []
    for member in dead_members
      roulette.push(member)
    end
    return roulette.size > 0 ? roulette[rand(roulette.size)] : nil
  end
  #--------------------------------------------------------------------------
  # * Smooth Selection of Target
  #     index : Index
  #--------------------------------------------------------------------------
  #Todo: Deprecate smooth target.
  def smooth_target(index)
    member = members[index]
    return member if member != nil and member.exist?
    return existing_members[0]
  end
  #--------------------------------------------------------------------------
  # * Smooth Selection of Target (incapacitated)
  #     index : Index
  #--------------------------------------------------------------------------
  # Deprecate smooth target.
  def smooth_dead_target(index)
    member = members[index]
    return member if member != nil and member.dead?
    return dead_members[0]
  end
  #--------------------------------------------------------------------------
  # * Calculate Average Agility
  #--------------------------------------------------------------------------
  def average_agi
    result = 0
    n = 0
    for member in members
      result += member.agi
      n += 1
    end
    result /= n if n > 0
    result = 1 if result == 0
    return result
  end
  #--------------------------------------------------------------------------
  # * Application of Slip Damage Effects
  #--------------------------------------------------------------------------
  def slip_damage_effect
    for member in members
      member.slip_damage_effect
    end
  end
end
