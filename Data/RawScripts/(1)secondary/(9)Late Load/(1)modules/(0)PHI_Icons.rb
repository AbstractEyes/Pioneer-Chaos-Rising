module PHI
  module ICONS
    def self.safe_icon(sym)
      return STATS[sym][0] if STATS.keys.include?(sym)
      return 1
    end

    def self.safe_color(sym, alpha=nil)
      if STATS.keys.include?(sym)
        color = STATS[sym][1]
        color.alpha = alpha if alpha != nil
        return color
      end
      return PHI.color(:WHITE)
    end
#PHI::ICONS::STATS[]
    STATS = {
        :lvl      => [0, PHI.color(:WHITE)],
        :raw      => [4,PHI.color(:GREY)],
        :hp       => [1745, PHI.color(:GREEN)],
        :mp       => [1781, PHI.color(:CYAN)],
        :sta      => [1794, PHI.color(:YELLOW)],
        :stamina  => [1794, PHI.color(:YELLOW)],
        :atb      => [1572, PHI.color(:YELLOW)],

        :atk      => [1207, PHI.color(:ORANGE)],
        :str      => [1207, PHI.color(:ORANGE)],
        :agi      => [1272, PHI.color(:YELLOW)],
        :spi      => [188, PHI.color(:DRKBLUE)],
        :int      => [188, PHI.color(:DRKBLUE)],
        :def      => [1143, PHI.color(:GOLD)],

        :res      => [1569, PHI.color(:WHITE)],
        :ares     => [1569, PHI.color(:WHITE)],
        :allres   => [1569, PHI.color(:WHITE)],
        :all_res  => [1569, PHI.color(:WHITE)],
        :pres     => [1137, PHI.color(:YELLOW)],
        :physres  => [1137, PHI.color(:YELLOW)],
        :phy_res_i=> [1137, PHI.color(:YELLOW)],

        :eres     => [1121, PHI.color(:YELLOW)],
        :eleres   => [1121, PHI.color(:YELLOW)],
        :ele_res  => [1121, PHI.color(:YELLOW)],
        :ele_dam  => [1121, PHI.color(:YELLOW)],
        :ele_res_i=> [1121, PHI.color(:YELLOW)],

        :sres     => [1880, PHI.color(:YELLOW)],
        :statusres=> [1880, PHI.color(:YELLOW)],
        :sta_res  => [1880, PHI.color(:YELLOW)],

        :cmul     => [1898, PHI.color(:YELLOW)],
        :critmult => [1898, PHI.color(:YELLOW)],
        :cri_mul  => [1898, PHI.color(:YELLOW)],

        :cri      => [1897, PHI.color(:YELLOW)],
        :crat     => [1897, PHI.color(:YELLOW)],
        :critrate => [1897, PHI.color(:YELLOW)],
        :ccha     => [1897, PHI.color(:YELLOW)],

        :slash        => [3, PHI.color(:WHITE)],
        :slash_dam    => [3, PHI.color(:WHITE)],
        :slash_res    => [3, PHI.color(:WHITE)],

        :crush        => [209, PHI.color(:WHITE)],
        :crush_dam    => [209, PHI.color(:WHITE)],
        :crush_res    => [209, PHI.color(:WHITE)],

        :puncture     => [129, PHI.color(:WHITE)],
        :puncture_dam => [129, PHI.color(:WHITE)],
        :puncture_res => [129, PHI.color(:WHITE)],

        :bullet       => [370, PHI.color(:WHITE)],
        :bullet_dam   => [370, PHI.color(:WHITE)],
        :bullet_res   => [370, PHI.color(:WHITE)],

        :energy       => [258, PHI.color(:WHITE)],
        :energy_dam   => [258, PHI.color(:WHITE)],
        :energy_res   => [258, PHI.color(:WHITE)],

        :blast        => [1676, PHI.color(:WHITE)],
        :blast_dam    => [1676, PHI.color(:WHITE)],
        :blast_res    => [1676, PHI.color(:WHITE)],


        :ember        => [1864, PHI.color(:RED)],
        :ember_dam    => [1864, PHI.color(:RED)],
        :ember_res    => [1864, PHI.color(:RED)],

        :brisk        => [1865, PHI.color(:BLUE)],
        :brisk_dam    => [1865, PHI.color(:BLUE)],
        :brisk_res    => [1865, PHI.color(:BLUE)],

        :bolt         => [1866, PHI.color(:YELLOW)],
        :bolt_dam     => [1866, PHI.color(:YELLOW)],
        :bolt_res     => [1866, PHI.color(:YELLOW)],

        :flood        => [1867, PHI.color(:CYAN)],
        :flood_dam    => [1867, PHI.color(:CYAN)],
        :flood_res    => [1867, PHI.color(:CYAN)],

        :stone        => [1868, PHI.color(:BROWN)],
        :stone_dam    => [1868, PHI.color(:BROWN)],
        :stone_res    => [1868, PHI.color(:BROWN)],

        :aer          => [1869, PHI.color(:GREEN)],
        :aer_dam      => [1869, PHI.color(:GREEN)],
        :aer_res      => [1869, PHI.color(:GREEN)],

        :light        => [1870, PHI.color(:WHITE)],
        :light_dam    => [1870, PHI.color(:WHITE)],
        :light_res    => [1870, PHI.color(:WHITE)],

        :shadow       => [1871, PHI.color(:BLACK)],
        :shadow_dam   => [1871, PHI.color(:BLACK)],
        :shadow_res   => [1871, PHI.color(:BLACK)],

        :chaos        => [1902, PHI.color(:PURPLE)],
        :chaos_dam    => [1902, PHI.color(:PURPLE)],
        :chaos_res    => [1902, PHI.color(:PURPLE)],

    }
    STAT_PRIORITY = {
        :lvl      => 0,
        :raw      => 0,
        :hp       => 1,
        :mp       => 2,
        :sta      => 3,
        :atb      => 4,

        :str      => 5,
        :atk      => 5,
        :agi      => 6,
        :int      => 7,
        :def      => 8,
        :pres     => 9,
        :physres  => 9,
        :eres     => 10,
        :eleres   => 10,
        :sres     => 11,
        :statusres=> 11,
        :crirate  => 12,
        :cri      => 12,
        :cmul     => 13,
        :crimul   => 13,

        :slash    => 14,
        :crush    => 15,
        :puncture => 16,
        :bullet   => 17,
        :energy   => 18,
        :blast    => 19,

        :ember    => 20,
        :brisk    => 21,
        :bolt     => 22,
        :flood    => 23,
        :stone    => 24,
        :aer      => 25,
        :light    => 26,
        :shadow   => 27,
        :chaos    => 28

    }

    EQUIPMENT_STAT_ORDER = [
        :hp       ,
        :mp       ,
        :sta      ,
        :str      ,
        :agi      ,
        :int      ,
        :crat     ,
        :cmul     ,
        :def      ,
        :ares     ,
        :pres     ,
        :eres     ,
        :sres
    ]

    EQUIPMENT_ELEMENT_ORDER = [
        :slash    ,
        :crush    ,
        :puncture ,
        :bullet   ,
        :energy   ,
        :blast    ,
        :ember    ,
        :brisk    ,
        :bolt     ,
        :flood    ,
        :stone    ,
        :aer      ,
        :light    ,
        :shadow   ,
        :chaos

    ]

    def self.get_element_icon(ele_id)
      STATS[SORTED_ELEMENTS[ele_id-1]][0]
    end

    def self.get_element_icon_int(ele_id)
      STATS[SORTED_ELEMENTS[ele_id]][0]
    end

    def self.get_element_color(ele_id)
      STATS[SORTED_ELEMENTS[ele_id-1]][1]
    end

    #PHI::ICONS.get_element_color(@ele_id)

    SORTED_ELEMENTS = {
        0   => :slash,
        1   => :crush,
        2   => :puncture,
        3   => :bullet,
        4   => :energy,
        5   => :blast,
        6   => :ember,
        7   => :brisk,
        8   => :bolt,
        9   => :flood,
        10  => :stone,
        11  => :aer,
        12  => :light,
        13  => :shadow,
        14  => :chaos
    }

    SORTED_ELEMENTS_ALL = [
        :slash       ,
        :slash_dam   ,
        :slash_res   ,
        :crush       ,
        :crush_dam   ,
        :crush_res   ,
        :puncture    ,
        :puncture_dam,
        :puncture_res,
        :bullet      ,
        :bullet_dam  ,
        :bullet_res  ,
        :energy      ,
        :energy_dam  ,
        :energy_res  ,
        :blast       ,
        :blast_dam   ,
        :blast_res   ,
        :ember       ,
        :ember_dam   ,
        :ember_res   ,
        :brisk       ,
        :brisk_dam   ,
        :brisk_res   ,
        :bolt        ,
        :bolt_dam    ,
        :bolt_res    ,
        :flood       ,
        :flood_dam   ,
        :flood_res   ,
        :stone       ,
        :stone_dam   ,
        :stone_res   ,
        :aer         ,
        :aer_dam     ,
        :aer_res     ,
        :light       ,
        :light_dam   ,
        :light_res   ,
        :shadow      ,
        :shadow_dam  ,
        :shadow_res  ,
        :chaos       ,
        :chaos_dam   ,
        :chaos_res   ,
    ]

    ELEMENT_LIST = {
        :slash    => 0,
        :crush    => 1,
        :puncture => 2,
        :bullet   => 3,
        :energy   => 4,
        :blast    => 5,

        :ember    => 6,
        :brisk    => 7,
        :bolt     => 8,
        :flood    => 9,
        :stone    => 10,
        :aer      => 11,
        :light    => 12,
        :shadow   => 13,
        :chaos    => 14
    }
    
    ELEMENT_LIST_ALL = {
        :slash        => 0 ,
        :slash_dam    => 0 ,
        :slash_res    => 0 ,
        :crush        => 1 ,
        :crush_dam    => 1 ,
        :crush_res    => 1 ,
        :puncture     => 2 ,
        :puncture_dam => 2 ,
        :puncture_res => 2 ,
        :bullet       => 3 ,
        :bullet_dam   => 3 ,
        :bullet_res   => 3 ,
        :energy       => 4 ,
        :energy_dam   => 4 ,
        :energy_res   => 4 ,
        :blast        => 5 ,
        :blast_dam    => 5 ,
        :blast_res    => 5 ,
        :ember        => 6 ,
        :ember_dam    => 6 ,
        :ember_res    => 6 ,
        :brisk        => 7 ,
        :brisk_dam    => 7 ,
        :brisk_res    => 7 ,
        :bolt         => 8 ,
        :bolt_dam     => 8 ,
        :bolt_res     => 8 ,
        :flood        => 9 ,
        :flood_dam    => 9 ,
        :flood_res    => 9 ,
        :stone        => 10 ,
        :stone_dam    => 10 ,
        :stone_res    => 10 ,
        :aer          => 11 ,
        :aer_dam      => 11 ,
        :aer_res      => 11 ,
        :light        => 12 ,
        :light_dam    => 12 ,
        :light_res    => 12 ,
        :shadow       => 13 ,
        :shadow_dam   => 13 ,
        :shadow_res   => 13 ,
        :chaos        => 14 ,
        :chaos_dam    => 14 ,
        :chaos_res    => 14 ,
    }
  end
end