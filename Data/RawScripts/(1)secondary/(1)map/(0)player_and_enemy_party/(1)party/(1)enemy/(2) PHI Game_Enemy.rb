#==============================================================================
# ** Game_Enemy
#------------------------------------------------------------------------------
#  This class handles enemy characters. It's used within the Game_Troop class
# ($game_troop).
#==============================================================================
module RPG
  class Enemy

    def skill_id
      note.each_line do |line|
        if line.include?('<id')
          return (line.split(' ')[1].tr('>', '').tr(':', '')).to_sym
        end
      end
      return nil
    end

    def unlocked_skills
      out = []
      note.each_line do |line|
        if line.include?('<skill')
          nl = line.tr('<', '').tr('>', '').split(' ').clone
          for i in 1...nl.size
            nl[i] = nl[i].to_i
          end
          out.push(nl[1...nl.size])
        end
      end
      return out
    end

  end
end

class Unlocked_Skill
  attr_accessor :class_id
  attr_accessor :weapon_id
  attr_accessor :skill_id
  attr_accessor :level
  def initialize(raw)
    chunks = raw.split('~')
    self.class_id = chunks[0].tr(':','').to_sym
    self.weapon_id = chunks[1].tr(':', '').to_sym
    self.skill_id = chunks[2].to_i
    self.level = chunks[3].to_i
  end
end

class Game_Enemy < Game_Battler
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_reader   :enemy_id                 # enemy ID
  attr_reader   :name                     # original name
  attr_accessor :event
  attr_accessor :skills
  attr_accessor :class_id
  attr_accessor :skill_id
  attr_reader   :unlocked_skills
  #--------------------------------------------------------------------------
  # * Object Initialization
  #     index    : index in troop
  #     enemy_id : enemy ID
  #--------------------------------------------------------------------------
  def initialize(enemy_id, event, new_enemy = false)
    super()
    @enemy_id = enemy_id
    @event = event
    @new_enemy = new_enemy
    if @new_enemy
      @enemy = Enemy_Object.new(PHI::ENTITY_DATA::ENTITIES[@enemy_id])
    else
      @enemy = $data_enemies[@enemy_id]
    end
    #p @enemy.inspect
    @name = enemy.name
    @battler_name = enemy.name
    @hp = enemy.hp
    @mp = enemy.mp
    @res = enemy.phy_res
    @skills = {}
    @skill_id = enemy.skill_id
    @unlocked_skills = prepare_unlocks(enemy.unlocked_skills)
    learn_skills
    #p self.enemy.inspect
    #p ' enemy done '
    #@action = Game_BattleAction.new(self)
  end

  def prepare_unlocks(raw)
    out = []
    for dur in enemy.unlocked_skills
      out.push Unlocked_Skill.new(dur)
    end
    return out
  end

  def learn_skills
    #todo: properly implement the skill learning
    if @new_enemy
      for skill in @unlocked_skills
        if PHI::SKILL_DATA::CLASS_SKILL_TREES.keys.include?(skill.class_id)
          @skills[skill.weapon_id] = {} unless @skills.keys.include? skill.weapon_id
          @skills[skill.weapon_id][skill.skill_id] = Skill_Object.new(@skill_id, skill.weapon_id, skill.skill_id)
          @skills[skill.weapon_id][skill.skill_id].level = skill.level
        end
      end
    else
      for belt_index in 0...PHI::SKILL_DATA::CLASS_SKILL_TREES[@skill_id].size
        belt_key = PHI::SKILL_DATA::CLASS_SKILL_TREES[@skill_id][belt_index]
        PHI::SKILL_DATA::SKILLS[@skill_id][belt_key].each do |sk_id, skill|
          if knows_skill?(belt_index, sk_id)
            #p 'Learning skill ', belt_key, sk_id
            @skills[belt_key] = {} unless @skills.keys.include? belt_key
            @skills[belt_key][sk_id] = Skill_Object.new(@skill_id, belt_key, sk_id)
            @skills[belt_key][sk_id].level = get_base_level(belt_index, sk_id)
          end
        end
      end
    end

  end

  def get_base_level(key, id)
    for data in @unlocked_skills
      return data[2] if data[0] == key && data[1] == id
    end
    return 1
  end

  def knows_skill?(key, id)
    #p @unlocked_skills.inspect
    for data in @unlocked_skills
      return true if data[0] == key && data[1] == id
    end
    return false
  end

  def character
    return @event
  end

  def level
    return enemy.level
  end

  #--------------------------------------------------------------------------
  def matched_id?(e)
    return @event.event.id == e.event.id
  end
  #--------------------------------------------------------------------------
  # * Determine if Actor or Not
  #--------------------------------------------------------------------------
  def actor?
    return false
  end
  #--------------------------------------------------------------------------
  # * Get Enemy Object
  #--------------------------------------------------------------------------
  def enemy
    return @enemy
  end
  #--------------------------------------------------------------------------
  # * Get Display Name
  #--------------------------------------------------------------------------
  def name
    return @name
  end
  #--------------------------------------------------------------------------
  # * Get Basic Maximum HP
  #--------------------------------------------------------------------------
  def base_maxhp
    return enemy.hp
  end
  #--------------------------------------------------------------------------
  # * Get basic Maximum MP
  #--------------------------------------------------------------------------
  def base_maxmp
    return enemy.mp
  end
  def base_maxres
    return enemy.maxres
  end
  def base_maxstamina
    #Todo: Fix enemy stamina.
    return 100
  end
  #--------------------------------------------------------------------------
  # * Get Basic Attack
  #--------------------------------------------------------------------------
  def base_atk
    return enemy.atk
  end
  #--------------------------------------------------------------------------
  # * Get Basic Defense
  #--------------------------------------------------------------------------
  def base_def
    return enemy.def
  end
  #--------------------------------------------------------------------------
  # * Get Basic Spirit
  #--------------------------------------------------------------------------
  def base_spi
    return enemy.spi
  end
  #--------------------------------------------------------------------------
  # * Get Basic Agility
  #--------------------------------------------------------------------------
  def base_agi
    return enemy.agi
  end
  def base_res
    return enemy.res
  end
  def base_phy_res
    return enemy.phy_res
  end
  def base_ele_res
    return enemy.ele_res_v
  end
  def base_sta_res
    n = 0
    return n
  end
  def base_cri_mul
    return enemy.cri_mul
  end
  def phy_res
    return base_phy_res * @level
  end
  def ele_res
    return base_ele_res * @level
  end
  def sta_res
    return base_sta_res * @level
  end
  def cri_mul
    return base_cri_mul + (0.1 * (self.agi / 50.0))
  end
  def cri
    return enemy.cri# ? 10 : 0
  end
  #--------------------------------------------------------------------------
  # * Get Element Change Value
  #     element_id : element ID
  #--------------------------------------------------------------------------
  def element_resistence_rate(element_id)
    rank = enemy.element_ranks[element_id]
    result = [0,200,150,100,50,0,-100][rank]
    for state in states
      result /= 2 if state.element_set.include?(element_id)
    end
    return result
  end
  #--------------------------------------------------------------------------
  # * Get Element List
  #--------------------------------------------------------------------------
  def get_element_resistance
    result = {}
    (1...14).each { |id|
      result[id] = element_resistance(id)
    }
    return result
  end
  def get_element_damage
    result = {}
    (1...14).each do |id|
      result[id] = element_damage(id)
    end
  end
  def element_damage(element_id)
    out = 100
    enemy.ele_dam.each do |ele| out += ele[0] if ele[0] == element_id end
    return out
  end
  #--------------------------------------------------------------------------
  # * Get Added State Success Rate
  #     state_id : state ID
  #--------------------------------------------------------------------------
  def state_probability(state_id)
    return enemy.sta_res
  end
  #--------------------------------------------------------------------------
  # * Get Experience
  #--------------------------------------------------------------------------
  def exp
    return enemy.exp
  end
  #--------------------------------------------------------------------------
  # * Get Gold
  #--------------------------------------------------------------------------
  def gold
    return enemy.gold
  end
  def drops
    return enemy.drops
  end
  #--------------------------------------------------------------------------
  # * Determine if Action Conditions are Met
  #     action : battle action
  #--------------------------------------------------------------------------
  def conditions_met?(action)
    return true
    case action.condition_type
    when 1  # Number of turns
      n = $game_troop.turn_count
      a = action.condition_param1
      b = action.condition_param2
      return false if (b == 0 and n != a)
      return false if (b > 0 and (n < 1 or n < a or n % b != a % b))
    when 2  # HP
      hp_rate = hp * 100.0 / maxhp
      return false if hp_rate < action.condition_param1
      return false if hp_rate > action.condition_param2
    when 3  # MP
      mp_rate = mp * 100.0 / maxmp
      return false if mp_rate < action.condition_param1
      return false if mp_rate > action.condition_param2
    when 4  # State
      return false unless state?(action.condition_param1)
    when 5  # Party level
      return false if $game_party.max_level < action.condition_param1
    when 6  # Switch
      switch_id = action.condition_param1
      return false if $game_switches[switch_id] == false
    end
    return true
  end

end
