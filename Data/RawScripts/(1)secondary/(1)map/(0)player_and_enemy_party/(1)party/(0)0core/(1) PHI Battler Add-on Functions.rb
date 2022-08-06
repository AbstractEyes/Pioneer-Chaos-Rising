module BATTLE_DATA
  
  # In frames by default, speed and dexterity decrease.
  ATB_TIMER   = 300
  # In seconds by default set to 0, speed and magi decrease, and increase.
  SKILL_TIMER = 300
  
  COOLDOWN_TIMER = 300

  FLASH_TIMER = 20
  
end
=begin
class Game_Battler
  attr_reader   :macros
  attr_accessor :pathing
  attr_accessor :battle_movement
  attr_accessor :appear
  alias old_initialize initialize
  def initialize
    old_initialize
    @active_skill = nil
    @atb_counter = BATTLE_DATA::ATB_TIMER
    @skill_counter = BATTLE_DATA::SKILL_TIMER
    @cooldown_counter = BATTLE_DATA::COOLDOWN_TIMER
    @macros = PHI::PLAYER_MACROS::MACRO_VALUES
    self.pathing = false
    self.battle_movement = false
    self.appear = false
  end
  
  def update
    update_atb
  end
  
  def update_atb
    # If atb meter is full, and skill is not active.
    return if self.pathing
    unless ready?
      atb_step
      return
    end
    # Skill not full, step
    if !skill_full? && is_skill? # If skill meter is full, and skill is active.
      #@skill_counter = BATTLE_DATA::SKILL_TIMER
      skill_step
      return
    else
      # Skill full, confirm bool.
      @skill_ready = true
      return
    end
  end

  def atb
    return @atb_counter
  end

  def reset_atb
    @atb_counter = 0.0
  end
  
  # Step the counters
  def atb_step
    distance = BATTLE_DATA::ATB_TIMER
    modifier = 999
    modifier += self.level * 1.5
    modifier = self.agi + 1 if modifier < self.agi
    rate = distance / (modifier - self.agi).to_f + 1
    rate = 50 if rate > 50
    #p rate if self.name == "Maximus"
    @atb_counter += rate
  end

  def skill_step
    @skill_counter -= (((self.action.skill.startup * BATTLE_DATA::ATB_TIMER) + ((self.spi/100)*25).to_i / 100).to_i * 5)
  end
  
  # Check bool flags
  def atb_full?
    return (@atb_counter >= BATTLE_DATA::ATB_TIMER)
  end
  def ready?
    return atb_full? && !self.pathing
  end
  def skill_full?
    return (@skill_counter <= 0)
  end
  def skill_ready?
    return skill_full?
  end

  def path_required?
    return self.pathing
  end

  def nothing_active?
    return self.action.nothing?
  end
  def is_attack?
    return self.action.attack?
  end
  def is_defend?
    return self.action.guard?
  end
  def is_skill?
    return self.action.skill?
  end
  def is_move?
    return self.action.moving?
  end

  def movement_enabled?
    return self.battle_movement
  end
#~   
#~   def agi
#~     return 22
#~   end
#~   
#~   def max_agi
#~     return 22
#~   end
  
end
=end