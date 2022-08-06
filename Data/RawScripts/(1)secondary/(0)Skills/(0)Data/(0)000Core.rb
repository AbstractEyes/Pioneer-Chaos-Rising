#Generated 10/6/2019 3:58:10 PM version 2.0.0.0
module PHI
  module SKILL_DATA
    CLASS_TITLES = {
      1 => :destroyer,
      2 => :tae_chi,
      3 => :kung_fu,
      4 => :paladin,
      5 => :yin_elemental,
      6 => :yun_elemental,
      7 => :cleric,
      8 => :bowgunner,
      9 => :archer,
      10 => :gunslinger,
      11 => :scout,
      12 => :cannoneer,
      13 => :summoner,
      14 => :wing_chun,
      15 => :ogre,
      16 => :wolf,
      17 => :tortoise,
      18 => :skeleton,
      19 => :elemental,
      20 => :item,
    }
    CLASS_SKILL_TREES = {
      :destroyer => [:broadsword, :great_hammer, :heavy, ],
      :tae_chi => [:chakra_gloves, :jian, :gi, ],
      :kung_fu => [:weighted_staff, :iron_fists, :gi, ],
      :paladin => [:war_hammer, :sword_and_shield, :heavy, ],
      :yin_elemental => [:book_of_prophecy, :book_of_crepify, :robe, ],
      :yun_elemental => [:book_of_tranquility, :book_of_empowerment, :robe, ],
      :cleric => [:book_of_clarity, :book_of_durability, :robe, ],
      :bowgunner => [:bowgun, :tools, :leather, ],
      :archer => [:long_bow, :crossbow, :leather, ],
      :gunslinger => [:pistols, :shotgun, :leather, ],
      :scout => [:bolt_action_rifle, :traps, :leather, ],
      :cannoneer => [:blunderbuss, :hand_cannon, :heavy, ],
      :summoner => [:book_of_summon, :enchanted_stones, :heavy, ],
      :wing_chun => [:wrist_rings, :fan, :gi, ],
      :ogre => [:club, :head, :rags, ],
      :wolf => [:teeth, :claws, :pelt, ],
      :tortoise => [:snapper, :body, :shell, ],
      :skeleton => [:weapon41, ],
      :elemental => [:Shit, ],
      :item => [:Curative, :Destructive, :Ammos, ],
    }
    def self.get_weapons(id);return CLASS_SKILL_TREES[get_class(id)];end;def self.get_class(id);return CLASS_TITLES[id];end;
  end
end
