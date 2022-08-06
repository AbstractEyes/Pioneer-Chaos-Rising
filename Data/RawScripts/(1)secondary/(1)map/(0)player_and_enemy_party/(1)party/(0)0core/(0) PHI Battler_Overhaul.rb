#==============================================================================
# ** Game_Battler
#------------------------------------------------------------------------------
#  This class deals with battlers. It's used as a superclass of the Game_Actor
# and Game_Enemy (0)classes.
#==============================================================================

class Game_Battler
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_reader   :battler_name             # battle graphic filename
  attr_reader   :battler_hue              # battle graphic hue
  attr_reader   :hp                       # HP
  attr_reader   :mp                       # MP
  attr_reader   :stamina
  attr_reader   :action                   # battle action
  attr_accessor :hidden                   # hidden flag
  attr_accessor :immortal                 # immortal flag
  attr_accessor :animation_id             # animation ID
  attr_accessor :animation_mirror         # animation flip horizontal flag
  attr_accessor :white_flash              # white flash flag
  attr_accessor :blink                    # blink flag
  attr_accessor :collapse                 # collapse flag
  attr_reader   :skipped                  # action results: skipped flag
  attr_reader   :missed                   # action results: missed flag
  attr_reader   :evaded                   # action results: evaded flag
  attr_reader   :critical                 # action results: critical flag
  attr_reader   :absorbed                 # action results: absorbed flag
  attr_reader   :hp_damage                # action results: HP damage
  attr_reader   :mp_damage                # action results: MP damage
  attr_reader   :str_damage
  attr_reader   :agi_damage
  attr_reader   :int_damage
  attr_reader   :def_damage
  attr_accessor :flash
  attr_accessor :targets
  attr_accessor :shape_manager
  attr_accessor :battle_movement
  attr_accessor :resurrect
  attr_accessor :lingering
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize
    @battler_name = ""
    @battler_hue = 0
    @hp = 0
    @mp = 0
    @stamina = 0
    @action = Game_BattleAction.new(self)
    @hidden = false   
    @immortal = false
    @shape_manager = Shape_Manager.new(self)
    @states = []
    @lingering = []
    @battle_movement = false
    clear_extra_values
    clear_sprite_effects
    clear_action_results
  end
  #--------------------------------------------------------------------------
  # * Clear Values Added to Parameter
  #--------------------------------------------------------------------------
  def clear_extra_values
    @maxhp_plus = 0
    @maxmp_plus = 0
    @maxstamina_plus = 0
    @atk_plus = 0
    @def_plus = 0
    @spi_plus = 0
    @agi_plus = 0
    @dex_plus = 0
    @res_plus = 0
    @state_res_plus = 0
    @ele_res_plus = 0
    @phy_res_plus = 0
    @cri_mul_plus = 0
    @cri_plus = 0
  end
  #--------------------------------------------------------------------------
  # * Clear Variable Used for Sprite Communication
  #--------------------------------------------------------------------------
  def clear_sprite_effects
    @animation_id = 0
    @animation_mirror = false
    @white_flash = false
    @blink = false
    @collapse = false
    @resurrect = false
    @flash = false
  end
  #--------------------------------------------------------------------------
  # * Clear Variable for Storing Action Results
  #--------------------------------------------------------------------------
  def clear_action_results
    @skipped = false
    @missed = false
    @evaded = false
    @critical = false
    @absorbed = false
    @hp_damage = 0
    @mp_damage = 0
    @stam_damage = 0
    @str_damage = 0
    @agi_damage = 0
    @int_damage = 0
    @def_damage = 0
    @res_damage = 0
    @state_damage = 0
    @ele_res_damage = 0
    @phy_res_damage = 0
    @cri_damage = 0
    @cri_mul_damage = 0
    #@added_states = []              # Added states (ID array)
    #@removed_states = []            # Removed states (ID array)
    #@remained_states = []           # Unchanged states (ID array)
  end

  def perks
    return [] if @skills.nil?
    output = []
    @skills.each do |key, skill|
      output.push skill if skill.unlocked #todo: and is passive
    end
    return output
  end

  def skills
    out = []
    @skills.each do |key, skill|
      out.push skill if skill.unlocked
    end
    return out
  end

  def weapon1_skills
    return [] if @skills.nil?
    output = []
    @skills[@skills.keys[0]].each do |key, skill|
      output.push skill #if skill.unlocked
    end
    return output
  end

  def weapon2_skills
    return [] if @skills.nil?
    output = []
    @skills[@skills.keys[1]].each do |key, skill|
      output.push skill #if skill.unlocked
    end
    return output
  end

  def armor_skills
    return [] if @skills.nil?
    output = []
    @skills[@skills.keys[2]].each do |key, skill|
      output.push skill #if skill.unlocked
    end
    return output
  end
  #--------------------------------------------------------------------------
  def maxhp
    return [base_maxhp + @maxhp_plus - @hp_damage + maxhp_lingering, 1].max
  end
  def maxmp
    return [base_maxmp + @maxmp_plus - @mp_damage + maxmp_lingering, 0].max
  end
  def maxstr
    return [base_atk + @atk_plus - @str_damage + maxatk_lingering, 0].max
  end
  def maxagi
    return [base_agi + @agi_plus - @agi_damage + maxagi_lingering, 0].max
  end
  def maxint
    return [base_spi + @spi_plus - @int_damage + maxint_lingering, 0].max
  end
  def maxdef
    return [base_def + @def_plus - @def_damage + maxdef_lingering, 0].max
  end
  def maxres
    return base_res + @res_plus - @res_damage + maxres_lingering
  end
  def maxstares
    return base_sta_res + @state_res_plus - @state_damage + maxstateres_lingering
  end
  def maxphyres
    return base_phy_res + @phy_res_plus - @phy_res_damage + maxphyres_lingering
  end
  def maxeleres
    return base_ele_res + @ele_res_plus - @ele_res_damage + maxeleres_lingering
  end
  def maxcri
    return base_cri + @cri_plus - @cri_damage + maxcri_lingering
  end
  def maxcrimul
    return base_cri_mul + @cri_mul_plus - @cri_mul_damage + maxcrimul_lingering
  end
  def maxstamina
    return 100 + @maxstamina_plus - @stam_damage + maxstam_lingering
  end
  def atk
    n = [base_atk + @atk_plus, 1].max
    n = [Integer(n), 1].max
    return n
  end

  def def
    n = [base_def + @def_plus, 1].max
    n = [Integer(n), 1].max
    return n
  end

  def spi
    n = [base_spi + @spi_plus, 1].max
    n = [Integer(n), 1].max
    return n
  end

  def agi
    n = [base_agi + @agi_plus, 1].max
    n = [Integer(n), 1].max
    return n
  end
  def res
    n = base_res + @res_plus
    return n
  end
  def sta_res
    n = base_sta_res + @state_res_plus
    return n
  end
  def phy_res
    n = base_phy_res + @phy_res_plus
    return n
  end
  def ele_res_v
    n = base_ele_res + @ele_res_plus
    return n
  end
  def cri
    n = base_cri + @cri_plus
    return n
  end
  def cri_mul
    n = base_cri_mul + @cri_mul_plus
    return n
  end

  def maxhp=(new_maxhp)
    @maxhp_plus += new_maxhp - self.maxhp
    @maxhp_plus = [[@maxhp_plus, -maxhp_limit].max, maxhp_limit].min
    @hp = [@hp, self.maxhp].min
  end
  def maxmp=(new_maxmp)
    @maxmp_plus += new_maxmp - self.maxmp
    @maxmp_plus = [[@maxmp_plus, -maxmp_limit].max, maxmp_limit].min
    @mp = [@mp, self.maxmp].min
  end

  def hp=(hp)
    @hp = [[hp, maxhp].min, 0].max
  end
  def mp=(mp)
    @mp = [[mp, maxmp].min, 0].max
  end
  def stamina=(stamina)
    @stamina = [[stamina, maxstamina].min, 0].max
  end

  def atk=(new_atk)
    @atk_plus += new_atk - self.atk
  end
  def def=(new_def)
    @def_plus += new_def - self.def
  end
  def spi=(new_spi)
    @spi_plus += new_spi - self.spi
  end
  def agi=(new_agi)
    @agi_plus += new_agi - self.agi
  end
  def res=(new_res)
    @res_plus += new_res - self.res
  end
  def sta_res=(new_res)
    @state_res_plus += new_res - self.sta_res
  end
  def phy_res=(new_res)
    @phy_res_plus += new_res - self.phy_res
  end
  def ele_res_v=(new_res)
    @ele_res_plus += new_res - self.ele_res_v
  end
  def cri=(new_cri)
    @cri_plus += new_cri - self.cri
  end
  def cri_mul=(new_cri)
    @cri_mul_plus += new_cri - self.cri_mul
  end
  #--------------------------------------------------------------------------
  def process_manipulation(base_attribute, skill_changes)
    out = 0
    skill_changes.each { |change|
      num = chop_ps(change[0]).to_i
      if change[0].include?('%')
        if change[0].include?('+')
          out +=  apply_variance(base_attribute + (base_attribute * (num / 100.0)), change[1].to_i)
        elsif change[0].include?('-')
          out += -apply_variance((base_attribute + (base_attribute * (num / 100.0))), change[1].to_i)
        else
          out += apply_variance(base_attribute * (num / 100.0), change[1].to_i)
        end
      else
        if change[0].include?('-')
          out += -num
        else
          out += num
        end
      end
    }
    return out.to_i
  end

  def lingering_process_attribute(sym)
    out = 0
    lingering.each { |l_skill|
      for i in 0..l_skill.stacks
        skill = l_skill.skill
        case sym
          when :str
            out += process_manipulation(base_atk, skill.atk_dam)
          when :agi
            out += process_manipulation(base_agi, skill.agi_dam)
          when :int
            out += process_manipulation(base_spi, skill.int_dam)
          when :res
            out += process_manipulation(base_res, skill.res_dam)
          when :sta_res
            out += process_manipulation(base_sta_res, skill.status_res_dam)
          when :phy_res
            out += process_manipulation(base_phy_res, skill.phy_res_dam)
          when :ele_res
            out += process_manipulation(base_ele_res, skill.ele_res_dam)
          when :def
            out += process_manipulation(base_def, skill.def_dam)
          when :hp
            out += process_manipulation(base_maxhp, skill.hp_dam)
          when :mp
            out += process_manipulation(base_maxmp, skill.mp_dam)
          when :sta
            out += process_manipulation(base_maxstamina, skill.sta_dam)
          when :cri
            out += process_manipulation(base_cri, skill.cri_dam)
          when :cri_mul
            out += process_manipulation(base_cri_mul, skill.cri_mul_dam)
        end
      end
    }
    return out
  end

  def maxhp_lingering
    return lingering_process_attribute(:hp)
  end
  def maxmp_lingering
    return lingering_process_attribute(:mp)
  end
  def maxstam_lingering
    return lingering_process_attribute(:sta)
  end
  def maxatk_lingering
    return lingering_process_attribute(:str)
  end
  def maxagi_lingering
    return lingering_process_attribute(:agi)
  end
  def maxint_lingering
    return lingering_process_attribute(:int)
  end
  def maxdef_lingering
    return lingering_process_attribute(:def)
  end
  def maxres_lingering
    return lingering_process_attribute(:res)
  end
  def maxstateres_lingering
    return lingering_process_attribute(:sta_res)
  end
  def maxeleres_lingering
    return lingering_process_attribute(:ele_res_v)
  end
  def maxphyres_lingering
    return lingering_process_attribute(:phy_res)
  end
  def maxcri_lingering
    return lingering_process_attribute(:cri)
  end
  def maxcrimul_lingering
    return lingering_process_attribute(:cri_mul)
  end

  #--------------------------------------------------------------------------
  # * Recover All
  #--------------------------------------------------------------------------
  def recover_all
    self.hp = maxhp
    self.mp = maxmp
    self.stamina = maxstamina
    self.atk = maxstr
    self.agi = maxagi
    self.spi = maxint
    self.def = maxdef
    self.res = maxres
    self.sta_res = maxstares
    self.phy_res = maxphyres
    self.ele_res_v = maxeleres
    self.cri = maxcri
    self.cri_mul = maxcrimul
    #self.status_res = maxsta
  end

  #--------------------------------------------------------------------------
  # * Determine Incapacitation
  #--------------------------------------------------------------------------
  def dead?
    return (not @hidden and @hp <= 0 and not @immortal)
  end
  #--------------------------------------------------------------------------
  # * Get Element Change Value
  #     element_id : element ID
  #--------------------------------------------------------------------------
  def element_resistance(element_id)
    return 100
  end
  def element_damage(element_id)
    return 100
  end
  #--------------------------------------------------------------------------
  # * Get Added State Success Rate
  #--------------------------------------------------------------------------
  def state_probability(state_id)
    return 0
  end
  #--------------------------------------------------------------------------
  # * Determine if State is Resisted
  #     state_id : state ID
  #--------------------------------------------------------------------------
  def state_resist?(state_id)
    return false
  end
  #--------------------------------------------------------------------------
  # * Get Normal Attack Element
  #--------------------------------------------------------------------------
  def element_set
    return []
  end
  #--------------------------------------------------------------------------
  # * Get Normal Attack State Change (+)
  #--------------------------------------------------------------------------
  def plus_state_set
    return []
  end
  #--------------------------------------------------------------------------
  # * Get Normal Attack State Change (-)
  #--------------------------------------------------------------------------
  def minus_state_set
    return []
  end
  #--------------------------------------------------------------------------
  # * Calculation of MP Consumed for Skills
  #     skill : skill
  #--------------------------------------------------------------------------
  def calc_mp_cost(skill)
    if half_mp_cost
      return skill.mp_cost / 2
    else
      return skill.mp_cost
    end
  end
  #--------------------------------------------------------------------------
  # * Determine Usable Skills
  #     skill : skill
  #--------------------------------------------------------------------------
  #Todo: Reform skill can use into something usable.
  def skill_can_use?(skill)
    return true
    #return false unless skill.is_a?(RPG::Skill)
    #return false unless movable?
    #return false if silent? and skill.spi_f > 0
    #return false if calc_mp_cost(skill) > mp
    #if $game_temp.in_battle
    #  return skill.battle_ok?
    #else
    #  return skill.menu_ok?
    #end
  end

  #--------------------------------------------------------------------------
  # * Calculation of Damage Caused by Skills or Items
  #     user : User of skill or item
  #     obj  : Skill or item (for normal attacks, this is nil)
  #    The results are substituted for @hp_damage or @mp_damage.
  #--------------------------------------------------------------------------
  #Todo: convert to item only objects.
  def make_obj_damage_value(user, obj)
    primary_stat = user.atk #get_primary_obj_stat(user, obj)
    damage = obj.base_damage + obj.damage + primary_stat           # get base damage
    variance = obj.atk_f
    if damage > 0                                   # a positive number?
      damage += primary_stat * 4 * variance / 100   # Attack F of the user
      #damage += user.spi * 2 * obj.spi_f / 100      # Spirit F of the user
      unless obj.ignore_defense                     # Except for ignore defense
        damage -= self.def * 2 * variance / 100    # Attack F of the target
      end
      damage = 0 if damage < 0                      # If negative, make 0
    elsif damage < 0                                # a negative number?
      damage -= user.atk * 4 * obj.atk_f / 100      # Attack F of the user
      damage -= user.spi * 2 * obj.spi_f / 100      # Spirit F of the user
    end
    damage += equipment_elemental_damage(user, damage)

    #damage *= elements_max_rate(obj.element_set)    # elemental adjustment
    #damage /= 100
    damage = apply_variance(damage, obj.variance)   # variance
    damage = apply_guard(damage)                    # guard adjustment
    if obj.damage_to_mp
      @mp_damage = damage                           # damage MP
    else
      @hp_damage = damage                           # damage HP
    end
  end

  def make_skill_damage_value(user, skill, segment=nil)
    if segment.nil?
      @hp_damage += prepare_hp_damage(user, skill).to_i
      @mp_damage += prepare_stat_damage(user, skill, skill.mp_dam).to_i
      @stam_damage += prepare_stat_damage(user, skill, skill.sta_dam).to_i
      @str_damage += prepare_stat_damage(user, skill, skill.atk_dam).to_i
      @agi_damage += prepare_stat_damage(user, skill, skill.agi_dam).to_i
      @int_damage += prepare_stat_damage(user, skill, skill.int_dam).to_i
      @def_damage += prepare_stat_damage(user, skill, skill.def_dam).to_i
      @res_damage += prepare_stat_damage(user, skill, skill.res_dam).to_i
      #@phy_res_damage += prepare_stat_damage(user, skill, skill.phy_res_dam).to_i
      #@ele_res_damage += prepare_stat_damage(user, skill, skill.ele_res_dam).to_i

      #@phy_res_damage
      #@ele_res_damage
      #@cri
      #@cri_mul
      #stack_lingering(user, skill)
    else
      #todo damage for segment changes.
    end
    #prepare_aura_skill(user, skill)
  end

  def skill_lingering?(skill)
    return nil unless skill.residue?
    for l_skill in lingering
      if l_skill.skill.__id__ == skill.__id__
        return l_skill
      end
    end
    return nil
  end

  def stack_lingering(user, skill)
    if (l_skill = skill_lingering?(skill)) != nil
      l_skill.stack_up
    else
      return unless skill.residue?
      @lingering.push Lingering_Skill.new(skill)
    end
  end

  def prepare_hp_damage(user, skill)
    #Get damage attribute and take percentage based on the array.
    damage = 0
    p user.name, skill.name
    damage = process_damage_attr(user, damage, skill)
    p "process_damage_attr: " + damage.to_s
    damage = apply_damage_resistance(process_damage(user, damage, skill.raw_dam))
    p "apply_damage_resistance: " + damage.to_s
    damage = scaled_skill_elemental_damage(user, damage)
    p "scaled_skill_elemental_damage: " + damage.to_s
    damage = equipment_elemental_damage(user, damage)
    p "equipment_elemental_damage: " + damage.to_s
    damage = 1 if damage.to_i == 0
    return damage
  end

  def prepare_stat_damage(user, skill, damage_arry)
    damage = 0
    damage = process_damage_attr(user, damage, skill)
    damage = process_stat_damage(user, damage, damage_arry)
    return damage
  end

  def process_stat_damage(user, damage, damage_arr)
    return 0 if damage_arr.empty?
    return process_damage(user, damage, damage_arr)
  end

  def apply_damage_resistance(damage)
    # damage = damage - (damage * ((self.def * 0.02) / 1000))
    return damage - (damage * (self.def / 1000.0)).floor
  end

  def process_damage(user, damage, damage_arr)
    p 'process damage ' + " " + damage.to_s + " " + damage_arr.inspect
    for dmg in damage_arr
      if dmg[0].include?('+')
        if has_pct?(dmg[0])
          damage += apply_variance(damage * (chop_ps(dmg[0]) / 100.0), dmg[1])
        else
          damage += apply_variance(chop_ps(dmg[0]), dmg[1])
        end
      elsif dmg[0].include?('-')
        if has_pct?(dmg[0])
          damage += -apply_variance(damage * (chop_ps(dmg[0]) / 100.0), dmg[1])
        else
          damage += -apply_variance(chop_ps(dmg[0]), dmg[1])
        end
      else
        # Multiply
        if has_pct?(dmg[0])
          damage = apply_variance(damage * (chop_ps(dmg[0]) / 100.0), dmg[1])
        else
          damage *= apply_variance(chop_ps(dmg[0]), dmg[1])
        end
      end
    end
    return damage
  end

  def chop_ps(str)
    out = str.tr('%', '')
    out = out.tr('+', '')
    out = out.tr('-', '')
    out = out.tr('*', '')
    out = out.tr('/', '')
    return out.to_f
  end

  def has_pct?(str)
    return str.include?('%')
  end

  def process_damage_attr(user, damage, skill)
    dam_out = 0
    if skill.dam_attr.nil? or skill.dam_attr.empty?
      return damage + 1
    else
      attrs = skill.dam_attr
    end
    p 'attrs: ' + attrs.inspect
    attrs.each do |attr|
      case attr[0]
        when :str
          dam_out += user.atk * (attr[1] / 100.0)
        when :agi
          dam_out += user.agi * (attr[1] / 100.0)
        when :int
          dam_out += user.spi * (attr[1] / 100.0)
      end
    end
    p 'dam_out: ' + dam_out.inspect
    return damage + dam_out
  end

  def equipment_elemental_damage(user, damage)
    #@damage = damage
    #(1...14).each do |id|
    #  damage += (((damage * user.element_damage(id)) / 100) * (100 - self.element_resistance(id)))
    #end
    return damage
  end

  def scaled_skill_elemental_damage(user, damage)
    stacked_damage = 0
    #temp_damage = damage
    user.action.skill.ele_dam.each do |node|
      value = chop_ps(node[0]).to_i
      variance = node[1]
      element_id = PHI::ICONS::ELEMENT_LIST[node[2]]
      chopped_damage = apply_variance(damage * (value / 100.0), variance)
      #temp_damage -= chopped_damage
      stacked_damage += ((chopped_damage * (value / 100.0)) * (self.element_resistance(element_id) / 100))
    end
    return stacked_damage
    #return temp_damage + stacked_damage
  end

  #--------------------------------------------------------------------------
  # * Get Maximum Elemental Adjustment Amount
  #     element_set : Elemental alignment
  #    Returns the most effective adjustment of all elemental alignments.
  #--------------------------------------------------------------------------
  def elements_max_rate(element_set)
    #return 100 if element_set.empty?                # If there is no element
    #rate_list = []
    #for i in element_set
    #  rate_list.push(element_resist(i))
    #end
    #return rate_list.max
  end
  #--------------------------------------------------------------------------
  # * Applying Variance
  #     damage   : Damage
  #     variance : Degree of variance
  #--------------------------------------------------------------------------
  def apply_variance(damage, variance)
    return damage if variance == 100
    if damage != 0                                  # If damage is not 0
      amp = [damage.abs * variance / 100, 0].max    # Calculate range
      damage += rand(amp+1) + rand(amp+1) - amp     # Execute variance
    end
    return damage
  end
  #--------------------------------------------------------------------------
  # * Damage Reflection
  #     user : User of skill or item
  #    @hp_damage, @mp_damage, or @absorbed must be calculated before this
  #    method is called.
  #--------------------------------------------------------------------------
  def execute_damage
    #if @hp_damage > 0           # Damage is a positive number
    #  remove_states_shock       # Remove state due to attack
    #end
    self.hp -= @hp_damage
    self.mp -= @mp_damage
    self.stamina -= @stam_damage
    self.atk -= @str_damage
    self.agi -= @agi_damage
    self.spi -= @int_damage
    self.def -= @def_damage
    self.res -= @res_damage
    #if @absorbed                # If absorbing
    #  user.hp += (@hp_damage / 4).to_i
    #  user.mp += (@mp_damage / 4).to_i
    #end
  end
  #--------------------------------------------------------------------------
  # * Apply State Changes
  #     obj : Skill, item, or attacker
  #--------------------------------------------------------------------------
  def apply_state_changes(obj)
    return
    #plus = obj.plus_state_set             # get state change (+)
    #minus = obj.minus_state_set           # get state change (-)
    #for i in plus                         # state change (+)
    #  next if state_resist?(i)            # is it resisted?
    #  next if dead?                       # are they incapacitated?
    #  next if i == 1 and @immortal        # are they immortal?
    #  if state?(i)                        # is it already applied?
    #    @remained_states.push(i)          # record unchanged states
    #    next
    #  end
    #  if rand(100) < state_probability(i) # determine probability
    #    add_state(i)                      # add state
   #     @added_states.push(i)             # record added states
   #   end
   # end
   # for i in minus                        # state change (-)
   #   next unless state?(i)               # is the state not applied?
   #   remove_state(i)                     # remove state
   #   @removed_states.push(i)             # record removed states
   # end
   # for i in @added_states & @removed_states  # if there are any states in
   #   @added_states.delete(i)                 # both added and removed
   #   @removed_states.delete(i)               # sections, delete them both
   # end
  end
  #--------------------------------------------------------------------------
  # * Determine Whether to Apply a Normal Attack
  #     attacker : Attacker
  #--------------------------------------------------------------------------
  def attack_effective?(attacker)
    if dead?
      return false
    end
    return true
  end
  #--------------------------------------------------------------------------
  # * Apply Normal Attack Effects
  #     attacker : Attacker
  #--------------------------------------------------------------------------
  def attack_effect(attacker)
    clear_action_results
    #Todo: Redo dead check, possibly.  Not likely though.
#    unless attack_effective?(attacker)
#      @skipped = true
#      return
#    end
#    #Todo: Redo missed check.
#    if rand(100) >= calc_hit(attacker)            # determine hit ratio
#      @missed = true
#      return
#    end
    #Todo: Redo evaded check.
#    if rand(100) < calc_eva(attacker)             # determine evasion rate
#      @evaded = true
#      return
#    end
    make_attack_damage_value(attacker)            # damage calculation
    execute_damage(attacker)                      # damage reflection
    if @hp_damage == 0                            # physical no damage?
      return                                    
    end
    apply_state_changes(attacker)                 # state change
  end
  #--------------------------------------------------------------------------
  # * Determine if a Skill can be Applied
  #     user  : Skill user
  #     skill : Skill
  #--------------------------------------------------------------------------
  def skill_effective?(user, skill)
    if skill.for_dead_friend? != dead?
      return false
    end
    if not $game_temp.in_battle and skill.for_friend?
      return skill_test(user, skill)
    end
    return true
  end
  #--------------------------------------------------------------------------
  # * Skill Application Test
  #     user  : Skill user
  #     skill : Skill
  #    Used to determine, for example, if a (0)character is already fully healed
  #    and so cannot recover anymore.
  #--------------------------------------------------------------------------
  def skill_test(user, skill)
    tester = self.clone
    tester.make_obj_damage_value(user, skill)
    tester.apply_state_changes(skill)
    if tester.hp_damage < 0
      return true if tester.hp < tester.maxhp
    end
    if tester.mp_damage < 0
      return true if tester.mp < tester.maxmp
    end
    return true unless tester.added_states.empty?
    return true unless tester.removed_states.empty?
    return false
  end
  def make_ele_damage(user, skill)

  end
  #--------------------------------------------------------------------------
  # * Apply Skill Effects
  #     user  : Skill user
  #     skill : skill
  #--------------------------------------------------------------------------
  def skill_effect(user, skill)
    clear_action_results
    #unless skill_effective?(user, skill)
    #  @skipped = true
    #  return
    #end
    #if rand(100) >= calc_hit(user, skill)         # determine hit ratio
    #  @missed = true
    #  return
    #end
    #if rand(100) < calc_eva(user, skill)          # determine evasion rate
    #  @evaded = true
    #  return
    #end
    make_obj_damage_value(user, skill)            # calculate damage
    make_obj_absorb_effect(user, skill)           # calculate absorption effect
    execute_damage(user)                          # damage reflection
    #p skill.inspect
    #if skill.physical_attack and @hp_damage == 0  # physical no damage?
    #  return
    #end
    apply_state_changes(skill)                    # state change
  end
  #--------------------------------------------------------------------------
  # * Determine if an Item can be Used
  #     user : Item user
  #     item : item
  #--------------------------------------------------------------------------
  def item_effective?(user, item)
    if item.for_dead_friend? != dead?
      return false
    end
    if not $game_temp.in_battle and item.for_friend?
      return item_test(user, item)
    end
    return true
  end
  #--------------------------------------------------------------------------
  # * Item Application Test
  #     user : Item user
  #     item : item
  #    Used to determine, for example, if a (0)character is already fully healed
  #    and so cannot recover anymore.
  #--------------------------------------------------------------------------
  def item_test(user, item)
    tester = self.clone
    tester.make_obj_damage_value(user, item)
    tester.apply_state_changes(item)
    if tester.hp_damage < 0 or tester.calc_hp_recovery(user, item) > 0
      return true if tester.hp < tester.maxhp
    end
    if tester.mp_damage < 0 or tester.calc_mp_recovery(user, item) > 0
      return true if tester.mp < tester.maxmp
    end
    return true unless tester.added_states.empty?
    return true unless tester.removed_states.empty?
    return true if item.parameter_type > 0
    return false
  end
  #--------------------------------------------------------------------------
  # * Apply Item Effects
  #     user : Item user
  #     item : item
  #--------------------------------------------------------------------------
  def item_effect(user, item)
    clear_action_results
#    unless item_effective?(user, item)
#      @skipped = true
#      return
#    end
#    if rand(100) >= calc_hit(user, item)          # determine hit ratio
#      @missed = true
#      return
#    end
#    if rand(100) < calc_eva(user, item)           # determine evasion rate
#      @evaded = true
#      return
#    end
    hp_recovery = calc_hp_recovery(user, item)    # calc HP recovery amount
    mp_recovery = calc_mp_recovery(user, item)    # calc MP recovery amount
    make_obj_damage_value(user, item)             # damage calculation
    @hp_damage -= hp_recovery                     # subtract HP recovery amount
    @mp_damage -= mp_recovery                     # subtract MP recovery amount
    make_obj_absorb_effect(user, item)            # calculate absorption effect
    execute_damage(user)                          # damage reflection
    item_growth_effect(user, item)                # apply growth effect
    if item.physical_attack and @hp_damage == 0   # physical no damage?
      return                                    
    end
    apply_state_changes(item)                     # state change
  end
  #--------------------------------------------------------------------------
  # * Item Growth Effect Application
  #     user : Item user
  #     item : item
  #--------------------------------------------------------------------------
  def item_growth_effect(user, item)
    if item.parameter_type > 0 and item.parameter_points != 0
      case item.parameter_type
      when 1  # Maximum HP
        @maxhp_plus += item.parameter_points
      when 2  # Maximum MP
        @maxmp_plus += item.parameter_points
      when 3  # Attack
        @atk_plus += item.parameter_points
      when 4  # Defense
        @def_plus += item.parameter_points
      when 5  # Spirit
        @spi_plus += item.parameter_points
      when 6  # Agility
        @agi_plus += item.parameter_points
      end
    end
  end



end