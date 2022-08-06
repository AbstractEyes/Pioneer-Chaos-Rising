class Inventory_Help < Window_Base
  
  def initialize(x,y,width,height)
    super(x,y,width,height)
    refresh($game_party.items[0]) unless $game_party.items.empty?
  end
  
  def refresh(item = nil)
    self.contents.clear
    return if item == nil
    if item.is_a?(RPG::Item) and item.is_a?(RPG::Item)
      if item.id == item.id
        @item = item
        set_item_statistics
      end
    end
    #elsif item.is_a?(RPG::Weapon) and item.is_a?(RPG::Weapon)
    #  if item.id == item.id
    #    @item = item
    #    set_weapon_statistics
    #  end
    #elsif item.is_a?(RPG::Armor) and item.is_a?(RPG::Armor)
    #  if item.id == item.id
    #    @item = item
    #    set_armor_statistics
    #  end
    #end
  end
  # 0  Empty type
  # 1  Tool
  # 2  Consumable
  # 3  Raw Materal
  # 4  Refined Materal
  # 5  Monster Item
  # 6  Raw Resource
  # 7  Construction Item
  # 8  One Hand Agility Weapon
  # 9  Two Hand Agility Weapon
  # 10 One Hand Attack Weapon
  # 11 Two Hand Attack Weapon
  # 12 One Hand Intelligence Weapon
  # 13 Two Hand Intelligence Weapon
  # 14 Plate Armor
  # 15 Ring Armor
  # 16 Leather Armor
  # 17 Arcane Armor
  # 18 Accessories
  # 19 Supply
  # 20 Special
  def item_type_converter(item)
    type = item.item_type
    case type
      when 1
        #(red, green, blue[,alpha])
        return ["Tool",Color.new(125,125,125,255)]
      when 2
        return ["Consumable",Color.new(0,255,0,255)]
      when 3
        return ["Raw Material",Color.new(225,125,125,255)]
      when 4
        return ["Refined Material",Color.new(200,200,200,255)]
      when 5
        return ["Monster Part",Color.new(255,125,125,255)]
      when 6
        return ["Commodity",Color.new(100,255,100,255)]
      when 7
        return ["Construction",Color.new(100,50,50,255)]
      when 8
        return ["Supply",Color.new(255,100,25,255)]
      when 9
        return ["Special",Color.new(100,100,255,255)]
      when 9001
        return ["General",Color.new(100,100,100,255)]
      else
    end
  end

  def set_item_statistics
    options = []
    return if @item == nil
    color = self.contents.font.color = system_color
    type = item_type_converter(@item)
    options.push ["#{@item.name}",-1,[color,@item.icon_index]]
      color = self.contents.font.color = normal_color
      color = self.contents.font.color = type[1]
    options.push ["#{type[0]}",0,[color]]
      color = Color.new(255,255,0,255)
    options.push ["Value: #{@item.price}",1,[color]]
      color = self.contents.font.color = normal_color
    scope = @item.scope
    if scope > 0 and @item.consumable == true
      if scope == 1  # One enemy
        options.push ["One enemy as target.",2]
      elsif scope == 2  # all enemies
        options.push ["All enemies as target.",2]
      elsif scope == 3  # one enemy dual
        options.push ["One enemy dual hit.",2]
      elsif scope == 4  # one random enemy
        options.push ["One random enemy.",2]
      elsif scope == 5  # 2 random enemies
        options.push ["Two random enemies.",2]
      elsif scope == 6  # 3 random enemies
        options.push ["Three random enemies.",2]
      elsif scope == 7  # one ally
        options.push ["One ally.",2]
      elsif scope == 8  # all allies
        options.push ["All allies.",2]
      elsif scope == 9  # one ally dead
        options.push ["One incapacitated ally.",2]
      elsif scope == 10 # all allies dead
        options.push ["All incapacitated allies.",2]
      elsif scope == 11 # the user
        options.push ["Menu use.",2]
      end
    end
    if @item.base_damage > 0
      color = self.contents.font.color = hp_color
      options.push ["Base damage: #{@item.base_damage}",3,[color]]
    end
    if @item.hp_recovery_rate > 0
      options.push ["HP heal: #{@item.hp_recovery_rate}%",4]
    end
    if @item.hp_recovery > 0
      options.push ["HP heal amount: #{@item.hp_recovery}",5]
    end
    if @item.mp_recovery_rate > 0
      options.push ["MP heal: #{@item.mp_recovery_rate}%",6]
    end
    if @item.mp_recovery > 0
      options.push ["MP heal amount: #{@item.mp_recovery}",7]
    end
    if @item.parameter_type > 0
      amount = @item.parameter_points # Amount of increase to stat
      if @item.parameter_type == 1 # Max hp
        options.push ["Base HP: +#{amount}",8]
      elsif @item.parameter_type == 2 # max mp
        options.push ["Base MP: +#{amount}",9]
      elsif @item.parameter_type == 3 # max attack
        options.push ["Base Attack: +#{amount}",10]
      elsif @item.parameter_type == 4 # max defense
        options.push ["Base Defense: +#{amount}",11]
      elsif @item.parameter_type == 5 # max intelligence
        options.push ["Base Intelligence: +#{amount}",12]
      elsif @item.parameter_type == 6 # max agility
        options.push ["Base Agility: +#{amount}",13]
      end
    end
    draw_item_statistics(options)
  end
  
  def draw_item_statistics(options)
    xr = 0
    for i in 0...options.size
      if options[i][2] != nil
        data = options[i][2]
        for param in data
          if param.is_a?(Color)
            self.contents.font.color = param
          elsif param.is_a?(Integer)
            xr = 24
            self.draw_icon(param,0,i*24,true)
          end
        end
      end
      self.contents.draw_text(0+xr,i*24,width,WLH,options[i][0])
      self.contents.font.color = normal_color
      xr = 0
    end
  end
    
  def set_weapon_statistics
    self.contents.clear
    options = []
    return if @item == nil
    color = self.contents.font.color = system_color
    type = item_type_converter(@item)
    options.push ["#{@item.name}",-1,[color,@item.icon_index]]
      color = self.contents.font.color = normal_color
      color = self.contents.font.color = type[1]
    options.push ["#{type[0]}",0,[color]]
      color = Color.new(255,255,0,255)
    options.push ["Value: #{@item.price}",1,[color]]
      color = self.contents.font.color = normal_color
      # HP statistic of gear
#~       (0)options.push ["Max HP: +#{@item.stat_per[:hp]}",2]
#~       (0)options.push ["Max MP: +#{@item.stat_per[:mp]}",3]
      options.push ["Attack: +#{@item.atk}",4,["first"]]
      options.push ["Base Hit: %#{@item.hit}",5,["first"]]
#~       (0)options.push ["Base Crit: %#{@item.cri}",6,["first"]]
      options.push ["Defense: +#{@item.def}",7,["first"]]
      options.push ["Agility: +#{@item.agi}",8,["second"]]
#~       (0)options.push ["Dexterity: +#{@item.dex}",9,["second"]]
      options.push ["Intelligence: +#{@item.spi}",10,["second"]]
#~       (0)options.push ["Magic Resist: +#{@item.res}",11,["second"]]
      
    draw_weapon_statistics(options)      
  end
  
  def draw_weapon_statistics(options)
    xr = 0
    for i in 0...options.size
      if options[i][2] != nil
        data = options[i][2]
        for param in data
          if param.is_a?(Color)
            self.contents.font.color = param
          elsif param.is_a?(Integer)
            xr = 24
            self.draw_icon(param,0,i*24,true)
          elsif param.is_a?(String)
            if param == "first"
              xr = 0
            elsif param == "second"
              xr = self.width / 2
            end
          end
        end
      end
      self.contents.draw_text(0+xr,i*20,width,WLH,options[i][0])
      self.contents.font.color = normal_color
      xr = 0
    end
  end

  def set_armor_statistics
    self.contents.clear
    options = []
    return if @item == nil
    color = self.contents.font.color = system_color
    type = item_type_converter(@item)
    options.push ["#{@item.name}",-1,[color,@item.icon_index]]
      color = self.contents.font.color = normal_color
      color = self.contents.font.color = type[1]
    options.push ["#{type[0]}",0,[color]]
      color = Color.new(255,255,0,255)
    options.push ["Value: #{@item.price}",1,[color]]
      color = self.contents.font.color = normal_color
    draw_item_statistics(options)
  end
  
end