#==============================================================================
# ** Game_Actor
#------------------------------------------------------------------------------
#  This class handles actors. It's used within the Game_Actors class
# ($game_actors) and referenced by the Game_Party class ($game_party).
#==============================================================================
class Float
  def round_p(precision)
    return ((self * 10**precision).round.to_f) / (10**precision)
  end
end

module PHI
  module ACTORS
    DEFAULT_FIFTHS = {
        1 => 12, #Plate
        2 => 8,  #Elemental
        3 => 16, #Martial
        4 => 8,
        5 => 16,
        6 => 8,
        7 => 4, #leather
        8 => 4,
        9 => 12,
        10 => 8,
        11 => 4
    }
  end
end

class Game_Actor < Game_Battler
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_reader   :name                     # name
  attr_reader   :character_name           # (0)character graphic filename
  attr_reader   :character_index          # (0)character graphic index
  attr_reader   :face_name                # face graphic filename
  attr_reader   :face_index               # face graphic index
  attr_reader   :class_id                 # class ID
  attr_reader   :weapon1_id               # weapon ID
  attr_reader   :weapon2_id               # shield ID
  attr_reader   :armor1_id                # helmet ID
  attr_reader   :armor2_id                # accessory armor ID
  attr_reader   :armor3_id                # body armor ID
  attr_reader   :armor4_id                # leg armor id
  attr_reader   :level                    # level
  attr_reader   :exp                      # experience
  attr_accessor :last_skill_id            # for cursor memory: Skill
  attr_accessor :current_weapon           # if 0 weapon 0th slot, if 1 weapon 1th slot
  #--------------------------------------------------------------------------
  # * Object Initialization
  #     actor_id : actor ID
  #--------------------------------------------------------------------------
  def initialize(actor_id)
    super()
    setup(actor_id)
    @last_skill_id = 0
  end
  #--------------------------------------------------------------------------
  # * Setup
  #     actor_id : actor ID
  #--------------------------------------------------------------------------
  def setup(actor_id)
    actor = $data_actors[actor_id]
    @actor_id = actor_id
    @name = actor.name
    @character_name = actor.character_name
    @character_index = actor.character_index
    @face_name = actor.face_name
    @face_index = actor.face_index
    @class_id = actor.class_id
    @weapon1_id = $game_party.equipment.new_gear(true, actor.weapon_id,  actor.initial_level, [], true)#actor.initial_level)
    @weapon2_id = $game_party.equipment.new_gear(true, actor.armor1_id,  actor.initial_level, [], true)#actor.initial_level)
    @armor1_id  = $game_party.equipment.new_gear(false, actor.armor2_id, actor.initial_level, [], true)#actor.initial_level)
    @armor2_id  = $game_party.equipment.new_gear(false, actor.armor3_id, actor.initial_level, [], true)#actor.initial_level)
    @armor3_id  = $game_party.equipment.new_gear(false, actor.armor4_id, actor.initial_level, [], true)#actor.initial_level)
    @armor4_id  = $game_party.equipment.new_gear(false, PHI::ACTORS::DEFAULT_FIFTHS[@actor_id], actor.initial_level, [], true)#actor.initial_level)
    # include 6th gear into class equipment list
    #self.class
    @level = actor.initial_level
    set_equipment_stats
    @exp_list = Array.new(101)
    @current_weapon = 0
    make_exp_list
    @exp = @exp_list[@level]
    @skills = {}
    learn_skills
    clear_extra_values
    recover_all
  end

  def equip_ids
    return [@weapon1_id, @weapon2_id, @armor1_id, @armor2_id, @armor3_id, @armor4_id]
  end
  #--------------------------------------------------------------------------
  # * Determine if Actor or Not
  #--------------------------------------------------------------------------
  def actor?
    return true
  end
  #--------------------------------------------------------------------------
  # * Get Actor ID
  #--------------------------------------------------------------------------
  def id
    return @actor_id
  end
  #--------------------------------------------------------------------------
  # * Get Index
  #--------------------------------------------------------------------------
  def index
    return $game_party.members.index(self)
  end
  #--------------------------------------------------------------------------
  # * Get Actor Object
  #--------------------------------------------------------------------------
  def actor
    return $data_actors[@actor_id]
  end
  #--------------------------------------------------------------------------
  # * Get Class Object
  #--------------------------------------------------------------------------
  def class
    return $data_classes[@class_id]
  end
  #--------------------------------------------------------------------------
  # * Get Skill Object Array
  #--------------------------------------------------------------------------
  def skills
    return @skills
  end

  #--------------------------------------------------------------------------
  # * Get Weapon Object Array
  #--------------------------------------------------------------------------
  def weapons
    result = []
    result.push($game_party.equipment[@weapon1_id])
    result.push($game_party.equipment[@weapon2_id])
    return result
  end
  #--------------------------------------------------------------------------
  # * Get Armor Object Array
  #--------------------------------------------------------------------------
  def armors
    result = []
    result.push($game_party.equipment[@armor1_id])
    result.push($game_party.equipment[@armor2_id])
    result.push($game_party.equipment[@armor3_id])
    result.push($game_party.equipment[@armor4_id])
    return result
  end
  #--------------------------------------------------------------------------
  # * Get Equipped Item Object Array
  #--------------------------------------------------------------------------
  def equips
    result = []
    result.push($game_party.equipment[@weapon1_id])
    result.push($game_party.equipment[@weapon2_id])
    result.push($game_party.equipment[@armor1_id])
    result.push($game_party.equipment[@armor2_id])
    result.push($game_party.equipment[@armor3_id])
    result.push($game_party.equipment[@armor4_id])
    return result
  end
  #--------------------------------------------------------------------------
  # * Calculate Experience
  #--------------------------------------------------------------------------
  def make_exp_list
    @exp_list[1] = @exp_list[999 + 1] = 0
    m = 2000
    (2..999).each do |i|
      @exp_list[i] = @exp_list[i-1] + Integer(m)
      m += 2000
    end
  end
  #--------------------------------------------------------------------------
  # * Get Element List
  #--------------------------------------------------------------------------
  def get_element_resistence
    result = {}
    for id in 0...14
      result[id] = element_resistance(id)
    end
    return result
  end
  def get_element_damages
    result = {}
    for id in 0...14
      result[id] = element_damage(id)
    end
  end
  #--------------------------------------------------------------------------
  # * Get Element Change Value
  #     element_id : element ID
  #--------------------------------------------------------------------------
  def element_resistance(element_id)
    rank = self.class.element_ranks[element_id]
    result = PHI::ENEMY::ELEMENT_RANKS[rank]
    for armor in equips.compact
      result += armor.stat_ele_res(element_id, result)
    end
    element_id < 7 ? result += phy_res : result += ele_res
    return result
  end
  def element_damage(element_id)
    result = 100
    for armor in equips.compact
      result += armor.stat_ele_dam(element_id, result)
    end
    return result
  end
  #--------------------------------------------------------------------------
  # * Get Critical Ratio
  #--------------------------------------------------------------------------
  def cri
    n = 5
    n += (self.agi / 50.0).to_i + base_cri
    return n
  end

  #--------------------------------------------------------------------------
  # * Get Experience String
  #--------------------------------------------------------------------------
  def exp_s
    return @exp_list[@level+1] > 0 ? @exp : "-------"
  end
  #--------------------------------------------------------------------------
  # * Get String for Next Level Experience
  #--------------------------------------------------------------------------
  def next_exp_s
    return @exp_list[@level+1] > 0 ? @exp_list[@level+1] : "-------"
  end
  #--------------------------------------------------------------------------
  # * Get String for Experience to Next Level
  #--------------------------------------------------------------------------
  def next_rest_exp_s
    return @exp_list[@level+1] > 0 ?
      (@exp_list[@level+1] - @exp) : "-------"
  end
  #--------------------------------------------------------------------------
  # * Change Equipment (designate ID)
  #     equip_type : Equip region (0..4)
  #     item_id    : Weapon ID or armor ID
  #     test       : Test flag (for battle test or temporary equipment)
  #    Used by event commands or battle test preparation.
  #--------------------------------------------------------------------------
  def change_equip_by_id(equip_type, item_id, test = false)
    change_equip(equip_type, item_id)
  end
  #--------------------------------------------------------------------------
  # * Change Equipment (designate object)
  #     equip_type : Equip region (0..4)
  #     item       : Weapon or armor (nil is used to unequip)
  #     test       : Test flag (for battle test or temporary equipment)
  #--------------------------------------------------------------------------
  def change_equip(equip_socket, item_id)
    case equip_socket
      when 0  # Weapon 1
        $game_party.equipment.unequip(@weapon1_id, item_id)
        @weapon1_id = item_id
      when 1  # Weapon 2
        $game_party.equipment.unequip(@weapon2_id, item_id)
        @weapon2_id = item_id
      when 2  # Head
        $game_party.equipment.unequip(@armor1_id, item_id)
        @armor1_id = item_id
      when 3  # Overcoat
        $game_party.equipment.unequip(@armor2_id, item_id)
        @armor2_id = item_id
      when 4  # Body
        $game_party.equipment.unequip(@armor3_id, item_id)
        @armor3_id = item_id
      when 5 # Feet
        $game_party.equipment.unequip(@armor4_id, item_id)
        @armor4_id = item_id
    end
    set_equipment_stats
  end
  #--------------------------------------------------------------------------
  # * Discard Equipment
  #     item : Weapon or armor to be discarded.
  #    Used when the "Include Equipment" option is enabled.
  #--------------------------------------------------------------------------
  def discard_equip(item)
    #if item.is_a?(RPG::Weapon)
    # if @weapon1_id == item.id
    #    @weapon1_id = 0
    #  elsif two_swords_style and @weapon2_id == item.id
    #    @weapon2_id = 0
    #  end
    #elsif item.is_a?(RPG::Armor)
    #  if not two_swords_style and @weapon2_id == item.id
    #    @weapon2_id = 0
    #  elsif @armor1_id == item.id
    #    @armor1_id = 0
    #  elsif @armor2_id == item.id
    ##    @armor2_id = 0
    #  elsif @armor3_id == item.id
    #    @armor3_id = 0
    #  end
    #end
  end
  #--------------------------------------------------------------------------
  # * Determine if Two handed Equipment
  #--------------------------------------------------------------------------
  def two_hands_legal?
    if weapons[0] != nil and weapons[0].two_handed
      return false if @weapon2_id != 0
    end
    if weapons[1] != nil and weapons[1].two_handed
      return false if @weapon1_id != 0
    end
    return true
  end
  #--------------------------------------------------------------------------
  # * Determine if Equippable
  #     db_id : position in the equipment database for the equip
  #--------------------------------------------------------------------------
  def equippable?(db_id)
    return false unless db_id.is_a?(Integer)
    item = $game_party.equipment[db_id]
    if item.weapon?
      return self.class.weapon_set.include?(item.base_id)
    else
      return self.class.armor_set.include?(item.base_id)
    end
    return false
  end
  #--------------------------------------------------------------------------
  # * Change Experience
  #     exp  : New experience
  #     show : Level up display flag
  #--------------------------------------------------------------------------
  def change_exp(exp, show)
    last_level = @level
    last_skills = skills
    @exp = [[exp, 32999999].min, 0].max
    while @exp >= @exp_list[@level+1] and @exp_list[@level+1] > 0
      level_up
    end
    while @exp < @exp_list[@level]
      level_down
    end
    @hp = maxhp
    @mp = maxmp
    @stamina = base_maxstamina
   end
  #--------------------------------------------------------------------------
  # * Level Up
  #--------------------------------------------------------------------------
  def level_up
    @level += 1
    #Todo: add sp levelup protocol here.
    #for learning in self.class.learnings
    #  learn_skill(learning.skill_id) if learning.level == @level
    #end
  end
  #--------------------------------------------------------------------------
  # * Level Down
  #--------------------------------------------------------------------------
  def level_down
    @level -= 1
  end
  #--------------------------------------------------------------------------
  # * Show Level Up Message
  #     new_skills : Array of newly learned skills
  #--------------------------------------------------------------------------
  def display_level_up(new_skills)
  end
  #--------------------------------------------------------------------------
  # * Get Experience (for the double experience point option)
  #     exp  : Amount to increase experience.
  #     show : Level up display flag
  #--------------------------------------------------------------------------
  def gain_exp(exp, show)
    change_exp(@exp + exp, show)
  end
  #--------------------------------------------------------------------------
  # * Change Level
  #     level : new level
  #     show  : Level up display flag
  #--------------------------------------------------------------------------
  def change_level(level, show)
    change_exp(@exp_list[level], show)
  end
  #--------------------------------------------------------------------------
  # * Learn Skill
  #     skill_id : skill ID
  #--------------------------------------------------------------------------
  def learn_skill(skill_id)
    p 'Old learn skill used, needs new.'
  end
  def learn_skills
    for belt_index in 0...PHI::SKILL_DATA::CLASS_SKILL_TREES[self.skill_title_id].size
      #p @skill_belt_data
      belt_key = PHI::SKILL_DATA::CLASS_SKILL_TREES[self.skill_title_id][belt_index]
      PHI::SKILL_DATA::SKILLS[self.skill_title_id][belt_key].each do |sk_id, skill|
        @skills[belt_key] = {} unless @skills.keys.include? belt_key
        @skills[belt_key][sk_id] = Skill_Object.new(self.skill_title_id, belt_key, sk_id)
      end
    end
  end

  def get_skill_tree_title(belt_index)
    return PHI::SKILL_DATA::CLASS_SKILL_TREES[skill_title_id][belt_index]
  end

  def skill_title_id
    return PHI::SKILL_DATA::CLASS_TITLES[@class_id]
  end

  def get_skill(belt_key, skill_key)
    if @skills.keys.include? belt_key && @skills[belt_key].keys.include?(skill_key)
      return @skills[belt_key][skill_key]
    end
    return nil
  end

  def get_skill_belt_pos(belt_index)
    belt_key = PHI::SKILL_DATA::CLASS_SKILL_TREES[self.skill_title_id][belt_index]
    if @skills.keys.include? belt_key
      return get_sorted_belt_array(@skills[belt_key])
    end
    return nil
  end

  def get_sorted_belt_array(belt)
    out = []
    belt.keys.sort.each { |key|
      out.push belt[key]
    }
    return out
  end

  def get_skill_belt(belt_key)
    if @skills.keys.include? belt_key
      return @skills[belt_key]
    end
    return nil
  end
  #--------------------------------------------------------------------------
  # * Forget Skill
  #     skill_id : skill ID
  #--------------------------------------------------------------------------
  def forget_skill(skill_id)
    if @skills.keys.include?(skill_id)
      @skills[skill_id].unlocked = false
    end
  end
  #--------------------------------------------------------------------------
  # * Determine if Finished Learning Skill
  #     skill : skill
  #--------------------------------------------------------------------------
  def skill_learn?(skill_id)
    if @skills.keys.include?(skill_id)
      return @skills[skill_id].unlocked
    end
    return false
  end
  #--------------------------------------------------------------------------
  # * Determine Usable Skills
  #     skill : skill
  #--------------------------------------------------------------------------
  def skill_can_use?(skill)
    return false unless skill_learn?(skill)
    return super
  end
  #--------------------------------------------------------------------------
  # * Change Name
  #     name : new name
  #--------------------------------------------------------------------------
  def name=(name)
    @name = name
  end
  #--------------------------------------------------------------------------
  # * Change Class ID
  #     class_id : New class ID
  #--------------------------------------------------------------------------
  def class_id=(class_id)
    @class_id = class_id
  end
  #--------------------------------------------------------------------------
  # * Change Graphics
  #     character_name  : new (0)character graphic filename
  #     character_index : new (0)character graphic index
  #     face_name       : new face graphic filename
  #     face_index      : new face graphic index
  #--------------------------------------------------------------------------
  def set_graphic(character_name, character_index, face_name, face_index)
    @character_name = character_name
    @character_index = character_index
    @face_name = face_name
    @face_index = face_index
    reset_o_animation
  end
  #--------------------------------------------------------------------------
  # * Use Sprites?
  #--------------------------------------------------------------------------
  def use_sprite?
    return false
  end
  #--------------------------------------------------------------------------
  # * Perform Collapse
  #--------------------------------------------------------------------------
  def perform_collapse
    if $game_temp.in_battle and dead?
      @collapse = true
      Sound.play_actor_collapse
    end
  end
  #--------------------------------------------------------------------------
  # * Perform Automatic Recovery (called at end of turn)
  #--------------------------------------------------------------------------
  def do_auto_recovery
    if auto_hp_recover and not dead?
      self.hp += maxhp / 20
    end
  end

  def base_parameter(type)
    return @level * actor.parameters[type, 1]
  end
  #--------------------------------------------------------------------------
  # ? ?? MaxHP ???
  #--------------------------------------------------------------------------
  def base_maxhp
    n =  base_parameter(0) + (base_atk * 4) + e_stat(:hp)
    return n.to_i
  end
  def base_maxmp
    n = base_parameter(1) + (base_spi * 2) + e_stat(:mp)
    #equips.each { |item| n += item.mp(n) }
    return n.to_i
  end
  def base_maxstamina
    n = 100 + e_stat(:sta)
    #equips.each { |item| n += item.stamina(n) }
    return n.to_i
  end
  def base_atk
    n = base_parameter(2) + e_stat(:str)
    #equips.each { |item| n += item.atk(base_parameter(2)) }
    return n.to_i
  end
  def base_spi
    n = base_parameter(4) + e_stat(:int)
    #equips.each { |item| n += item.spi(base_parameter(4)) }
    return n.to_i
  end
  def base_agi
    n = base_parameter(5) + e_stat(:agi)
    #equips.each { |item| n += item.agi(base_parameter(5)) }
    return n.to_i
  end
  def base_def
    n = base_parameter(3) + e_stat(:def)
    #equips.each { |item| n += item.def(base_parameter(3)) }
    return n.to_i
  end
  def base_sta_res
    n = e_stat(:sta_res)
    #equips.each { |item| n += item.sta_res(n) }
    return n.to_i
  end
  def base_cri
    n = 5 + e_stat(:cri)
    #equips.each { |item| n += item.cri(n)}
    return n
  end
  def base_cri_mul
    n = 1.5 + e_stat(:cmul)
    #equips.each { |item| n += item.cri_mul(n) }
    return n
  end
  def base_res
    n = (base_def / 25.0).round_p(1) + e_stat(:ares)
    #equips.compact.each { |item| n += item.res(n) }
    return n
  end
  def base_ele_res
    n = base_res + e_stat(:eres)
    #equips.each { |item| n += item.ele_res_i(n) }
    return n
  end
  def base_phy_res
    n = base_res + e_stat(:pres)
    #equips.each { |item| n += item.phy_res_i(n) }
    return n
  end
  def phy_res
    return res + base_phy_res# * @level
  end
  def ele_res
    return res + base_ele_res# * @level
  end
  def sta_res
    return res + base_sta_res# * @level
  end
  def cri_mul
    return base_cri_mul + (0.1 * (self.agi / 50.0)).round_p(1)
  end

  def e_stat(key)
    return @equip_stats[key]
  end

  def stats
    statz = {
        :hp => base_maxhp,
        :mp => base_maxmp,
        :sta => base_maxstamina,
        :str => base_atk,
        :agi => base_agi,
        :int => base_spi,
        :def => base_def,
        :ares => base_res,
        :pres => base_phy_res,
        :eres => base_ele_res,
        :sres => base_sta_res,
        :cri => base_cri,
        :cmul => base_cri_mul
    }
    return element_both(statz)
  end

  def element_both(in_hash={})
    for i in 0...PHI::ICONS::SORTED_ELEMENTS.keys.size
      in_hash[PHI::ICONS::SORTED_ELEMENTS[i]] = []
      in_hash[PHI::ICONS::SORTED_ELEMENTS[i]].push element_damage(i+1) #if ele_dam(i+1) != 0
      in_hash[PHI::ICONS::SORTED_ELEMENTS[i]].push element_resistance(i+1) #if ele_res(i+1) != 0
    end
    return in_hash
  end

  def set_equipment_stats
    @equip_stats = {}
    @equip_stats[:hp] = 0
    @equip_stats[:mp] = 0
    @equip_stats[:sta] = 0
    @equip_stats[:str] = 0
    @equip_stats[:agi] = 0
    @equip_stats[:int] = 0
    @equip_stats[:def] = 0
    @equip_stats[:ares] = 0
    @equip_stats[:pres] = 0
    @equip_stats[:eres] = 0
    @equip_stats[:sres] = 0
    @equip_stats[:cri] = 0
    @equip_stats[:cmul] = 0
    equips.each { |item|
      @equip_stats[:hp]   += item.hp(base_parameter(0) + (base_atk * 4)).to_i
      @equip_stats[:mp]   += item.mp(base_parameter(1) + (base_spi * 2)).to_i
      @equip_stats[:sta]  += item.stamina(100).to_i
      @equip_stats[:str]  += item.atk(base_parameter(2)).to_i
      @equip_stats[:agi]  += item.agi(base_parameter(3)).to_i
      @equip_stats[:int]  += item.spi(base_parameter(4)).to_i
      @equip_stats[:def]  += item.def(base_parameter(5)).to_i
      @equip_stats[:ares] += item.res((base_def / 25.0).round_p(1)).to_i
      @equip_stats[:pres] += item.phy_res_i(1).to_i
      @equip_stats[:eres] += item.ele_res_i(1).to_i
      @equip_stats[:sres] += item.sta_res(0).to_i
      @equip_stats[:cri]  += item.cri(5).to_i
      @equip_stats[:cmul] += item.cri_mul(1.5).to_i
    }
  end

end