=begin
    SKILLS[:template] = {
        # Skills must be numbered here, to allow for sorting in the lists.
        0 => {
            :always_active      => false,                 #  If always active, provides attribute bonuses to character all the time.
                                                          #  If always active, and has buff attributes, uses buff attributes anyway.
                                                          #  Buff/Debuff attributes do not stack if :always_active is enabled.
                                                          #  Aura: Always active can still spread with timers, but will lose bonus when skill shape is left.
            #:details
            :type             => 0,                   #   0 = attack, 1 = buff/debuff, 2 = aura, 3 = mixed
            :unlocked         => true,                #  Unlocked by default or not.
            :name             => 'Template',
            :desc             => '',                  #  Single line skill text description.
            :icon_id          => 5,
            :cast_message     => '',
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

            #:structure
            :startup           => 0,              # the amount of turns it costs to activate the move
            :cooldown          => 0,              # the amount of turns it costs to restart your atb bar

            :offset            => 1,              # The amount minimum of spaces between you and the target
            :size              => [1, 1],         # The length/width of the attack shape.
            :shape             => 0,              # The shape value itself, 0 means square.

            :shove             => [], # [[sym, direction, spaces],...] sym = :relative, :absolute, :away, :toward

            # :damage_attr cannot be empty and must exist.
            # :costs are not required.
            # :damages are not required.
            # :ele_dam/:ele_res is not required
            #:attributes
            :dam_attr       => [[:atk, 33], [:agi, 33], [:int, 33]], # Base attribute calculations. Pre skill attrs.

            # Attribute tolls to cast a skill.
            # [[amt, pct=nil],...]
            :hp_cost            => [], # Skill activation costs.
            :mp_cost            => [], # Skill activation costs.
            :sta_cost           => [], # Skill activation costs.
            :atk_cost           => [], # Skill activation costs.
            :int_cost           => [], # Skill activation costs.
            :agi_cost           => [], # Skill activation costs.
            :def_cost           => [], # Skill activation costs.

            # Damage modifiers for the attack.
            # [[n, mod, pct, variance], ..., [1, '+'=nil, 100=nil, 20=nil]],
            :raw_dam            => [], # Skill damage based on primary attributes.
            :hp_dam             => [], # Skill damage directly to hp.
            :mp_dam             => [], # Skill damage directly to mp.
            :sta_dam            => [], # Skill damage directly to stamina.
            :atk_dam            => [], # Skill damage etc.
            :agi_dam            => [], # Skill damage.
            :int_dam            => [], # Skill damage.
            :def_dam            => [], # Skill damage.

            # Elemental damage, and variances from elemental damage.
            # [amount, modifier, percent, element_id=1, variance=0]
            :ele_dam            => [], # 0 Notifies there is no elemental damage.
            :ele_res            => [], # 0 Notifies there is no elemental resistence.

            # [[n, mod, pct, id], ..., [1, '+'=nil, 100=nil, 20=nil]],
            :status_res         => [], # Empty means there are no bonus status resistances.
            #:requirements
            :level            => 1, # Starting level of this skill.
            :lvl_rq           => 1, # Character level required to learn/use this skill.
            :sp_rq            => 0, # SP amount required to learn/use this skill.


           #sequence and level grid.

            :sequence          => [:full],        # The entire sequence used to determine the skill pattern.

            :level_grid       => {
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
module PHI
  module SKILL_DATA
    # ################################################################################################################ #
    # PRIMARY PREPARATION # ########################################################################################## #
    # ################################################################################################################ #
    SKILLS[:destroyer] = {}
    SKILLS[:destroyer][:spear] = {}
    # ################################################################################################################ #
    # Broadsword Skills ---------------------------------------------------------------------------------------------- #
    # ---------------------------------------------------------------------------------------------------------------- #
    # PREPARATION ---------------------------------------------------------------------------------------------------- #
    # ---------------------------------------------------------------------------------------------------------------- #
    SKILLS[:destroyer][:broadsword] = {}
    # ---------------------------------------------------------------------------------------------------------------- #
    # Slice ---------------------------------------------------------------------------------------------------------- #
    # ---------------------------------------------------------------------------------------------------------------- #
    SKILLS[:destroyer][:broadsword][0] = Hash.deep_clone(SKILLS[:template][0])
    bind(:destroyer, :broadsword, 0)
    # ---------------------------------------------------------------------------------------------------------------- #
    set(:type, 0)
    set(:target, 2)
    set(:unlocked, true)
    set(:name, 'Slice')
    set(:desc, 'A quick slice, to deal damage.')
    set(:icon_id, 25)
    set(:size, [1, 2])
    add(:dam_attr, [:atk, 100])
    #:shove             => [], # [[sym, direction, spaces],...] sym = :relative, :absolute, :away, :toward
    set(:shove, [:relative, :left, 2])
    add_levelup(:raw_dam, '+5%', 2)
    add_levelup(:raw_dam, '+5%', 3)
    add_levelup(:raw_dam, '+5%', 4)
    add_levelup(:raw_dam, '+5%', 5)
    # ---------------------------------------------------------------------------------------------------------------- #
    # Slice ---------------------------------------------------------------------------------------------------------- #
    # ---------------------------------------------------------------------------------------------------------------- #
    SKILLS[:destroyer][:broadsword][1] = Hash.deep_clone(SKILLS[:template][0])
    bind(:destroyer, :broadsword, 1)
    # ---------------------------------------------------------------------------------------------------------------- #
    SKILLS[:destroyer][:broadsword][2] = Hash.deep_clone(SKILLS[:template][0])
    bind(:destroyer, :broadsword, 2)
    # ---------------------------------------------------------------------------------------------------------------- #
    set(:type, 0)
    set(:type, 'Attack')
    set(:target, 2)
    set(:unlocked, true)
    set(:max_lvl, 1)
    set(:name, 'Test 1')
    set(:desc, 'A quick slice, to deal damage.')
    set(:icon_id, 35)
    set(:size, [1, 2])
    # ---------------------------------------------------------------------------------------------------------------- #
    SKILLS[:destroyer][:broadsword][3] = Hash.deep_clone(SKILLS[:template][0])
    bind(:destroyer, :broadsword, 3)
    # ---------------------------------------------------------------------------------------------------------------- #
    set(:type, 0)
    set(:target, 2)
    set(:name, 'Test 2')
    set(:desc, 'A quick slice, to deal damage.')
    set(:icon_id, 45)
    set(:size, [1, 2])
    # ---------------------------------------------------------------------------------------------------------------- #
    SKILLS[:destroyer][:broadsword][4] = Hash.deep_clone(SKILLS[:template][0])
    bind(:destroyer, :broadsword, 4)
    # ---------------------------------------------------------------------------------------------------------------- #
    set(:type, 0)
    set(:target, 2)
    set(:name, 'Test 3')
    set(:desc, 'A quick slice, to deal damage.')
    set(:icon_id, 55)
    set(:size, [1, 2])
    # ---------------------------------------------------------------------------------------------------------------- #
    SKILLS[:destroyer][:broadsword][5] = Hash.deep_clone(SKILLS[:template][0])
    bind(:destroyer, :broadsword, 5)
    # ---------------------------------------------------------------------------------------------------------------- #
    set(:type, 0)
    set(:target, 2)
    set(:name, '654654654sfdf')
    set(:desc, 'A quick slice, to deal damage.')
    set(:icon_id, 65)
    set(:size, [1, 2])
    # ---------------------------------------------------------------------------------------------------------------- #
    SKILLS[:destroyer][:broadsword][6] = Hash.deep_clone(SKILLS[:template][0])
    bind(:destroyer, :broadsword, 6)
    # ---------------------------------------------------------------------------------------------------------------- #
    set(:type, 0)
    set(:target, 2)
    set(:name, 'sdfasdfasdf')
    set(:desc, 'A quick slice, to deal damage.')
    set(:icon_id, 82)
    set(:size, [1, 2])
    # ---------------------------------------------------------------------------------------------------------------- #
    SKILLS[:destroyer][:broadsword][7] = Hash.deep_clone(SKILLS[:template][0])
    bind(:destroyer, :broadsword, 7)
    # ---------------------------------------------------------------------------------------------------------------- #
    set(:type, 0)
    set(:target, 2)
    set(:name, 'sdfasdfasdfsdfasdfasdfsdfasdfasdfsdfasdfasdf')
    set(:desc, 'A quick slice, to deal damage.')
    set(:icon_id, 86)
    set(:size, [1, 2])
    # ---------------------------------------------------------------------------------------------------------------- #
    SKILLS[:destroyer][:broadsword][8] = Hash.deep_clone(SKILLS[:template][0])
    bind(:destroyer, :broadsword, 8)
    # ---------------------------------------------------------------------------------------------------------------- #
    set(:type, 0)
    set(:target, 2)
    set(:name, 'sdfasdfasdfsdfasdfa33434')
    set(:desc, 'A quick slice, to deal damage.')
    set(:icon_id, 155)
    set(:size, [1, 2])
    # ---------------------------------------------------------------------------------------------------------------- #
    SKILLS[:destroyer][:broadsword][9] = Hash.deep_clone(SKILLS[:template][0])
    bind(:destroyer, :broadsword, 9)
    # ---------------------------------------------------------------------------------------------------------------- #
    set(:type, 0)
    set(:target, 2)
    set(:name, 'adfsdf33fefewvrverv')
    set(:desc, 'A quick slice, to deal damage.')
    set(:icon_id, 325)
    set(:size, [1, 2])
    # ---------------------------------------------------------------------------------------------------------------- #
    SKILLS[:destroyer][:broadsword][10] = Hash.deep_clone(SKILLS[:template][0])
    bind(:destroyer, :broadsword, 10)
    # ---------------------------------------------------------------------------------------------------------------- #
    set(:type, 0)
    set(:target, 2)
    set(:name, 'zxcvzxcvzxcv')
    set(:desc, 'A quick slice, to deal damage.')
    set(:icon_id, 325)
    set(:size, [1, 2])
    # ---------------------------------------------------------------------------------------------------------------- #
    SKILLS[:destroyer][:broadsword][11] = Hash.deep_clone(SKILLS[:template][0])
    bind(:destroyer, :broadsword, 11)
    # ---------------------------------------------------------------------------------------------------------------- #
    set(:type, 0)
    set(:target, 2)
    set(:name, 'qwerqwerqwer')
    set(:desc, 'A quick slice, to deal damage.')
    set(:icon_id, 954)
    set(:size, [1, 1])
    # ---------------------------------------------------------------------------------------------------------------- #
    SKILLS[:destroyer][:broadsword][12] = Hash.deep_clone(SKILLS[:template][0])
    bind(:destroyer, :broadsword, 12)
    # ---------------------------------------------------------------------------------------------------------------- #
    set(:type, 0)
    set(:target, 2)
    set(:name, 'kl;jl;kjl;kj;lkj')
    set(:desc, 'A quick slice, to deal damage.')
    set(:icon_id, 1231)
    set(:size, [1, 5])
    unbind

    SKILLS[:destroyer][:spear] = Hash.deep_clone(SKILLS[:destroyer][:broadsword])
    bind(:destroyer, :spear, 0)
    set(:name, 'testbelt2number1')
    set(:icon_id, 145)
    unbind
    bind(:destroyer, :spear, 1)
    set(:unlocked, true)
    set(:icon_id, 275)
    unbind
    SKILLS[:destroyer][:heavy] = Hash.deep_clone(SKILLS[:destroyer][:broadsword])
    bind(:destroyer, :heavy, 0)
    set(:name, 'heavyarmoryoloswag')
    set(:icon_id, 246)
    unbind

    p 'Size'
    p SKILLS[:destroyer][:broadsword].size


  end
=begin

=end

end