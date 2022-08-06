# --------------------------------------------------------------------------------------------- #
# Skill Containers #
# ---------------- #
# Any skill modifiers must be stored in this container.  Including skill levels and max levels.
# For any skill that is created, a template must be cloned and modifiers changed manually.
# --------------------------------------------------------------------------------------------- #
# DAMAGE SKILLS: Readable params; #
# ------------------------------- #
# :type                 => n_int
  #   0 = attack, 1 = buff/debuff, 2 = aura, 3 = mixed
  #   Doesn't affect the usage at all, just the displayed dialog when highlighted.
# :always_active        => bool
  #   If enabled, this skill is always active on the current player.  Damage becomes permanent changes to stats.
# -------------------------------------------------------------
# :unlocked             => bool
  #   Unlocked by default or not, true/false. Default false.
# -------------------------------------------------------------
# :name                 => string
  #   Skill name.
# :icon_id              => n_int
  #   Icon id.
# :desc                 => string
  #   The description displayed when the menu checks the skill.
# :ani                  => n_int
  #   The animation id to be used by default.
# -------------------------------------------------------------
# :cast_message         => string
  #   Displays a message when casting.
# -------------------------------------------------------------
# :offset               => n_int
  #   The required distance the user needs to be from the target to activate.
# -------------------------------------------------------------
# :size                 => [length_int, width_int]
  #   Length and width of the basic shape.
# -------------------------------------------------------------
# :shape                => n_int
  #   Unique shapes will be set via integer.  The size may or may not be used.
  #     Unknown shapes, not usable yet.
# -------------------------------------------------------------
# :startup              => n_float
  #   Multiplier to determine how much start up time this skill has.  0 = 0 atb timer counts, 1 = 1 atb timer counts
# :cooldown             => n_float
  #   Multiplier to determine how much cool down time AFTER the skill is cast.
# :shove                => [[type_sym, direction_sym, spaces], ...]
  #   sym = :relative, :absolute, :away, :toward
  #   Relative directions: Relative shove is the most common for skills
  #   Todo: Write algorithm to handle relative directions.
    #   :left, :right, :away, :towards
  #   Contains the shove direction, if the skill has a shove.
# -------------------------------------------------------------
# :target               => n_int
  #   0 = everything, 1 = allies only, 2 = enemies only
# -------------------------------------------------------------
# :sequence             => [[sym, val, val], ...[sym]]
=begin
  #   Contains a list of skill commands in the sequence.
  #     Levelup sequences overwrite the basic sequence.  Allowing for full sequence replacements.
    #     :full
    #        performs the standard 'ani', 'wait', 'damage', 'effect', 'wait' sequence.
    #     :use, n
    #        uses another skill template for the rest of the skill
    #        potentially infinite skills careful.
    #     :mult, n
    #        n = multiplier for the next damage use
    #        multiplies the damage of the next damage use by this percentage
    #     :ani, n
    #        n = animation_id
    #          If no id, <animation> uses the current animation attached to skill.
    #        bypasses the rest of the animations for this animation id
    #     :damage, n1, n2
    #        n1 = exact_damage
    #          If no exact damage specified, uses current skill to determine it.
    #        n2 = damage_type
    #          If no damage type determined, takes primary damage type of skill template.
    #        Performs damage, shows numbers, and calculates properly.
    #     :code, ["",...]
    #        "" = place code here, evaluates when sequence reaches this point, separate priority with ,""
    #     :add_ele_dam, n1, n2
    #        n1 = element type
    #        n2 = element damage
    #          Adds element damage to the next attack.
    #     :add_state_dam, n1, n2
    #        n1 = state type
    #        n2 = state damage
    #          Adds state damage to the next attack.
    #     :spawn, name, x, y, dummy_id=nil
    #        name      = entity name as string
    #        x         = x pos
    #        y         = y pos
    #        dummy_id  = event id to use as a dummy, automatically creates new if none provided.
    #          Spawns an entity at the target location.
=end
# -------------------------------------------------------------
# :lvl_req              => n
  #   The character level required to unlock in the skill tree.
# -------------------------------------------------------------
# :level                => n
  #   The starting level of the skill when added.
# :max_lvl              => n
  #   The max level of the skill.
# :level_grid           => {
=begin
    #   # Takes the primary level attributes, and adds new attributes to the list of attributes.
    #   level_number            => {
    #     :attribute    => value,
    #     :attribute2   => value2
    #   },
    #   level_number2           => {
    #     :attribute    => value,
    #     :attribute2   => value2
    #   }
    # }
      # ALL ATTRIBUTES HAVE THE :OVERWRITE SYM ENABLED AS FIRST CHECK.
      # :sym              => [:OVERWRITE, [...],...]
        # If present, this takes full priority over the original shape.

      # damage attributes 1:1 added to last
      # elemental attributes 1:1 added to last

      # :sequence         => [:OVERWRITE, []]
        # Completely overwrites the old sequence.
      # :sequence         => [[str, val], [str]]
        # Adds sequence nodes to the old sequence.
      # WORKS FOR ALL COMMANDS!
=end
# -------------------------------------------------------------
# :dam_attr             => [[attr, percentage], [attr, percentage]]
  #   The raw damage attributes:  :str, :agi, :int
  #   [[:str, 100]] = 100% str attribute.
  #   [[:str, 125], [:agi, 30]] = 125% str, 30% agi
  #   Percentage of your attribute to contribute to the damage pool.
# -------------------------------------------------------------
# :attr_dam                  => [['(+-)(n_int/n_float)(%)', variance],...]
=begin
  #     n = value
  #     mod = '+' / '-' / '*' / '\' / none, none = +
  #     pct = true/false/none, none = 1
  #     var = n, value of variance ex: 20 = 20% variance added, -20 = negated by at least 20%.
=end
# -------------------------------------------------------------
# :hp_cost                  => [n, pct]
  #     n = cost
  #     pct = true/false/nil percentage.
# :hp_dam                   => [['(+-)(n_int/n_float)(%)', variance],...]
=begin
  #     n = value
  #     mod = '+' / '-' / '*' / '\' / none, none = +
  #     pct = true/false/none, none = 1
  #     var = n, value of variance ex: 20 = 20% variance added, -20 = negated by at least 20%.
=end
# -------------------------------------------------------------
# :mp_cost                  => [n, pct]
# :mp_dam                   => [['(+-)(n_int/n_float)(%)', variance],...]
=begin
  #     n = value
  #     mod = '+' / '-' / '*' / '\' / none, none = +
  #     pct = true/false/none, none = 1
  #     var = n, value of variance ex: 20 = 20% variance added, -20 = negated by at least 20%.
=end
# -------------------------------------------------------------
# :sta_cost                 => [n, pct]
# :sta_dam                  => [['(+-)(n_int/n_float)(%)', variance],...]
=begin
  #     n = value
  #     mod = '+' / '-' / '*' / '\' / none, none = +
  #     pct = true/false/none, none = 1
  #     var = n, value of variance ex: 20 = 20% variance added, -20 = negated by at least 20%.
=end
# -------------------------------------------------------------
# :atk_cost                 => [n, pct]
# :atk                      => [['(+-)(n_int/n_float)(%)', variance],...]
=begin
  #     n = value
  #     mod = '+' / '-' / '*' / '\' / none, none = +
  #     pct = true/false/none, none = 1
  #     var = n, value of variance ex: 20 = 20% variance added, -20 = negated by at least 20%.
=end
# -------------------------------------------------------------
# :agi_cost                 => [n, pct]
# :agi                      => [['(+-)(n_int/n_float)(%)', variance],...]
=begin
  #     n = value
  #     mod = '+' / '-' / '*' / '\' / none, none = +
  #     pct = true/false/none, none = 1
  #     var = n, value of variance ex: 20 = 20% variance added, -20 = negated by at least 20%.
=end
# -------------------------------------------------------------
# :int_cost                 => [n, pct]
# :int                      => [['(+-)(n_int/n_float)(%)', variance],...]
=begin
  #     n = value
  #     mod = '+' / '-' / '*' / '\' / none, none = +
  #     pct = true/false/none, none = 100
  #     var = n, value of variance ex: 20 = 20% variance added, -20 = negated by at least 20%.
=end
# -------------------------------------------------------------
# :def_cost                 => [n, pct]
# :def                      => [['(+-)(n_int/n_float)(%)', variance],...]
=begin
  #     n = value
  #     mod = '+' / '-' / '*' / '\' / none, none = +
  #     pct = true/false/none, none = 100
  #     var = n, value of variance ex: 20 = 20% variance added, -20 = negated by at least 20%.
=end
# -------------------------------------------------------------
# :ele_dam                  => [['(+-)(n_int/n_float)(%)', variance, id], ..., ['+25%', 2, 3]]
# :ele_res                  => [['+35%', 2], ..., ['', id]]
# -------------------------------------------------------------
# :sta_res                  => [n, mod, id]...
  #     id = state id
  #     ignores = true/false ignores resistance
# -------------------------------------------------------------
# BUFFS SPECIFIC
# -------------------------------------------------------------
# :ignore_resist            => bool
  #   Completely ignores target's state resistance, useful for buffs.
# :no_damage                => bool
  #   Doesn't provide boost on the first turn, waits one turn.
# :residue                  => bool
  #   Lingers on target.
# :timed                    => bool
  #   Determines if the step is used.
# :timer                    => n_int
  #   The amount of seconds between each step.
# :turns                    => n_int
  #   If 0, only activates damage/trait one time.  If > 0, activate every matching step modulo.
  #   Does not charge the costs again.
# :step                     => n_int
  #   The amount of required steps before the state wears off.
# :spreads                  => n_int
  #   Spreads by touch: 1 = spreads to both, 2 = spreads to allies, 3 = spreads to enemies
# :spread_range             => n_int
  #   The touch range of the spread capability.
# :stacks                   => n_int
  #   If 1 or greater, can stack multiple buffs/debuffs on battlers.
# :chance                   => n_int
  #   If 0, no chance of buff/debuff.  If > 0, sub odds of usage from resistance, unless ignore_resist is enabled.
# -------------------------------------------------------------------------------------------- #
# STATE SKILLS: Readable params; #
# ------------------------------ #
# Structure cheat sheet:
# SKILLS[:class] = {
#   :weapon => {
#     :details      => {...},
#     :buff         => {...},
#     :activation   => {
#       :structure      => {..., :sequence={...}, ...},
#       :attributes     => {...},
#     },
#     :requirements => {...},
#     :level_grid   => {...}
#   }
# }

module PHI
  module SKILL_DATA
    #PHI::SKILL_DATA::CLASS_SKILL_TREES
    #CLASS_SKILL_TREES = {}

    @class_sym = nil
    @weapon = nil
    @id = nil
=begin
    SKILLS = {}
    SKILLS[:template] = {
        # Skills must be numbered here, to allow for sorting in the lists.
        0 => {
            # +5 points
            :always_active      => false,                 #  If always active, provides attribute bonuses to character all the time.
                                                          #  If always active, and has buff attributes, uses buff attributes anyway.
                                                          #  Buff/Debuff attributes do not stack if :always_active is enabled.
                                                          #  Aura: Always active can still spread with timers, but will lose bonus when skill shape is left.
            :counter            => false,             # Determines if this can be used to counter.
            :on_hit             => false,             # Performs effects on hit.
            :on_dodge           => false,             # Performs effects on dodge.
            :interrupt          => false,             # Can interrupt the startup of skill, causing the atb timer to reset.
            :can_be_interrupt   => false,             # Moves can interrupt the startup of this move.

            #:details
            :type             => '',                  # String containing the type of skill.
            :unlocked         => false,                #  Unlocked by default or not.
            :name             => 'Template',
            :desc             => '',                  #  Single line skill text description.
            :icon_id          => 5,
            :cast_message     => '',
            :animation_on_cast=> 1,
            :animation_on_hit => 1,
            :target           => 0,                   #  -1 = self, 0 = everything, 1 = allies only, 2 = enemies only, 3 = group only(ally if used on ally, enemy if used on enemy)

            #:buff
            :residue          => false,               #   Sticks to the target, if the sta_res check is passed, and this is set to true.
                                                      #     Idea: permanent sticky attributes.  These do not stack with themselves.
            :ignore_resist    => false,               #   Ignores resistance of the target if true, good for buffs.
            :chance           => 0,                   #   The default percentage chance of effecting if the move hits the target.
            :no_damage        => false,               #   No attribute changes on the first usage, waits for step.
            :damage_negates   => false,               #   Disables the skill when damaged.
            :timed            => false,               #   If timed, uses the traits below.
            :timer            => 0,                   #   The amount of seconds between each step.
            :step             => 0,                   #   The amount of required steps before the state wears off.
            :turns            => 0,                   #   If 0, only activates damage/trait one time.  If > 0, activate every matching step modulo.
            :spreads          => 0,                   #   Spreads by touch: 1 = spreads to both, 2 = spreads to allies, 3 = spreads to enemies
            :spread_range     => 0,                   #   The touch range of the spread capability.
            :stacks           => 0,                   #   If 1 or greater, can stack multiple buffs/debuffs on battlers.
            :returns          => false,               #   If true, can return the trait to the original user. Otherwise cannot.

            #:structure
            :startup           => 0,              # the amount of turns it costs to activate the move
            :cooldown          => 0,              # the amount of turns it costs to restart your atb bar

            :offset            => 1,              # The amount minimum of spaces between you and the target
            :size              => '',             # The length/width of the attack shape.
            :shape             => 0,              # The shape value itself, 0 means square.

            # Relative:
            # 2 = relative left, 4 = relative right
            :shove             => '', # [[sym, direction, spaces],...] sym = :relative, :absolute, :away, :toward
            :self_shove        => '', # Shove used on self.

            # :costs are not required.
            # :damages are not required.
            # :ele_dam/:ele_res is not required
            #:attributes
            :dam_attr       => '',#[:atk, 33], [:agi, 33], [:int, 33]], # Base attribute calculations. Pre skill attrs.

            # Attribute tolls to cast a skill.
            # [['amt(%)'],...]
            :hp_cost            => '', # Skill activation costs.
            :mp_cost            => '', # Skill activation costs.
            :sta_cost           => '', # Skill activation costs.
            :atk_cost           => '', # Skill activation costs.
            :int_cost           => '', # Skill activation costs.
            :agi_cost           => '', # Skill activation costs.
            :def_cost           => '', # Skill activation costs.

            # Damage modifiers for the attack.
            # [['(+-)(n_int/n_float)(%)', variance], ..., ['+25%', 10]]
            :raw_dam            => '', # Skill damage based on primary attributes.
            :hp_dam             => '', # Skill damage directly to hp.
            :mp_dam             => '', # Skill damage directly to mp.
            :sta_dam            => '', # Skill damage directly to stamina.
            :atk_dam            => '', # Skill damage etc.
            :agi_dam            => '', # Skill damage.
            :int_dam            => '', # Skill damage.
            :def_dam            => '', # Skill damage.

            # Elemental damage, and variances from elemental damage.
            # [ ['(+-)(n_int/n_float)(%)', variance, element_id], ... ]
            :ele_dam            => '', # 0 Notifies there is no elemental damage.
            :ele_res            => '', # 0 Notifies there is no elemental resistence.

            # [['(+-)(n_int/n_float)(%)', variance], ..., ['+25%', 2]]
            :status_res         => '', # Empty means there are no bonus status resistances.

            #:requirements
            :level            => 1, # Starting level of this skill.
            :lvl_rq           => 1, # Character level required to learn/use this skill.
            :max_lvl          => 10,

            #sequence and level grid.
            :sequence          => [:full],        # The entire sequence used to determine the skill pattern.

            :level_grid       => {
                0             => {},
                1             => {},
                2             => {},
                3             => {},
                4             => {},
                5             => {},
                6             => {},
                7             => {},
                8             => {},
                9             => {},
                10            => {}
            }
        },
    }
=end
    def self.bind(class_sym, weapon_sym, skill_id)
      @class_sym = class_sym
      @weapon = weapon_sym
      @id = skill_id
    end

    def self.unbind
      @class_sym = nil
      @weapon = nil
      @id = nil
    end

    def self.set(sym, value)
      p @class_sym.inspect + ' ' + @weapon.inspect + ' ' + @id.inspect + ' ' + sym.inspect + value.inspect
      out_val = convert_type(value)
      p sym.inspect + ' ' + value.inspect + ' ' + out_val.inspect if sym == :desc
      SKILLS[@class_sym][@weapon][@id][sym] = out_val
    end

    def self.convert_type(str_in)
      return str_in unless str_in.is_a?(String)
      out_val = str_in
      str_in.each_char do |char|
        if char == '['
          eval('out_val = ' + str_in)
          break
        elsif char =~ /[0-9]/
          out_val = str_in.to_i
          break
        elsif char =~ /[a-zA-Z]/
          if str_in[0...5] == 'false' or str_in[0...4] == 'true'
            out_val = str_in.to_bool
            break
          else
            out_val = str_in
            break
          end
        end
      end
      return out_val
    end

    def self.add(sym, value)
      return SKILLS[@class_sym][@weapon][@id][sym].push value if SKILLS[@class][@weapon][@id][sym].is_a?(Array)
      return SKILLS[@class_sym][@weapon][@id][sym] += value if SKILLS[@class][@weapon][@id][sym].is_a?(Integer)
      p('Failed to add properly to the skill list.')
    end

    def self.add_levelup(sym, value, level)
      unless SKILLS[@class_sym][@weapon][@id][:level_grid][level].keys.include?(sym)
        SKILLS[@class_sym][@weapon][@id][:level_grid][level][sym] = []
      end
      SKILLS[@class_sym][@weapon][@id][:level_grid][level][sym].push value
    end

    def self.add_levelup_raw(level, raw_string)
      levelup_grid = []
      eval('levelup_grid = ' + raw_string)
      for grid_level in levelup_grid
        p grid_level.inspect
        SKILLS[@class_sym][@weapon][@id][:level_grid][level].push grid_level
      end
      Hash.pump(SKILLS)
    end

    def self.no_keys?(sym)
      return !SKILLS.keys.include?(@class_sym) ||
          !SKILLS[@class_sym].keys.include?(@weapon) ||
          !SKILLS[@class_sym][@weapon].keys.include?(@id) ||
          !SKILLS[@class_sym][@weapon][@id].keys.include?(sym)
    end

    def self.levelups(sym, level)
      val = SKILLS[@class_sym][@weapon][@id][sym]
      #p sym.inspect + ' ' + val.inspect
      val = val.clone if val.is_a?(Array) || val.is_a?(Hash)
      return val if level == 1
      SKILLS[@class_sym][@weapon][@id][:level_grid].each_pair do |list_lvl, value|
        p level.to_s + ' ' + list_lvl.to_s
        next unless level >= list_lvl
        next unless value.keys.empty?
        next unless value.keys.include?(sym)
        #Todo: add more functionality for the value, as the levelup scheme has changed.
        #Create combine_similar method
        val += value
      end
      return val
    end

    def self.get_base(sym)
      return self.get(sym, 1)
    end

    def self.get(sym, level=1)
      if @class_sym.nil? || @id.nil? || @weapon.nil? || self.no_keys?(sym)
        Hash.pump(SKILLS)
        p 'Failed to find symbol. ' + @class_sym.to_s + ' ' + @id.to_s + ' ' + @weapon.to_s
        return
      end
      return levelups(sym, level)
    end

    #def self.clean_template
    #  SKILLS[:template][0].each do |key, value|
    #    next if value.is_a?(Array) or value.is_a?(Hash)
    #    SKILLS[:template][0][key] = convert_type(value)
    #  end
    #end

    #clean_template if self.methods.include?('SKILLS') && SKILLS.keys.include?(:template)

  end
end