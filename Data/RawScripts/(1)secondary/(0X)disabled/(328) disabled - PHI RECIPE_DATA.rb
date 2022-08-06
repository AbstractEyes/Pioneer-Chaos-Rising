module PHI
  module RECIPES
    
# -------------------------------------------------------------------------- #
# Requirement parameters
# Pioneer Level
# ['pioneer level']
# # Coins
# ['coins', amount]
# # Resources
# ['resources', amount]
# # Item as amount
# ['item', id, amount]
# # Weapon as amount
# ['weapon', id, amount]
# # Armor as amount
# ['armor', id, amount]
# -------------------------------------------------------------------------- #
# Acceptable reward parameters:
# If no reward table, reward = nil
# Template: [reward, ['param'],['param']]
# # Pioneer Exp
# ['pioneer exp',amount]
# # Coins
# ['coins', amount]
# # Resources
# ['resources', amount]
# # Item increased by how many
# ['item', id, amount]
# # Weapon increased by what amount
# ['weapon', id, amount]
# # Armor increased by what amount
# ['armor', id, amount]
# -------------------------------------------------------------------------- #
    RECIPE_DATA = {
#~       #  => [ # Open Recipe List
#~               ['requirement',
#~               [ ['param'],
#~               ],# Close Params
#~               ],# Close Requirement
#~               
#~               ['reward',[['param'],],
#~               ],# Close Reward
#~             ], # Close Recipe List

      0  => # Potion
            [['requirement',[['item',39, 1],['item',40, 1],],], 
            ['reward',[['item',16, 1],],],
            'Consumable',['item',16],1,1],
            
      1  => # Potion
            [['requirement',[['item',44, 1],['item',45, 1],],], 
            ['reward',[['item',16, 1],],],
            'Consumable',['item',16],2,5],
            
      2  => # Potion
            [['requirement',[['item',39, 1],['item',40, 1],],], 
            ['reward',[['item',17, 1],],],
            'Consumable',['item',17],1,10],
            
      3  => # Potion
            [['requirement',[['item',39, 1],['item',40, 1],],], 
            ['reward',[['item',18, 1],],],
            'Consumable',['item',18],1,15],
            
      4  => # Potion
            [['requirement',[['item',40, 1],['item',41, 1],],], 
            ['reward',[['item',19, 1],],],
            'Consumable',['item',19],1,20],
      5  => # Potion
            [['requirement',[['item',40, 1],['item',41, 1],],], 
            ['reward',[['item',20, 1],],],
            'Consumable',['item',20],1,5],
#~       6  => [],
#~       7  => [],
#~       8  => [],
#~       9  => [],
#~       10 => [],
#~       11 => [],
#~       12 => [],
#~       13 => [],
#~       14 => [],
#~       15 => [],
#~       16 => [],
#~       17 => [],
#~       18 => [],
#~       19 => [],
#~       20 => [],
#~       21 => [],
#~       22 => [],
#~       23 => [],
#~       24 => [],
#~       25 => [],
#~       26 => [],
#~       27 => [],
#~       28 => [],
#~       29 => [],
#~       30 => [],
#~       31 => [],
#~       32 => [],
#~       33 => [],
      
    }
    
    def self.create_requirements(id)
      data = RECIPE_DATA[id]
      requirement = PHI::REQUIREMENT.new
      return if data.empty?
      if data[0][0] == 'requirement'
        params = data[0][1]
        for x in 0...params.size
          param_name = params[x][0] if !params[x][0].nil?
          param_name = '' if param_name.nil?
          if param_name == 'pioneer level'
            requirement.pl = params[x][1]
          elsif param_name == 'coins'
            requirement.coins = params[x][1]
          elsif param_name == 'resources'
            requirement.resources = params[x][1]
          elsif param_name == 'item'
            requirement.items.push [params[x][1],params[x][2]]
          elsif param_name == 'weapon'
            requirement.weapons.push [params[x][1],params[x][2]]
          elsif param_name == 'armor'
            requirement.armors.push [params[x][1],params[x][2]]
          end
        end
      else
        requirement = nil
      end
      return requirement
    end
    
    def self.create_rewards(id)
      data = RECIPE_DATA[id]
      reward = PHI::REWARD.new
      return if data.empty?
      if data[1][0] == 'reward'
        params = data[1][1]
        for x in 0...params.size
          param_name = params[x][0] if !params[x][0].nil?
          if param_name == 'pioneer exp'
            reward.pioneer_exp = params[x][1]
          elsif param_name == 'coins'
            reward.coins = params[x][1]
          elsif param_name == 'resources'
            reward.resources = params[x][1]
          elsif param_name == 'item'
            reward.items.push [params[x][1],params[x][2]]
          elsif param_name == 'weapon'
            reward.weapons.push [params[x][1],params[x][2]]
          elsif param_name == 'armor'
            reward.armors.push [params[x][1],params[x][2]]
          end
        end
      else
        reward = nil
      end
      return reward
    end
    
    def self.sort_category(id)
      data = RECIPE_DATA[id]
      return data[2] if !data[2].nil?
      return "Uncategorized"
    end
    
    def self.check_icon_id(id)
      data = RECIPE_DATA[id]
      icon_item_base = data[3] if !data[3].nil?
      return 1 if icon_item_base == nil
      type = icon_item_base[0]
      id = icon_item_base[1]
      if type == 'item'
        return $data_items[id].icon_index
      elsif type == 'weapon'
        return $data_weapons[id].icon_index
      elsif type == 'armor'
        return $data_armors[id].icon_index
      end
      return 1
    end
    
    def self.check_level(id)
      data = RECIPE_DATA[id]
      return data[4] if !data[4].nil?
      return 0
    end
      
    def self.view(id)
      requirements = create_requirements(id)
      rewards = create_rewards(id)
      category = sort_category(id)
      level = check_level(id)
      icon_id = check_icon_id(id)
      return [requirements,rewards,category,level,icon_id]
    end
    
  end
# -------------------------------------------------------------------------- #
# Requirement parameters
# Pioneer Level
# ['pioneer level']
# # Coins
# ['coins', amount]
# # Resources
# ['resources', amount]
# # Item as amount
# ['item', id, amount]
# # Weapon as amount
# ['weapon', id, amount]
# # Armor as amount
# ['armor', id, amount]
# -------------------------------------------------------------------------- #
# Acceptable reward parameters:
# If no reward table, reward = nil
# Template: ['reward', ['param'],['param']]
# # Pioneer Exp
# ['pioneer exp',amount]
# # Coins
# ['coins', amount]
# # Resources
# ['resources', amount]
# # Switch true as reward
# ['switch', id, bool] # (true or false)
# # Variable id as '+','-','/','*','%' amount
# ['variable', id, '+','-','/','*','%', amount]
# # Item increased by how many
# ['item', id, amount]
# # Weapon increased by what amount
# ['weapon', id, amount]
# # Armor increased by what amount
# ['armor', id, amount]
# -------------------------------------------------------------------------- #
  class REQUIREMENT
    def initialize
      @pl = 0
      @coins = 0
      @resources = 0
      @items = []
      @weapons = []
      @armors = []
    end
    attr_accessor :pl
    attr_accessor :coins
    attr_accessor :collateral
    attr_accessor :items
    attr_accessor :weapons
    attr_accessor :armors
  end
  
  class REWARD
    def initialize
      @pioneer_exp = 0
      @coins = 0
      @resources = 0
      @items = []
      @weapons = []
      @armors = []
    end
    attr_accessor :pioneer_exp
    attr_accessor :coins
    attr_accessor :collateral
    attr_accessor :items
    attr_accessor :weapons
    attr_accessor :armors
  end
  
end