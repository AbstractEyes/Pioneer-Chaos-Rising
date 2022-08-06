=begin
module PHI
  
  module HOTSPOT
    
    # Make sure these spots only run once per item that changes.
    # Only once, if it runs again after you fail to receive the item
    # it will automatically reroll if not ran only once.
    
    # ORES #  ORES #  ORES #  ORES #  ORES #  ORES #  ORES #  ORES #  ORES #
    # ORES #  ORES #  ORES #  ORES #  ORES #  ORES #  ORES #  ORES #  ORES #
    # ORES #  ORES #  ORES #  ORES #  ORES #  ORES #  ORES #  ORES #  ORES #
    # ORES #  ORES #  ORES #  ORES #  ORES #  ORES #  ORES #  ORES #  ORES # 
    def self.ore_spot(level = 1)
      random_value = rand(100)
      if level == 1
        case random_value 
        when 0...5
          return $data_items[101] # Iron Ore
        when 6...10
          return $data_items[184] # Sapphire
        when 10...40
          return $data_items[183] # Ore Cluster
        when 41...100
          return $data_items[100] # Copper Ore
        end
      elsif level == 10
        case random_value 
        when 0...5
          return $data_items[102] # Coal
        when 6...30
          return $data_items[184] # Sapphire
        when 31...100
          return $data_items[101] # Iron Ore
        end
      elsif level == 20
        case random_value 
        when 0...5
          return $data_items[103] # Mythril
        when 6...10
          return $data_items[185] # Emerald
        when 11...25
          return $data_items[184] # Sapphire
        when 26...50
          return $data_items[101] # Iron Ore
        when 51...100
          return $data_items[102] # Coal
        end
      elsif level == 30
        case random_value
        when 0...5
          return $data_items[104] # Nasyre
        when 6...30
          return $data_items[185] # Emerald
        when 31...100
          return $data_items[103] # Mythril
        end
      elsif level == 40
        case random_value
        when 0...5
          return $data_items[105] # Adamantium
        when 6...10
          return $data_items[186] # Ruby
        when 11...25
          return $data_items[185] # Emerald
        when 41...100
          return $data_items[104] # Nasyr
        end
      elsif level == 50
        case random_value 
        when 0...5
          return $data_items[106] # Ostarine
        when 6...30
          return $data_items[186] # Ruby
        when 31...100
          return $data_items[105] # Adamantium
        end
      elsif level == 60
        case random_value 
        when 0...5
          return $data_items[107] # Flamite
        when 6...10
          return $data_items[187] # Diamond
        when 11...25
          return $data_items[186] # Ruby
        when 41...100
          return $data_items[106] # Ostarine
        end
      elsif level == 70
        case random_value 
        when 0...5
          return $data_items[108] # Rasturite
        when 6...30
          return $data_items[187] # Diamond
        when 31...100
          return $data_items[107] # Flamite
        end
      elsif level == 80
        case random_value 
        when 0...5
          return $data_items[109] # Phoenixite
        when 6...10
          return $data_items[188] # Gem Cluster
        when 11...25
          return $data_items[187] # Diamond
        when 41...100
          return $data_items[108] # Rasturite
        end
      elsif level == 90
        case random_value 
        when 0...50
          return $data_items[188] # Gem cluster
        when 51...100
          return $data_items[109]  # Phoenixite
        end
      elsif level == 100
        case random_value 
        when 0...20
          return $data_items[188] # Gem cluster
        when 21...100
          return $data_items[109]  # Phoenixite
        end
      elsif level >= 101
        case random_value 
        when 0...20
          return $data_items[188] # Gem cluster
        when 21...100
          return $data_items[109]  # Phoenixite
        end
      end
    end
    # STONES # STONES # STONES # STONES # STONES # STONES # STONES # STONES
    # STONES # STONES # STONES # STONES # STONES # STONES # STONES # STONES
    # STONES # STONES # STONES # STONES # STONES # STONES # STONES # STONES
    # STONES # STONES # STONES # STONES # STONES # STONES # STONES # STONES
    def self.stone_spot(level = 1)
      random_value = rand(100)
      if level == 1
        case random_value 
        when 0...5
          return $data_items[184] # Sapphire
        when 6...40
          return $data_items[183] # Ore Cluster
        when 41...100
          return $data_items[161] # T1 Stone
        end
      elsif level == 10
        case random_value 
        when 0...5
          return $data_items[162] # T2 Stone
        when 6...25
          return $data_items[184] # Sapphire
        when 26...100
          return $data_items[161] # T1 Stone
        end
      elsif level == 20
        case random_value 
        when 0...5
          return $data_items[185] # Emerald
        when 6...25
          return $data_items[184] # Sapphire
        when 26...100
          return $data_items[162] # T2 Stone
        end
      elsif level == 30
        case random_value
        when 0...5
          return $data_items[163] # T3 Stone
        when 6...25
          return $data_items[185] # Emerald
        when 26...100
          return $data_items[162] # T2 Stone
        end
      elsif level == 40
        case random_value
        when 0...5
          return $data_items[186] # Ruby
        when 6...25
          return $data_items[185] # Emerald
        when 26...100
          return $data_items[163] # T3 Stone
        end
      elsif level == 50
        case random_value
        when 0...5
          return $data_items[164] # T4 Stone
        when 6...25
          return $data_items[186] # Ruby
        when 26...100
          return $data_items[163] # T3 Stone
        end
      elsif level == 60
        case random_value 
        when 0...5
          return $data_items[187] # Diamond
        when 6...25
          return $data_items[186] # Ruby
        when 26...100
          return $data_items[164] # T4 Stone
        end
      elsif level == 70
        case random_value 
        when 0...5
          return $data_items[165] # T5 Stone
        when 6...25
          return $data_items[187] # Diamond
        when 26...100
          return $data_items[164] # T4 Stone
        end
      elsif level == 80
        case random_value 
        when 0...5
          return $data_items[188] # Gem cluster
        when 6...25
          return $data_items[187] # Diamond
        when 51...100
          return $data_items[165] # T5 Stone
        end
      elsif level == 90
        case random_value 
        when 0...19
          return $data_items[188] # Gem cluster
        when 20...100
          return $data_items[165] # T5 Stone
        end
      elsif level == 100
        case random_value 
        when 0...49
          return $data_items[188] # Gem cluster
        when 50...100
          return $data_items[165] # T5 Stone
        end
      elsif level >= 101
        case random_value 
        when 0...49
          return $data_items[188] # Gem cluster
        when 50...100
          return $data_items[165] # T5 Stone
        end
      end
    end
    # TREES # TREES # TREES # TREES # TREES # TREES # TREES # TREES # TREES 
    # TREES # TREES # TREES # TREES # TREES # TREES # TREES # TREES # TREES 
    # TREES # TREES # TREES # TREES # TREES # TREES # TREES # TREES # TREES 
    # TREES # TREES # TREES # TREES # TREES # TREES # TREES # TREES # TREES 
    def self.tree_spot(level = 1)
      random_value = rand(100)
      if level == 1
        case random_value 
        when 0...5
          return $data_items[178] # Rare Herb
        when 6...40
          return $data_items[177] # Gold Herb
        when 41...100
          return $data_items[167] # T1 Wood
        end
      elsif level == 10
        case random_value 
        when 0...5
          return $data_items[168] # T2 Wood
        when 6...25
          return $data_items[178] # Rare Herb
        when 26...100
          return $data_items[167] # T1 Wood
        end
      elsif level == 20
        case random_value 
        when 0...5
          return $data_items[179] # Strange Seeds
        when 6...25
          return $data_items[178] # Rare Herb
        when 26...100
          return $data_items[168] # T2 Wood
        end
      elsif level == 30
        case random_value
        when 0...5
          return $data_items[169] # T3 Wood
        when 6...25
          return $data_items[179] # Strange Seeds
        when 26...100
          return $data_items[168] # T2 Wood
        end
      elsif level == 40
        case random_value
        when 0...5
          return $data_items[180] # Gold Seeds
        when 6...25
          return $data_items[179] # Strange Seeds
        when 26...100
          return $data_items[169] # T3 Wood
        end
      elsif level == 50
        case random_value
        when 0...5
          return $data_items[170] # T4 Wood
        when 6...25
          return $data_items[180] # Gold Seeds
        when 26...100
          return $data_items[169] # T3 Wood
        end
      elsif level == 60
        case random_value 
        when 0...5
          return $data_items[181] # Quality Roots
        when 6...25
          return $data_items[180] # Gold Seeds
        when 26...100
          return $data_items[170] # T4 Wood
        end
      elsif level == 70
        case random_value 
        when 0...5
          return $data_items[171] # T5 Wood
        when 6...25
          return $data_items[181] # Quality Roots
        when 26...100
          return $data_items[170] # T4 Wood
        end
      elsif level == 80
        case random_value 
        when 0...5
          return $data_items[182] # Birds Nest
        when 6...25
          return $data_items[181] # Quality Roots
        when 51...100
          return $data_items[171] # T5 Wood
        end
      elsif level == 90
        case random_value 
        when 0...19
          return $data_items[182] # Birds Nest
        when 20...100
          return $data_items[171] # T5 Wood
        end
      elsif level == 100
        case random_value 
        when 0...49
          return $data_items[182] # Birds Nest
        when 50...100
          return $data_items[171] # T5 Wood
        end
      elsif level >= 101
        case random_value 
        when 0...49
          return $data_items[182] # Birds Nest
        when 50...100
          return $data_items[171] # T5 Wood
        end
      end
    end
    # FISHING # FISHING # FISHING # FISHING # FISHING # FISHING # FISHING 
    # FISHING # FISHING # FISHING # FISHING # FISHING # FISHING # FISHING 
    # FISHING # FISHING # FISHING # FISHING # FISHING # FISHING # FISHING 
    # FISHING # FISHING # FISHING # FISHING # FISHING # FISHING # FISHING 
    def self.fish_spot(level = 1)
      random_value = rand(100)
      if level == 1
        case random_value 
        when 0...50
          return $data_items[61] # Small Squid
        when 51...100
          return $data_items[60] # Small Fish
        end
      elsif level == 10
        case random_value 
        when 0...50
          return $data_items[61] # Small Squid
        when 51...100
          return $data_items[60] # Small Fish
        end
      elsif level == 20
        case random_value 
        when 0...50
          return $data_items[63] # Medium Squid
        when 51...100
          return $data_items[62] # Medium Fish
        end
      elsif level == 30
        case random_value 
        when 0...50
          return $data_items[63] # Medium Squid
        when 51...100
          return $data_items[62] # Medium Fish
        end
      elsif level == 40
        case random_value 
        when 0...50
          return $data_items[65] # Large Squid
        when 51...100
          return $data_items[64] # Large Fish
        end
      elsif level == 50
        case random_value 
        when 0...50
          return $data_items[65] # Large Squid
        when 51...100
          return $data_items[64] # Large Fish
        end
      elsif level == 60
        case random_value 
        when 0...100
          return $data_items[66] # Small Shark
        end
      elsif level == 70
        case random_value 
        when 0...100
          return $data_items[66] # Small Shark
        end
      elsif level == 80
        case random_value 
        when 0...100
          return $data_items[67] # Large Shark
        end
      elsif level == 90
        case random_value 
        when 0...100
          return $data_items[67] # Large Shark
        end
      elsif level == 100
        case random_value 
        when 0...100
          return $data_items[67] # Large Shark
        end
      elsif level >= 101
        case random_value 
        when 0...100
          return $data_items[67] # Large Shark
        end
      end
    end
    
  end
  
end
=end