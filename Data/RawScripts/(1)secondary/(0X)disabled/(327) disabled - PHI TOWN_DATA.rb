module PHI
  module TOWN_DATA
    
    # Town's default maximum width and height
    TOWN_MAX_WIDTH = 9
    TOWN_MAX_HEIGHT = 9
    
    # Town's default building positions
    SAFEHOUSE_POSITION_X = 4
    SAFEHOUSE_POSITION_Y = 4
    TOWN_EXIT_X = 4
    TOWN_EXIT_Y = 2
    BASE_SHOP_X = 5
    BASE_SHOP_Y = 4
    DUNGEON_CRYSTAL_X = 4
    DUNGEON_CRYSTAL_Y = 5
    WORKSHOP_X = 3
    WORKSHOP_Y = 4
    
    # Default icon ids for some areas
    UNKNOWN = 1570
    
    # Level Limitations
    TIER_1 = 20
    TIER_2 = 40
    TIER_3 = 60
        
  end
  
  module AREA_DATA
    
    # at most 80 characters per line
    DESCRIPTIONS = {
      # Town Center
      0 => [["This building is very important for the day to day workings of the town."],
            ["Build and upgrade buildings, hire workers, builders, and more here."],],
      # Safehouse
      1 => [["This is where you spend the night, and you need to be refreshed if"],
            ["you plan to actually be useful to your town."],],
      # Workshop      
      2 => [["This is where you will build and craft almost all of your equipment,"],
            ["items, accessories, and other needed parts for the town and your party."],],
      # Coin Market      
      3 => [["This marketplace only trades the coins currency, because the market"],
            ["is full of imported goods from other towns and cities."],],
      # Resource Market
      4 => [["This is our own market, we buy and sell this currency only to our immediate"],
            ["town.  This currency is important for the entire town to function."],],
      # Road
      5 => [["This is a quick transit from one area to another, and you can also use"],
            ["them to replace old buildings you don't need anymore."],],
      # Unknown Land
      6 => [["This land is completely unknown unexplored land.  This land can be cleared"],
            ["if the land is touching a building or a road, for resources and items."],],
      # Airship Dock
      7 => [["We store our town's airships here. We use airships to travel to other nearby"],
            ["areas in search of resources to help feed and fuel the town."],],
      # Bank
      8 => [["This building is very important for the day to day workings of the town."],
            ["Build and upgrade buildings, hire workers, builders, and more here."],],
      # Dungeon Lord
      9 => [["The master of the dungeon crystals, permitted to send us to the "],
            ["Chaos Realm, if we pay him, and only if we pay him."],],
      # Farmland
     10 => [["Farming plots are useful for consumable item income, these provide"],
            ["multiple different kinds of items after upgrades."],],
      # Mining Shaft
     11 => [["Your builders dug a hole, now workers are digging out and sifting ores"],
            ["from the ore ridden ground below our town.  "],],
      # Fishing Hole
     12 => [["Water runs into the hole from an underground river, and fish come from"],
            ["upstream.  They don't seem to notice the difference."],],
      # Empty Plot
     13 => [["This land is ready for a building to built."],
            [""],],
      # Hunting Camp
     14 => [["This is the camp where your item generating hunters stay when they are"],
            ["preparing for a hunt, or sleeping off a hunt."],],
      # Casino
     15 => [["Feel like unwinding, or gambling away your earnings?  Look no further!"],
            ["We have an array of games, and you can bring in better forms of them."],],
      # Trade Station
     16 => [["You give us your items, we give you other items.  Don't like it? Use"],
            ["the recycler."],],
      # Artifact Museum
     17 => [["This is where you come to identify and store artifacts.  Depending"],
            ["on the artifact type, you may be able to carry it around with you."],],
      # Arcane Tower
     17 => [["Never can be too sure what these old coots will do."],
            [""],],
     
      }
      
      
    TOWN_AREA_UPGRADES = {
      # "Area Name"   => {
      #   "Sub Area Name"       => ["Required Area", array ID, PL Req, Cycles, 
      #                              desc_id,recipe]
      # }
        "Empty Plot"  => { # Empty start
            "Empty"   => ["None",0,0,0,0,0],
          }, # Empty Close
        "Road" => {
            "Empty"   => ["None",0,0,0,0,0],
          },#"Road", ]
        "Unknown Land" => {
            "Empty"   => ["None",0,0,0,0,0],
          },#"Unknown Land", ]
          
        "Pioneer House"  => { # Safehouse Start
            "Memo List"   => ["None",0,0,0,0,0],
            "Storage Box"  => ["None",1,0,0,0,0],
            "Character Lodging 1"   => ["None",2,0,0,0,0],
            "Character Lodging 2"   => ["None",3,0,0,0,0],
            "Character Lodging 3"   => ["Character Lodging 2",4,20,0,0,0],
            "Character Lodging 4"   => ["Character Lodging 3",5,30,0,0,0],
            "Character Lodging 5"   => ["Character Lodging 4",6,40,0,0,0],
            
        }, # Safehouse Close
        
        "Workshop"  => { # Workshop Open
            "Workbench 1"       => ["None",0,0,0,0,0],
            "Workbench 2"       => ["Workbench 1",1,20,2,0,0],
            "Workbench 3"       => ["Workbench 2",2,40,4,0,0],
            "Workbench 4"       => ["Workbench 3",3,60,4,0,0],
            "Workbench 5"       => ["Workbench 4",4,80,4,0,0],
            "Anvil 1"           => ["None",6,5,0,0,0],
            "Anvil 2"           => ["Anvil 1",6,20,4,0,0],
            "Anvil 3"           => ["Anvil 2",7,40,4,0,0],
            "Anvil 4"           => ["Anvil 3",8,60,4,0,0],
            "Anvil 5"           => ["Anvil 4",9,80,4,0,0],
            "Alchemy Station 1" => ["None",10,0,0,0,0],
            "Alchemy Station 2" => ["Alchemy Station 1",11,20,4,0,0],
            "Alchemy Station 3" => ["Alchemy Station 2",12,40,4,0,0],
            "Alchemy Station 4" => ["Alchemy Station 3",13,60,4,0,0],
            "Alchemy Station 5" => ["Alchemy Station 4",14,80,4,0,0],
          },#"Workshop Close        
        
        "Coin Market"  => { # Market Open
            "Weapon Stock 1"       => ["None",0,0,0,0,0],
            "Weapon Stock 2"       => ["Weapon Stock 1",1,20,4,0,0],
            "Weapon Stock 3"       => ["Weapon Stock 2",2,40,4,0,0],
            "Weapon Stock 4"       => ["Weapon Stock 3",3,60,4,0,0],
            "Weapon Stock 5"       => ["Weapon Stock 4",4,80,4,0,0],
            "Armor Stock 1"        => ["None",4,0,0,0,0],
            "Armor Stock 2"        => ["Armor Stock 1",6,20,4,0,0],
            "Armor Stock 3"        => ["Armor Stock 2",7,40,4,0,0],
            "Armor Stock 4"        => ["Armor Stock 3",8,60,4,0,0],
            "Armor Stock 5"        => ["Armor Stock 4",9,80,4,0,0],
            "Materials Stock 1"    => ["None",10,0,4,0,0],
            "Materials Stock 2"    => ["Materials Stock 1",11,20,4,0,0],
            "Materials Stock 3"    => ["Materials Stock 2",12,40,4,0,0],
            "Materials Stock 4"    => ["Materials Stock 3",13,60,4,0,0],
            "Materials Stock 5"    => ["Materials Stock 4",14,80,4,0,0],
            "Consumable Stock 1"    => ["None",15,0,4,0,0],
            "Consumable Stock 2"    => ["Consumable Stock 1",16,20,4,0,0],
            "Consumable Stock 3"    => ["Consumable Stock 2",17,40,4,0,0],

          },# Market Close
        
        "Resource Market"  => { # Resource Market Open
            "Guru Stage 1"    => ["None",0,0,0,0,0],
            "Guru Stage 2"    => ["Guru Stage 1",1,20,2,0,0],
            "Guru Stage 3"    => ["Guru Stage 2",2,40,4,0,0],
            "Guru Stage 4"    => ["Guru Stage 3",3,60,8,0,0],
            "Guru Stage 5"    => ["Guru Stage 4",4,80,10,0,0],
            "Farmer Stand 1"  => ["None",5,0,0,0,0],
            "Farmer Stand 2"  => ["Farmer Stand 1",6,20,2,0,0],
            "Farmer Stand 3"  => ["Farmer Stand 2",7,40,4,0,0],
            "Farmer Stand 4"  => ["Farmer Stand 3",8,60,4,0,0],
            "Farmer Stand 5"  => ["Farmer Stand 4",9,80,4,0,0],
            "Fishers Stall 1" => ["None",10,0,0,0,0],
            "Fishers Stall 2" => ["Fisher Stall 1",11,20,2,0,0],
            "Fishers Stall 3" => ["Fisher Stall 2",12,40,4,0,0],
            "Fishers Stall 4" => ["Fisher Stall 3",13,60,4,0,0],
            "Fishers Stall 5" => ["Fisher Stall 4",14,80,4,0,0],
            "Ore Merchant 1"  => ["None",15,0,0,0,0],
            "Ore Merchant 2"  => ["Ore Merchant 1",16,20,2,0,0],
            "Ore Merchant 3"  => ["Ore Merchant 2",17,40,4,0,0],
            "Ore Merchant 4"  => ["Ore Merchant 2",18,60,4,0,0],
            "Ore Merchant 5"  => ["Ore Merchant 2",19,80,4,0,0],
            "Hunter Racks 1"  => ["None",20,0,0,0,0],
            "Hunter Racks 2"  => ["Hunter Racks 1",21,20,2,0,0],
            "Hunter Racks 3"  => ["Hunter Racks 2",22,40,4,0,0],
            "Hunter Racks 4"  => ["Hunter Racks 2",23,60,4,0,0],
            "Hunter Racks 5"  => ["Hunter Racks 2",24,80,4,0,0],
          }, # Resource Market Close
        
        "Bank"  => {
            "Inventory Upgrade 1"   => ["None",0,0,0,0,0],
            "Inventory Upgrade 2"   => ["Inventory Upgrade 1",1, 5, 2,0,0],
            "Inventory Upgrade 3"   => ["Inventory Upgrade 2",2, 10,2,0,0],
            "Inventory Upgrade 4"   => ["Inventory Upgrade 3",3, 15,4,0,0],
            "Inventory Upgrade 5"   => ["Inventory Upgrade 4",4, 20,4,0,0],
            "Inventory Upgrade 6"   => ["Inventory Upgrade 5",5, 25,6,0,0],
            "Inventory Upgrade 7"   => ["Inventory Upgrade 6",6, 30,6,0,0],
            "Inventory Upgrade 8"   => ["Inventory Upgrade 7",7, 35,8,0,0],
            "Inventory Upgrade 9"   => ["Inventory Upgrade 8",8, 40,8,0,0],
            "Inventory Upgrade 10"  => ["Inventory Upgrade 9",9, 45,10,0,0],
            "Coin Income 1"         => ["None",10,2,0,0,0],
            "Coin Income 2"         => ["Coin Income 1",11,10,4,0,0],
            "Coin Income 3"         => ["Coin Income 2",12,20,6,0,0],
            "Coin Income 4"         => ["Coin Income 3",13,30,8,0,0],
            "Coin Income 5"         => ["Coin Income 4",14,40,10,0,0],
            "Coin Income 6"         => ["Coin Income 5",15,50,12,0,0],
            "Coin Income 7"         => ["Coin Income 6",16,60,14,0,0],
            "Coin Income 8"         => ["Coin Income 7",17,70,16,0,0],
            "Coin Income 9"         => ["Coin Income 8",18,80,18,0,0],
            "Coin Income 10"        => ["Coin Income 9",19,90,20,0,0],
            "Coin Income S"         => ["Coin Income 10",20,100,25,0,0],
          },#"Bank"]
        
        "Town Center"  => {
            "Builder Quarters 1"   => ["None",0,0,0,0,0],
            "Builder Quarters 2"   => ["Builder Quarters 1",1,20,4,0,0],
            "Builder Quarters 3"   => ["Builder Quarters 2",2,40,8,0,0],
            "Builder Quarters 4"   => ["Builder Quarters 3",3,60,12,0,0],
            "Farmer Quarters 1"   => ["None",4,0,0,0,0],
            "Farmer Quarters 2"   => ["Farmer Quarters 1",5,20,4,0,0],
            "Farmer Quarters 3"   => ["Farmer Quarters 2",6,40,10,0,0],
            "Farmer Quarters 4"   => ["Farmer Quarters 3",7,60,10,0,0],
            "Fisher Quarters 1"    => ["None",8,0,0,0,0],
            "Fisher Quarters 2"    => ["Fishers Quarters 1",9,20,4,0,0],
            "Fisher Quarters 3"    => ["Fishers Quarters 2",10,40,10,0,0],
            "Fisher Quarters 4"    => ["Fishers Quarters 3",11,60,10,0,0],
            "Miner Quarters 1"    => ["None",12,0,0,0,0],
            "Miner Quarters 2"    => ["Miners Quarters 1",13,20,4,0,0],
            "Miner Quarters 3"    => ["Miners Quarters 2",14,40,10,0,0],
            "Miner Quarters 4"    => ["Miners Quarters 3",15,60,10,0,0],
            "Hunter Quarters 1"    => ["None",16,0,0,0,0],
            "Hunter Quarters 2"    => ["Hunter Quarters 1",17,20,4,0,0],
            "Hunter Quarters 3"    => ["Hunter Quarters 2",18,40,10,0,0],
            "Hunter Quarters 4"    => ["Hunter Quarters 3",19,60,10,0,0],
            "Trader Quarters 1"   => ["None",20,0,0,0,0],
            "Trader Quarters 2"   => ["Trader Quarters 1",21,20,4,0,0],
            "Trader Quarters 3"   => ["Trader Quarters 2",22,40,10,0,0],
            "Trader Quarters 4"   => ["Trader Quarters 3",23,60,10,0,0],
          },#"Town Center", ]
        
        "Dungeon Lord"  => {
            "Cost Decrease 1"    => ["None",0,0,0,0,0],
            "Cost Decrease 2"    => ["Cost Decrease 1",1,20,0,0,0],
            "Cost Decrease 3"    => ["Cost Decrease 2",2,40,0,0,0],
            "Cost Decrease 4"    => ["Cost Decrease 3",3,60,0,0,0],
            "Cost Decrease 5"    => ["Cost Decrease 4",4,80,0,0,0],
            "Level 1 Crystal"   => ["None",5,0,0,0,0],
            "Level 10 Crystal"  => ["None",6,0,0,0,0],
            "Level 20 Crystal"  => ["Level 10 Crystal",7,18,  5,0,0],
            "Level 30 Crystal"  => ["Level 20 Crystal",8,28,  5,0,0],
            "Level 40 Crystal"  => ["Level 30 Crystal",9,38,  5,0,0],
            "Level 50 Crystal"  => ["Level 40 Crystal",10,48, 5,0,0],
            "Level 60 Crystal"  => ["Level 50 Crystal",11,58, 5,0,0],
            "Level 70 Crystal"  => ["Level 60 Crystal",12,68, 5,0,0],
            "Level 80 Crystal"  => ["Level 70 Crystal",13,78, 5,0,0],
            "Level 90 Crystal"  => ["Level 80 Crystal",14,88, 5,0,0],
            "Level 100 Crystal" => ["Level 90 Crystal",15,100,5,0,0],
          },#"Dungeon Lord", ]
        
        "Farmland" => {
            "Herb Patch 1"      => ["None",0,0,0,0,0],
            "Herb Patch 2"      => ["Herb Patch 1",1,5,0,0,0],
            "Herb Patch 3"      => ["Herb Patch 2",2,20,0,0,0],
            "Herb Patch 4"      => ["Herb Patch 3",3,40,0,0,0],
            "Herb Patch 5"      => ["Herb Patch 4",4,60,0,0,0],
            "Mushroom Box 1"   => ["None",5,0,0,0,0],
            "Mushroom Box 2"   => ["Mushroom Box 1",6,5,0,0,0],
            "Mushroom Box 3"   => ["Mushroom Box 2",7,10,0,0,0],
            "Mushroom Box 4"   => ["Mushroom Box 3",8,10,0,0,0],
            "Mushroom Box 5"   => ["Mushroom Box 4",9,10,0,0,0],
            "Carrot Plot 1"     => ["Herb Patch 3",10,15,0,0,0],
            "Carrot Plot 2"     => ["Carrot Plot 1",11,20,0,0,0],
            "Carrot Plot 3"     => ["Carrot Plot 2",12,25,0,0,0],
            "Bee Box 1"        => ["Mushroom Box 3",13,15,0,0,0],
            "Bee Box 2"        => ["Bee Box 1",14,20,0,0,0],
            "Bee Box 3"        => ["Bee Box 2",15,25,0,0,0],
            "Fertile Land 1"    => ["None",16,30,0,0,0],
            "Fertile Land 2"    => ["Fertile Land 2",17,35,0,0,0],
            "Fertile Land 3"    => ["Fertile Land 3",18,40,0,0,0],
            "Wood Chopping 1"  => ["None",19,0,0,0,0],
            "Wood Chopping 2"  => ["Wood Chopping 1",20,20,0,0,0],
            "Wood Chopping 3"  => ["Wood Chopping 2",21,40,0,0,0],
            "Wood Chopping 4"  => ["Wood Chopping 3",22,60,0,0,0],
            "Wood Chopping 5"  => ["Wood Chopping 4",23,80,0,0,0],
          },#"Farmland", ]
        
        "Mining Shaft"  => {
            "Dig Further 1"    => ["None",            0,0,0,0,0],
            "Dig Further 2"    => ["Dig Further 1",   1,1,2,0,0],
            "Dig Further 3"    => ["Dig Further 2",   2,10,2,0,0],
            "Dig Further 4"    => ["Dig Further 3",   3,20,3,0,0],
            "Dig Further 5"    => ["Dig Further 4",   4,30,3,0,0],
            "Dig Further 6"    => ["Dig Further 5",   5,40,4,0,0],
            "Dig Further 7"    => ["Dig Further 6",   6,50,4,0,0],
            "Dig Further 8"    => ["Dig Further 7",   7,60,5,0,0],
            "Dig Further 9"    => ["Dig Further 8",   8,70,5,0,0],
            "Dig Further 10"   => ["Dig Further 9",   9,80,10,0,0],
            "Minecarts 1"     => ["None",            10,20,2,0,0],
            "Minecarts 2"     => ["Minecarts 1",     11,40,5,0,0],
            "Minecarts 3"     => ["Minecarts 2",     12,60,10,0,0],
            "Mining Torches 1" => ["None",            13,20,2,0,0],
            "Mining Torches 2" => ["Mining Torches 1",14,40,5,0,0],
            "Mining Torches 3" => ["Mining Torches 2",15,60,10,0,0],
            "Safety Lines 1"  => ["None",            16,20,2,0,0],
            "Safety Lines 2"  => ["Safety Lines 1",  17,40,5,0,0],
            "Safety Lines 3"  => ["Safety Lines 2",  18,60,10,0,0],
            "Stone Quarry 1"    => ["None",             19,0,0,0,0],
            "Stone Quarry 2"    => ["Stone Quarry 1",   20,20,2,0,0],
            "Stone Quarry 3"    => ["Stone Quarry 2",   21,40,3,0,0],
            "Stone Quarry 4"    => ["Stone Quarry 3",   22,60,4,0,0],
            "Stone Quarry 5"    => ["Stone Quarry 4",   23,80,5,0,0],
            
          }, #"Mining Shaft", ]
        
        "Fishing Hole"  => {
            "Divert River 1"    => ["None",           0,0,0,0,0],
            "Divert River 2"    => ["Divert River 1", 1,10,0,0,0],
            "Divert River 3"    => ["Divert River 2", 2,20,0,0,0],
            "Divert River 4"    => ["Divert River 3", 3,30,0,0,0],
            "Divert River 5"    => ["Divert River 4", 4,40,0,0,0],
            "Divert River 6"    => ["Divert River 5", 5,50,0,0,0],
            "Divert River 6"    => ["Divert River 5", 6,60,0,0,0],
            "Divert River 6"    => ["Divert River 5", 7,70,0,0,0],
            "Divert River 6"    => ["Divert River 5", 8,80,0,0,0],
            "Divert River 6"    => ["Divert River 5", 9,90,0,0,0],
            "Divert River 6"    => ["Divert River 5", 10,100,0,0,0],
            "Widen Pool 1"     => ["None",           11,20,0,0,0],
            "Widen Pool 2"     => ["Widen Pool 1",   12,40,0,0,0],
            "Widen Pool 3"     => ["Widen Pool 2",   13,60,0,0,0],
            "Tackle 1"          => ["None",           14,10,0,0,0],
            "Tackle 2"          => ["Tackle 1",       15,20,0,0,0],
            "Tackle 3"          => ["Tackle 2",       16,40,0,0,0],
            "Boat Nets 1"      => ["None",           17,20,0,0,0],
            "Boat Nets 2"      => ["Boat Nets 1",    18,40,0,0,0],
            "Boat Nets 3"      => ["Boat Nets 3",    19,60,0,0,0],
            "Fishing Lines 1"   => ["None",           20,20,0,0,0],
            "Fishing Lines 2"   => ["Fishing Lines 1",21,40,0,0,0],
            "Fishing Lines 3"   => ["Fishing Lines 2",22,60,0,0,0],
          },#"Fishing Hole", ]
        
        "Hunting Camp" => {
            "Potions 1"      => ["None",0,0,0,0,0],
            "Potions 2"      => ["Potions 1",1,20,0,0,0],
            "Potions 3"      => ["Potions 2",2,40,0,0,0],
            "Potions 4"      => ["Potions 3",3,60,0,0,0],
            "Potions 5"      => ["Potions 4",4,80,0,0,0],
            "Tactics 1"       => ["None",5,0,0,0,0],
            "Tactics 2"       => ["Tactics 1",6,20,0,0,0],
            "Tactics 3"       => ["Tactics 2",7,40,0,0,0],
            "Tactics 4"       => ["Tactics 3",8,60,0,0,0],
            "Tactics 5"       => ["Tactics 4",9,80,0,0,0],
            "Weapons 1"      => ["None",10,0,0,0,0],
            "Weapons 2"      => ["Weapons 1",11,20,0,0,0],
            "Weapons 3"      => ["Weapons 2",12,40,0,0,0],
            "Weapons 4"      => ["Weapons 3",13,60,0,0,0],
            "Weapons 5"      => ["Weapons 4",14,80,0,0,0],
            "Armor 1"         => ["None",15,0,0,0,0],
            "Armor 2"         => ["Armor 1",16,20,0,0,0],
            "Armor 3"         => ["Armor 2",17,40,0,0,0],
            "Armor 4"         => ["Armor 3",18,40,0,0,0],
            "Armor 5"         => ["Armor 4",19,40,0,0,0],
            "Accessories 1"  => ["None",20,0,0,0,0],
            "Accessories 2"  => ["Accessories 1",21,20,0,0,0],
            "Accessories 3"  => ["Accessories 2",22,40,0,0,0],
            "Accessories 4"  => ["Accessories 3",23,40,0,0,0],
            "Accessories 5"  => ["Accessories 4",24,40,0,0,0],
          },#"Hunting Camp", ]
          
        "Airship Dock" => {
            "Protected Coast"    => ["None",              0,0,  0, 0, 0],
            "Lakefront"          => ["Protected Coast",   1,8,  4, 0, 0],
            "Oceanside"          => ["Lakefront",         2,18, 4, 0, 0],
            "Marsh Inlet"        => ["Oceanside",         3,28, 4, 0, 0],
            "Mountainside Woods" => ["Marsh Inlet",       4,38, 6, 0, 0],
            "Natural Cave"       => ["Mountainside Woods",5,48, 6, 0, 0],
            "Volcanic Chasm"     => ["Natural Cave",      6,58, 6, 0, 0],
            "Chaos Realm"        => ["Volcanic Chasm",    7,68, 8, 0, 0],
            "Dimensional Pocket" => ["Chaos Realm",       8,78, 8, 0, 0],
            "Sapphire Ruins"     => ["Dimensional Pocket",9,88, 8, 0, 0],
            "Abandoned Skyship"  => ["Sapphire Ruins",   10,98, 8, 0, 0],
          },#"Airship Dock", ]
        "Casino" => {
            "Slot Machines 1"   => ["None",0,0,0,0,],
            "Slot Machines 2"   => ["Slot Machines 1",1,0,0,0,],
            "Slot Machines 3"   => ["Slot Machines 2",2,0,0,0,],
            "Slot Machines 4"   => ["Slot Machines 3",3,0,0,0,],
            "Slot Machines 5"   => ["Slot Machines 4",4,0,0,0,],
            "Slot Machines 6"   => ["Slot Machines 5",5,0,0,0,],
            "Slot Machines 7"   => ["Slot Machines 6",6,0,0,0,],
            "Slot Machines 8"   => ["Slot Machines 7",7,0,0,0,],
            "Slot Machines 9"   => ["Slot Machines 8",8,0,0,0,],
            "Slot Machines 10"  => ["Slot Machines 9",9,0,0,0,],
            "Slot Machines S"   => ["Slot Machines 10",10,0,0,0],
            "Blackjack 1"    => ["None",11,0,0,0,0],
            "Blackjack 2"    => ["None",12,0,0,0,0],
            "Blackjack 3"    => ["None",13,0,0,0,0],
            "Blackjack 4"    => ["None",14,0,0,0,0],
            "Blackjack 5"    => ["None",15,0,0,0,0],
            "Blackjack 6"    => ["None",16,0,0,0,0],
            "Blackjack 7"    => ["None",17,0,0,0,0],
            "Blackjack 8"    => ["None",18,0,0,0,0],
            "Blackjack 9"    => ["None",19,0,0,0,0],
            "Blackjack 10"   => ["None",20,0,0,0,0],
            "Blackjack S"    => ["None",21,0,0,0,0],
            "Lucky Wheel 1"   => ["None",22,0,0,0,0],
            "Lucky Wheel 2"   => ["None",23,0,0,0,0],
            "Lucky Wheel 3"   => ["None",24,0,0,0,0],
            "Lucky Wheel 4"   => ["None",25,0,0,0,0],
            "Lucky Wheel 5"   => ["None",26,0,0,0,0],
            "Turtle Racing 1"  => ["None",27,0,0,0,0],
            "Turtle Racing 2"  => ["None",28,0,0,0,0],
            "Turtle Racing 3"  => ["None",29,0,0,0,0],
            "Turtle Racing 4"  => ["None",30,0,0,0,0],
            "Turtle Racing 5"  => ["None",31,0,0,0,0],
            "Item Gambling 1"   => ["None",32,0,4,0,0],
            "Item Gambling 2"   => ["Item Gambling 1",33,20,6,0,0],
            "Item Gambling 3"   => ["Item Gambling 2",34,40,8,0,0],
            "Item Gambling 4"   => ["Item Gambling 3",35,60,10,0,0],
            "Item Gambling 5"   => ["Item Gambling 4",36,80,12,0,0],
            },#"Casino", ]
        "Trade Station" => {
            "Item Trade 1"     => ["None",0,0,0,0,0],
            "Item Trade 2"     => ["None",1,0,0,0,0],
            "Item Trade 3"     => ["None",2,0,0,0,0],
            "Item Trade 4"     => ["None",3,0,0,0,0],
            "Item Trade 5"     => ["None",4,0,0,0,0],
            "Gear Trade 1"     => ["None",5,0,0,0,0],
            "Gear Trade 2"     => ["None",6,0,0,0,0],
            "Gear Trade 3"     => ["None",7,0,0,0,0],
            "Gear Trade 4"     => ["None",8,0,0,0,0],
            "Gear Trade 5"     => ["None",9,0,0,0,0],
            "Resource Trade 1"  => ["None",10,0,0,0,0],
            "Resource Trade 2"  => ["None",11,0,0,0,0],
            "Resource Trade 3"  => ["None",12,0,0,0,0],
            "Resource Trade 4"  => ["None",13,0,0,0,0],
            "Resource Trade 5"  => ["None",14,0,0,0,0],
          },#"Trade Station", ]
        "Artifact Museum" => {
            "Artifact Space 1"    => ["None",                0,0,0,0,0],
            "Artifact Space 2"    => ["Artifact Space 1",    1,20,4,0,0],
            "Artifact Space 3"    => ["Artifact Space 2",    2,40,4,0,0],
            "Artifact Space 4"    => ["Artifact Space 3",    3,60,4,0,0],
            "Artifact Space 5"    => ["Artifact Space 4",    4,80,4,0,0],
            "Examine Equipment 1"  => ["None",               5,0,0,0,0],
            "Examine Equipment 2"  => ["Examine Equipment 1",6,20,8,0,0],
            "Examine Equipment 3"  => ["Examine Equipment 2",7,40,8,0,0],
            "Examine Equipment 4"  => ["Examine Equipment 3",8,60,8,0,0],
            "Examine Equipment 5"  => ["Examine Equipment 4",9,80,8,0,0],
            "Recycler 1"          => ["None",               10,0,0,0,0],
            "Recycler 2"          => ["Recycler 1",         11,40,10,0,0],
            "Recycler 3"          => ["Recycler 2",         12,80,10,0,0],
          },#"Artifact Museum", ]
        "Arcane Tower" => {
            "Powerbox"        => ["None",  0,0,0,0,0],
            "Exp Grinder"     => ["None",  1,0,0,0,0],
            "Randombox"       => ["None",  2,0,0,0,0],
            "Stat Books 1"     => ["None",          3,20, 10,0,0],
            "Stat Books 2"     => ["Stat Books 1",  4,40, 10,0,0],
            "Stat Books 3"     => ["Stat Books 2",  5,60, 10,0,0],
            "Stat Books 4"     => ["Stat Books 3",  6,80, 10,0,0],
            "Stat Books 5"     => ["Stat Books 4",  7,100,10,0,0],
          },#"Artifact Museum", ]
    }

    # -------------- #
    # Town Area List #
    # ---------------------------------------------------- #
    # Contains all the data for the individual town areas. #
    # ---------------------------------------------------- #
    TOWN_AREA_DATA = {
      #  => ["Name",item_icon,duplicate_areas,cycles,
            # description_id, recipe_id,[sub_areas],[job]],
      #       0         1   2 3 4 5 6 7       
      #  => ["Diggery", 100,0,4,5,4,0,[0,3,6,9,11],
      "Empty Plot"      => ["Empty Plot",      1574,0,0,13,0, 
            ["Empty",],["None"],0,0,
            ], # Close Empty Plot Data
      "Pioneer House"   => ["Pioneer House",       1598,1,5,1,1,    
            ["Empty",],["None"],1,0,
            ], # Close Safehouse Data
      "Workshop"        => ["Workshop",        1647,1,5,2,2,    
            ["Anvil 1",
             "Workbench 1",
             "Alchemy Station 1",],["None"],2,0,
            ],# Close Workshop Data
      "Coin Market"     => ["Coin Market",     1630,1,5,3,3,    
            ["Weapon Stock 1",
            "Armor Stock 1",
            "Accessories Stock 1"],["None"],3,1,
            ],
      "Resource Market" => ["Resource Market", 1631,1,5,4,4,    
            ["Guru Stage 1",
            "Farmer Stand 1",
            "Fisher Stall 1",
            "Ore Merchant 1",
            "Hunter Racks 1"],["None"],4,2,
            ],
      "Bank"            => ["Bank",            1666,1,5,8,5,    
            ["Inventory Upgrade 1",
            "Coin Income 1"],["None"],5,1,
            ],
      "Town Center"     => ["Town Center",     1613,1,5,0,6,    
            ["Builder Quarters 1",
             "Farmer Quarters 1",
             "Miner Quarters 1",
             "Fisher Quarters 1",
             "Hunter Quarters 1",],["None"],6,0,
            ],
      "Dungeon Lord"    => ["Dungeon Lord",    1941,1,5,9,7,    
            ["Level 1 Crystal",],["None"],7,0,
            ],
      "Farmland"        => ["Farmland",        1601,8,5,10,8,    
            ["Empty"],["None"],8,0,
            ],
      "Mining Shaft"    => ["Mining Shaft",    1663,8,5,11,9,    
            ["Empty"],["None"],9,0,
            ],
      "Fishing Hole"    => ["Fishing Hole",    1605,8,5,12,10,   
            ["Empty"],["None"],10,0,
            ],
      "Hunting Camp"    => ["Hunting Camp",     133,8,5,14,11,   
            ["Empty"],["None"],11,0,
            ],
      "Airship Dock"    => ["Airship Dock",    1915,1,5,7,12,   
            ["Protected Coast"],["None"],12,0,
            ],
      "Road"            => ["Road",            1635,0,2,5,13,
            ["Empty"],["None"],13,0,
            ],
      "Unknown Land"    => ["Unknown Land",    1570,0,0,6,14,
            ["Empty"],["None"],14,0,
            ],
      "Casino"          => ["Casino",           134,1,5,15,15,
            ["Empty"],["None"],15,0,
            ],
      "Trade Station"   => ["Trade Station",    135,1,5,16,16,
            ["Empty"],["None"],16,0,
            ],
      "Artifact Museum" => ["Artifact Museum",  136,1,5,17,17,
            ["Empty"],["None"],17,0,
            ],
      "Arcane Tower"    => ["Arcane Tower",     136,1,5,18,18,
            ["Empty"],["None"],18,0,
            ],
#~       "Bacon" => ["",    137,0,0,6,18,
#~             ["Empty"],["None"],18
#~             ],
      # @town_areas[area_id][position]
      #0 Name as string
      #1 Icon_id as integer
      #2 Consecutive areas as integer
      #3 Cycles to construct as integer
      #4 Description id as integer
      #5 Recipe ID as integer
      #6 Stored Area ids for  as Array
        # [area_id as string]
      #7 currently active job
        #0 "Worker Name", #1 Cycles, #2 "Sub Area Name", #3 
      
    } # Close 
      
  end
  
  class AREA
    def initialize(area_id)
      areas = PHI::AREA_DATA::TOWN_AREA_DATA
      area = areas[area_id]
      @area_id = area_id
      @sort_id = area[8]
      @name = ""
      @name = area[0] if !area.nil?
      @icon_id = 1
      @icon_id = area[1] if !area.nil?
      @possible_areas = 0
      @possible_areas = area[2] if !area.nil?
      @cycle_req = 0
      @cycle_req = area[3] if !area.nil?
      @cycle = 0
      @description_id = 0
      @description_id = area[4] if !area.nil?
      @recipe_id = 0
      @recipe_id = area[9] if !area.nil?
      @upgrades = []
      upgrade_data = PHI::AREA_DATA::TOWN_AREA_UPGRADES
      upgrade_array = PHI::AREA_DATA::TOWN_AREA_UPGRADES[@name]
      upgrade_key_array = upgrade_array.keys
      if !upgrade_key_array.include?("Empty")
        for i in 0...upgrade_key_array.size
          @upgrades.push AREA_UPGRADE.new(upgrade_key_array[i],upgrade_array[upgrade_key_array[i]])
        end
        @upgrades.sort! {|x,y| x.upgrade_id <=> y.upgrade_id}
      end
      @active = false
      @active_job = nil
      @worker = nil
    end
    attr_accessor :area_id
    attr_accessor :sort_id
    attr_accessor :name
    attr_accessor :icon_id
    attr_accessor :possible_areas
    attr_accessor :cycle_req
    attr_accessor :cycle
    attr_accessor :description_id
    attr_accessor :recipe_id
    attr_accessor :upgrades
    attr_accessor :active
    attr_accessor :active_job
    attr_accessor :worker
  end
  
  class AREA_UPGRADE
    def initialize(upgrade_name,upgrade_array)
      @name = upgrade_name
      @icon_id = 1
      if @name != "Empty"
        @upgrade_id = upgrade_array[1]
        @area_required = upgrade_array[0]
        @pl_required = upgrade_array[2]
        @cycle_req = upgrade_array[3]
        @recipe_id = upgrade_array[4]
        @description_id = upgrade_array[5]
        @completed = false
        @completed = true if @pl_required == 0
        @built_by = "Default"
        @builder_data = nil
      else
        @upgrade_id = 0
        @area_required = "Empty"
        @pl_required = 0
        @cycle_req = 0
        @recipe_id = 0
        @description_id = 0
        @completed = true
        @built_by = "Default"
        @builder_data = nil
      end
    end
    attr_accessor :upgrade_id
    attr_accessor :name
    attr_accessor :icon_id
    attr_accessor :area_required
    attr_accessor :description_id
    attr_accessor :pl_required
    attr_accessor :cycle_req
    attr_accessor :recipe_id
    attr_accessor :built_by
    attr_accessor :completed
    attr_accessor :builder_data
  end
  
  class UPGRADE_DESCRIPTION
    def initialize(upgrade)
      @params = []
      @values = []
      @description = []
      @id = upgrade.description_id
    end
    attr_accessor :params
    attr_accessor :values
    attr_accessor :description
    attr_accessor :id
  end
end