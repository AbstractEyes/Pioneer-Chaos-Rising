class Skill_Object
  attr_accessor :id
  attr_accessor :level
  attr_accessor :max_level
  attr_accessor :level_req
  attr_accessor :sp_req
  attr_accessor :unlocked

  def initialize(class_, weapon, id)
    @level = 1
    @class = class_
    @weapon = weapon
    @id = id
    @unlocked = unlocked_default
    @seq_pos = 0
  end
  # ---------------------------------------------------------------------------------------
  # Functions to figure out what the skill does.
  def type
    get(:type)
  end
  # ---------------------------------------------------------------------------------------
  # Requirement stuff.
  # ---------------------------------------------------------------------------------------
  # Gets the current level of the skill.
  def level
    return @level
  end
  def level=(lvl)
    @level = lvl
  end

  def max_level
    return get(:max_lvl)
  end

  def gain_level
    @level += 1
  end

  def reset_level
    @level = get(:level)
  end

  # Gets the level required of the character to learn the skill.
  def lvl_rq
    get(:lvl_rq)
  end

  # Gets the sp required in the pool of the character before learning this skill.
  def sp_rq
    get(:sp_rq)
  end

  # ---------------------------------------------------------------------------------------
  # Description stuff
  def name
    return get(:name)
  end

  def icon_index
    return get(:icon_id)
  end

  def icon_id
    return get(:icon_id)
  end

  def unlocked_default
    return get(:unlocked)
  end

  def description
    return get(:desc)
  end

  def cast_message
    return get(:cast_message)
  end

  def kill_message
    return get(:kill_message)
  end

  def hit_message
    return get(:hit_message)
  end

  def cooldown_message
    return get(:cooldown_message)
  end

  def dam_attr
    return get(:dam_attr)
  end

  def animation_id_target
    return get(:animation_on_hit)
  end

  def animation_id_host
    return get(:animation_on_use)
  end
  # ---------------------------------------------------------------------------------------
  # Target stuff
  # ---------------------------------------------------------------------------------------
  def target
    return get(:target)
  end

  def for_ally?
    return (target == 1)
  end

  def for_enemy?
    return (target == 0)
  end

  def for_any?
    return (target == 2)
  end

  def no_target?
    return (target == 3)
  end

  # ---------------------------------------------------------------------------------------
  # Buff Debuff stuff
  # ---------------------------------------------------------------------------------------
  #   Sticks to the target, if the sta_res check is passed, and this is set to true.
  #     Idea: permanent sticky attributes.  These do not stack with themselves.
  def residue?
    get(:residue)
  end

  #   Ignores resistance of the target if true, good for buffs.
  def ignores_resist?
    get(:ignore_resist)
  end

  #   The default percentage chance of effecting if the move hits the target.
  def inflict_chance
    get(:chance)
  end

  #   No attribute changes on the first usage, waits for step.
  def no_damage?
    get(:no_damage)
  end

  #   Disables the skill effects when damaged.
  def damage_negates?
    get(:damage_negates)
  end

  def can_revive?
    get(:can_revive)
  end

  #   The amount of seconds between each step.
  def timer
    get(:timer)
  end

  #   The amount of required steps before the state wears off.
  def steps
    get(:step)
  end

  #   If 0, only activates damage/trait one time.  If > 0, activate every matching step modulo.
  def turns
    get(:turns)
  end

  #   Spreads by touch: 0 = none, 1 = spreads to both, 2 = spreads to allies, 3 = spreads to enemies
  def spreads
    get(:spreads)
  end

  #   The touch range of the spread capability.
  def spread_range
    get(:spread_range)
  end

  #   If 1 or greater, can stack multiple buffs/debuffs on battlers.
  def stacks
    get(:stacks)
  end
  # ---------------------------------------------------------------------------------------

  # the amount of turns it costs to activate the move
  def startup
    get(:startup)
  end

  # the amount of turns it costs to restart your atb bar
  def cooldown
    get(:cooldown)
  end

  # The amount minimum of spaces between you and the target
  def offset
    get(:offset)
  end

  # The length/width of the attack shape.
  def size
    get(:size)
  end

  # The shape value itself, 0 means square.
  def shape
    get(:shape)
  end

  def shape_length
    shape[0]
  end

  def shape_width
    shape[1]
  end

  # [[sym, direction, spaces],...]
  # sym =
  # :relative
  # :absolute
  # :away_host
  # :away_target
  # :to_host
  # :toward_host
  # :toward_target
  # :to_target
  def shove
    return get(:shove) #prepare_movement(get(:shove))
  end
  def self_shove
    return get(:self_shove) #prepare_movement(get(:self_shove))
  end
=begin
  def prepare_movement(raw_movement)
    return [] if raw_movement.nil? or raw_movement.empty?
    return (raw_movement.map! do |s|
      case s[0]
        when :relative
          prepare_relative(s)
        when :absolute
          prepare_absolute(s)
        when :away
          prepare_away(s)
        when :toward
          prepare_toward(s)
      end
    end + MoveCommand.new(0))
  end
  def prepare_relative(s)

  end
  def prepare_absolute(s)
  end
  def prepare_away(s)
  end
  def prepare_toward(s)
  end
=end
  # ---------------------------------------------------------------------------------------
  # Returns the specified sequence.
  def sequence
    return replace_unneeded(get(:sequence))
  end
  def replace_unneeded(seq)
    return [[:hit, :animation, :wait, :damage, :shove, :wait]] if seq.nil? or seq.empty?
    return seq.map! {|s| s == :full ? [:hit, :animation, :wait, :damage, :shove, :wait] : s; }
  end
  # ---------------------------------------------------------------------------------------
  # ---------------------------------------------------------------------------------------
  # ---------------------------------------------------------------------------------------
  # ---------------------------------------------------------------------------------------
  def hp_cost
    return get(:hp_cost)
  end
  def mp_cost
    return get(:mp_cost)
  end
  def sta_cost
    return get(:sta_cost)
  end
  def atk_cost
    return get(:atk_cost)
  end
  def agi_cost
    return get(:agi_cost)
  end
  def int_cost
    return get(:int_cost)
  end
  def def_cost
    return get(:def_cost)
  end
  def item_cost
    return get(:item_cost)
  end
  def costs
    return {
        :hp => hp_cost,
        :mp => mp_cost,
        :sta => sta_cost,
        :str => atk_cost,
        :agi => agi_cost,
        :int => int_cost,
        :def => def_cost,
        :item => item_cost,
        :res => res_cost,
        :ele_res => ele_res_cost,
        :phy_res => phy_res_cost,
        :sta_res => status_res_cost,
        :cri => cri_cost,
        :cri_mul => cri_mul_cost,
    }
  end
  def costs_chopped
    return values_chopped(costs)
  end
  def get_ele_dam
    out = {}
    ele_dam.each { |arry|
      out[arry[2]] = [arry[0], arry[1]]
    }
    return out
  end
  def values_chopped(hash)
    out = {}
    hash.each {|key,value|
      out[key] = value unless value.empty?
    }
    return out
  end
  # ---------------------------------------------------------------------------------------
  # ---------------------------------------------------------------------------------------
  def raw_dam
    return get(:raw_dam)
  end

  def hp_dam
    return get(:hp_dam)
  end
  def mp_dam
    return get(:mp_dam)
  end
  def sta_dam
    return get(:sta_dam)
  end
  def atk_dam
    return get(:atk_dam)
  end
  def agi_dam
    return get(:agi_dam)
  end
  def int_dam
    return get(:int_dam)
  end
  def def_dam
    return get(:def_dam)
  end
  def damages
    return {
        :raw => raw_dam,
        :hp => hp_dam,
        :mp => mp_dam,
        :sta => sta_dam,
        :str => atk_dam,
        :agi => agi_dam,
        :int => int_dam,
        :def => def_dam,
        :cri => cri_dam,
        :cri_mul => cri_mul_dam,
        :res => res_dam,
        :sta_res => status_res_dam,
        :ele => ele_res_dam,
        :phy => phy_res_dam
    }
  end
  def damages_chopped
    return values_chopped(damages)
  end

  def ele_res
    return get(:ele_res)
  end
  def ele_dam
    return get(:ele_dam)
  end

  def res_dam
    return get(:res_dam)
  end
  def status_res_dam
    return get(:status_res_dam)
  end
  def ele_res_dam
    return get(:ele_res_dam)
  end
  def phy_res_dam
    return get(:phy_res_dam)
  end
  def cri_mul_dam
    return get(:cri_mul_dam)
  end
  def cri_dam
    return get(:cri_dam)
  end

  def res_cost
    return get(:res_cost)
  end
  def status_res_cost
    return get(:status_res_cost)
  end
  def ele_res_cost
    return get(:ele_res_cost)
  end
  def phy_res_cost
    return get(:phy_res_cost)
  end
  def cri_mul_cost
    return get(:cri_mul_cost)
  end
  def cri_cost
    return get(:cri_cost)
  end

  def get(sym)
    PHI::SKILL_DATA.bind(@class, @weapon, @id)
    out = PHI::SKILL_DATA.get(sym, @level)
    PHI::SKILL_DATA.unbind
    return out
  end

  def set(sym, value)
    PHI::SKILL_DATA.bind(@class, @weapon, @id)
    PHI::SKILL_DATA.set(sym, value)
    PHI::SKILL_DATA.unbind
  end

end

#$skill_test = Skill_Object.new(:destroyer, :broadsword, 0)

#p $skill_test.inspect