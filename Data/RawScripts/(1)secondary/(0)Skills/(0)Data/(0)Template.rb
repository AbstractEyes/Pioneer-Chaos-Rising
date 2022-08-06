module PHI
  module SKILL_DATA
    SKILLS = {}
    SKILLS[:template] = {
       0   => {
             :always_active   => "false",
             :counter   => "false",
             :on_hit   => "false",
             :on_dodge   => "false",
             :interrupt   => "false",
             :can_be_interrupt   => "false",
             :type   => """",
             :unlocked   => "false",
             :name   => "Template",
             :desc   => """",
             :icon_id   => "5",
             :cast_message   => """",
             :cooldown_message   => """",
             :hit_message   => """",
             :kill_message   => """",
             :target   => "0",
             :residue   => "false",
             :ignore_resist   => "false",
             :chance   => "0",
             :no_damage   => "false",
             :damage_negates   => "false",
             :can_revive   => "false",
             :timed   => "false",
             :timer   => "0",
             :step   => "0",
             :turns   => "0",
             :spreads   => "0",
             :spread_range   => "0",
             :stacks   => "0",
             :returns   => "false",
             :startup   => "0",
             :cooldown   => "0",
             :offset   => "1",
             :size   => "[1,1]",
             :shape   => "0",
             :shove   => "[]",
             :self_shove   => "[]",
             :dam_attr   => "[]",
             :item_cost   => "[]",
             :hp_cost   => "[]",
             :mp_cost   => "[]",
             :sta_cost   => "[]",
             :atk_cost   => "[]",
             :int_cost   => "[]",
             :agi_cost   => "[]",
             :def_cost   => "[]",
             :res_cost   => "[]",
             :status_res_cost   => "[]",
             :ele_res_cost   => "[]",
             :phy_res_cost   => "[]",
             :cri_cost   => "[]",
             :cri_mul_cost   => "[]",
             :raw_dam   => "[]",
             :hp_dam   => "[]",
             :mp_dam   => "[]",
             :sta_dam   => "[]",
             :atk_dam   => "[]",
             :agi_dam   => "[]",
             :int_dam   => "[]",
             :def_dam   => "[]",
             :ele_dam   => "[]",
             :ele_res   => "[]",
             :cri_dam   => "[]",
             :cri_mul_dam   => "[]",
             :status_res_dam   => "[]",
             :res_dam   => "[]",
             :phy_res_dam   => "[]",
             :ele_res_dam   => "[]",
             :level   => "1",
             :lvl_rq   => "1",
             :max_lvl   => "10",
             :sequence   => "[]",
               :level_grid   =>  {
                 0   => [],
                 1   => [],
                 2   => [],
                 3   => [],
                 4   => [],
                 5   => [],
                 6   => [],
                 7   => [],
                 8   => [],
                 9   => [],
               },
             :animation_on_hit   => "0",
             :animation_on_use   => "0",
        },
    }
    def self.convert_type(str_in);return str_in unless str_in.is_a?(String);out_val = str_in;str_in.each_char do |char|;if char == '[';eval('out_val = ' + str_in);break;elsif char =~ /[0-9]/;out_val = str_in.to_i;break;elsif char =~ /[a-zA-Z]/;if str_in[0...5] == 'false' or str_in[0...4] == 'true';out_val = str_in.to_bool;break;else;out_val = str_in;break;end;end;end;return out_val;end;
    def self.clean_template;SKILLS[:template][0].each do |key, value|;next if value.is_a?(Array) or value.is_a?(Hash);SKILLS[:template][0][key] = convert_type(value);end;end;
    clean_template
    SKILLS[:destroyer] = {}
    SKILLS[:destroyer][:broadsword] = {}
    SKILLS[:destroyer][:great_hammer] = {}
    SKILLS[:destroyer][:heavy] = {}
    SKILLS[:tae_chi] = {}
    SKILLS[:tae_chi][:chakra_gloves] = {}
    SKILLS[:tae_chi][:jian] = {}
    SKILLS[:tae_chi][:gi] = {}
    SKILLS[:kung_fu] = {}
    SKILLS[:kung_fu][:weighted_staff] = {}
    SKILLS[:kung_fu][:iron_fists] = {}
    SKILLS[:kung_fu][:gi] = {}
    SKILLS[:paladin] = {}
    SKILLS[:paladin][:war_hammer] = {}
    SKILLS[:paladin][:sword_and_shield] = {}
    SKILLS[:paladin][:heavy] = {}
    SKILLS[:yin_elemental] = {}
    SKILLS[:yin_elemental][:book_of_prophecy] = {}
    SKILLS[:yin_elemental][:book_of_crepify] = {}
    SKILLS[:yin_elemental][:robe] = {}
    SKILLS[:yun_elemental] = {}
    SKILLS[:yun_elemental][:book_of_tranquility] = {}
    SKILLS[:yun_elemental][:book_of_empowerment] = {}
    SKILLS[:yun_elemental][:robe] = {}
    SKILLS[:cleric] = {}
    SKILLS[:cleric][:book_of_clarity] = {}
    SKILLS[:cleric][:book_of_durability] = {}
    SKILLS[:cleric][:robe] = {}
    SKILLS[:bowgunner] = {}
    SKILLS[:bowgunner][:bowgun] = {}
    SKILLS[:bowgunner][:tools] = {}
    SKILLS[:bowgunner][:leather] = {}
    SKILLS[:archer] = {}
    SKILLS[:archer][:long_bow] = {}
    SKILLS[:archer][:crossbow] = {}
    SKILLS[:archer][:leather] = {}
    SKILLS[:gunslinger] = {}
    SKILLS[:gunslinger][:pistols] = {}
    SKILLS[:gunslinger][:shotgun] = {}
    SKILLS[:gunslinger][:leather] = {}
    SKILLS[:scout] = {}
    SKILLS[:scout][:bolt_action_rifle] = {}
    SKILLS[:scout][:traps] = {}
    SKILLS[:scout][:leather] = {}
    SKILLS[:cannoneer] = {}
    SKILLS[:cannoneer][:blunderbuss] = {}
    SKILLS[:cannoneer][:hand_cannon] = {}
    SKILLS[:cannoneer][:heavy] = {}
    SKILLS[:summoner] = {}
    SKILLS[:summoner][:book_of_summon] = {}
    SKILLS[:summoner][:enchanted_stones] = {}
    SKILLS[:summoner][:heavy] = {}
    SKILLS[:wing_chun] = {}
    SKILLS[:wing_chun][:wrist_rings] = {}
    SKILLS[:wing_chun][:fan] = {}
    SKILLS[:wing_chun][:gi] = {}
    SKILLS[:ogre] = {}
    SKILLS[:ogre][:club] = {}
    SKILLS[:ogre][:head] = {}
    SKILLS[:ogre][:rags] = {}
    SKILLS[:wolf] = {}
    SKILLS[:wolf][:teeth] = {}
    SKILLS[:wolf][:claws] = {}
    SKILLS[:wolf][:pelt] = {}
    SKILLS[:tortoise] = {}
    SKILLS[:tortoise][:snapper] = {}
    SKILLS[:tortoise][:body] = {}
    SKILLS[:tortoise][:shell] = {}
    SKILLS[:skeleton] = {}
    SKILLS[:skeleton][:weapon41] = {}
    SKILLS[:elemental] = {}
    SKILLS[:elemental][:Shit] = {}
    SKILLS[:item] = {}
    SKILLS[:item][:Curative] = {}
    SKILLS[:item][:Destructive] = {}
    SKILLS[:item][:Ammos] = {}
  end
end
