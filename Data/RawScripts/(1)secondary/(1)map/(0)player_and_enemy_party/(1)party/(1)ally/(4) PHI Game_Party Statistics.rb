module PHI
  module DROPS
    WEAPONS = [1, 2, 19, 20, 5, 6]
    ARMORS = [1, 2, 3, 9, 10, 11, 13, 14, 15]
  end

  #PHI::CURRENCY::TYPES
  module CURRENCY
    TYPES = [:markers, :collateral, :carbon, :metal, :elemental, :chaotic]
    ICONS = [1630, 1597, 1726, 1739, 1706, 2003]
    COLOR = [:GOLD, :GREEN, :BLACK, :GREY, :ORANGE, :RED]
  end

end

class Array
  def swap(pos1, pos2)
    i1 = self[pos1]
    i2 = self[pos2]
    self[pos1] = i2
    self[pos2] = i1
  end
end

class Equipment_Inventory < Hash

  def initialize(*args, &block)
    super(*args, &block)
    @sorted = [-1] * 100
  end

  def sorted
    return @sorted
  end

  def swap(pos1, pos2)
    @sorted.swap(pos1, pos2)
  end

  def unequip(equipped_db_id, inventory_db_id)
    @sorted[@sorted.index(inventory_db_id)] = equipped_db_id
  end

  def next_sorted_position
    for i in 0...@sorted.size
      return i if @sorted[i] == -1
    end
    @sorted += [-1] * 6
    return next_sorted_position
  end

  def random_equip_base_type_id
    type = rand(2)
    if type == 0
      return [true, PHI::DROPS::WEAPONS[rand(PHI::DROPS::WEAPONS.size - 1) + 1]]
    else
      return [false, PHI::DROPS::ARMORS[rand(PHI::DROPS::ARMORS.size - 1) + 1]]
    end
  end

  # Adds a random newly formed gear to the inventory.
  # Returns new gear's db_id
  # level_range[0] = minimum_level, level_range[1] = level_variation
  def new_random_gear(level_range=[1, 200], enchantments=[])
    neg = 1
    neg = -1 if rand(2) == 1
    base = random_equip_base_type_id
    return new_gear(base[0], base[1], (neg * (rand(level_range[1]) + (neg * 1)) + level_range[0]), enchantments)
  end

  # Returns the new gear's db_id
  def new_gear(item_type, item_base_id, level=1, enchantments=[], equipped=false)
    return -1 if item_base_id == -1
    out_id = get_next_db_id
    self[out_id] = Equipment.new(item_type, item_base_id, level)
    self[out_id].enchant_multiple(enchantments)
    @sorted[next_sorted_position] = out_id unless equipped
    return out_id
  end

  # Returns nil, adds value to currencies for enchantments and gear
  def disassemble(db_id)
    self.delete(db_id)
    @sorted[@sorted.index(db_id)] = -1
  end

  # Returns old gear_id from slot to be added to equip inventory.
  # Equipment can only be swapped for other equipment, never unequipped.
  def equip(db_id, actor_id, equipment_slot)
    $game_party.all_members_safe[actor_id].change_equip(equipment_slot, db_id)
  end

  # Raises the level of a piece of equipment by 2.
  def temper_equip(db_id, levels=2)
    self[db_id].level += levels
  end

  # Raises the level of an enchantment inside of equipment.
  def temper_socket(db_id, socket, levels=1)
    self[db_id].socket(socket).level_up(levels)
  end

  # Tacks the gear with prepared enchantment
  def enchant(db_id, socket, prepared_enchantment)
    self[db_id].socket(socket, prepared_enchantment)
  end

  # Removes enchantment from slot.
  def disenchant(db_id, slot)
    self[db_id].socket(slot, nil)
  end

  # Returns the next open slot in the equipment inventory.
  def get_next_db_id
    out = 0
    while self.keys.include?(out) do out += 1 end
    return out
  end

  def equipped
    out = []
    $game_party.all_members_safe.each do |safe_mem|
      out += safe_mem.equip_ids
    end
    out.compact!
    return out
  end

  def unequipped
    self.keys - equipped
  end

  def equipped?(db_id)
    self.equipped.include?(db_id)
  end

  def get_equipped_member(db_id)
    $game_party.all_members_safe.each do |safe_mem|
      return safe_mem if safe_mem.equip_ids.include?(db_id)
    end
    return nil
  end

  def same_equips(db_id)
    out = []
    item_base = self[db_id]
    for i in 0...@sorted.size
      next if @sorted[i] == -1
      next if @sorted[i] == db_id
      temp_item = self[@sorted[i]]
      next if temp_item.nil?
      out.push(@sorted[i]) if item_base.kind == temp_item.kind &&
          item_base.base_id == temp_item.base_id
    end
    return out.reverse
  end

  def stats_pool(db_id)
    out = {}
    #p get_equipped_member(db_id).name
    get_equipped_member(db_id).equips.each do |equip|
      equip.stats.clone.each do |stat, value|
        out[stat] = 0 unless out.keys.include?(stat)
        out[stat] += value.to_i
      end
    end
    return out
  end

  def all_stats(db_id)
    out = {}
    return self[db_id].all_stats if get_equipped_member(db_id).nil?
    get_equipped_member(db_id).equips.clone.each do |equip|
      equip.all_stats.clone.each do |stat, value|
        vclone = value.clone
        if vclone.is_a?(Array)
          if !out.keys.include?(stat)
            out[stat] = vclone
          else
            out[stat][0] += vclone[0]
            out[stat][1] += vclone[1]
          end
        else
          out[stat] = 0 unless out.keys.include?(stat)
          out[stat] += vclone.to_i
        end
      end
    end
    return out
  end

  def sort_by(by_type=true, by_level=true, by_number=true, can_equip=true)
    test = self.keys.sort_by { |db_id|
      [by_type ? (self[db_id].weapon? ? 0 : 1) : 0,
       by_number ? self[db_id].base_id : 0,
       by_level ? self[db_id].level : 0]
    }
    test -= equipped
    while test.size < 100
      test.push -1
    end
    @sorted = test
    return @sorted
  end

end

class Item_Inventory < Hash
  attr_accessor :capacity

  def add(item_id, amount=1)
    self[item_id] = 0 unless self.keys.include?(item_id)
    self[item_id] += amount
    self.delete(item_id) if self[item_id] <= 0
  end

  def sort_by
    #consumable
    #gatherable
    #raw material

    self.each_value do |item|

    end
  end

  def initialize(capacity_in=20)
    self.capacity = capacity_in
  end

end

class Game_Party < Game_Unit
  attr_accessor :equipment
  attr_accessor :collateral
  attr_accessor :metal
  attr_accessor :carbon
  attr_accessor :elemental
  attr_accessor :chaotic

  alias phi_old_initialize_game_party initialize unless $@
  def initialize
    phi_old_initialize_game_party
    @items = Item_Inventory.new
    @storage = Item_Inventory.new
    @equipment = Equipment_Inventory.new
    @collateral = 0
    @metal = 0
    @carbon = 0
    @elemental = 0
    @chaotic = 0
  end

  def add_currency(type=:gold, amount=0)
    case type
      when :gold, :markers #gold
        gain_gold(amount)
      when :resource, :collateral
        @collateral += amount
        @collateral = 0 if @collateral < 0
      when :carbon #carbon
        @carbon += amount
        @carbon = 0 if @carbon < 0
      when :metal #metal
        @metal += amount
        @metal = 0 if @metal < 0
      when :elemental #elemental
        @elemental += amount
        @elemental = 0 if @elemental < 0
      when :chaotic, :chaos
        @chaotic += amount
        @chaotic = 0 if @chaotic < 0
    end
  end

  def currencies
    return [[:markers, @gold], [:collateral, @collateral],
            [:carbon, @carbon], [:metal, @metal],
            [:elemental, @elemental], [:chaotic, @chaotic]]
  end

  def currency_hash
    return {
        :markers => @gold,
        :collateral => @collateral,
        :carbon => @carbon,
        :metal => @metal,
        :elemental => @elemental,
        :chaotic => @chaotic
    }
  end

  def can_afford?(key, value)
    return currency_hash[key] >= value
  end

  def charge_currencies(currencies)
    for c in currencies
      add_currency(c[0], -c[1])
    end
  end

  def reward_currencies(currencies)
    for c in currencies
      add_currency(c[0], c[1])
    end
  end
  
  #--------------------------------------------------------------------------
  # * Get Party Name
  #    If there is only one, returns the actor's name. If there are more,
  #    returns "XX's Party".
  #--------------------------------------------------------------------------
  def name
    if @actors.size == 0
      return ''
    elsif @actors.size == 1
      return members[0].name
    else
      return sprintf(Vocab::PartyName, members[0].name)
    end
  end
  #--------------------------------------------------------------------------
  # * Battle Test Party Setup
  #--------------------------------------------------------------------------
  def setup_battle_test_members
    @actors = []
    for battler in $data_system.test_battlers
      actor = $game_actors[battler.actor_id]
      actor.change_level(battler.level, false)
      actor.change_equip_by_id(0, battler.weapon1_id, true)
      actor.change_equip_by_id(1, battler.weapon2_id, true)
      actor.change_equip_by_id(2, battler.armor1_id, true)
      actor.change_equip_by_id(3, battler.armor2_id, true)
      actor.change_equip_by_id(4, battler.armor3_id, true)
      actor.recover_all
      @actors.push(actor.id)
    end
    @items = {}
    for i in 1...$data_items.size
      if $data_items[i].battle_ok?
        @items[i] = 99 unless $data_items[i].name.empty?
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Get Maximum Level
  #--------------------------------------------------------------------------
  def max_level
    level = 0
    for i in @actors
      actor = $game_actors[i]
      level = actor.level if level < actor.level
    end
    return level
  end
  #--------------------------------------------------------------------------
  # * Get Item Object Array From Bagman
  #--------------------------------------------------------------------------
  def items
    result = []
    for i in @items.keys.sort
      result.push($data_items[i]) if @items[i] > 0
    end
    #for i in @weapons.keys.sort
    #  result.push($data_weapons[i]) if @weapons[i] > 0
    #end
    #for i in @armors.keys.sort
    #  result.push($data_armors[i]) if @armors[i] > 0
    #end
    return result
  end

  def equipment
    return @equipment
  end
  #--------------------------------------------------------------------------
  # * Gain Gold (or lose)
  #     n : amount of gold
  #--------------------------------------------------------------------------
  def gain_gold(n)
    @gold = [[@gold + n, 0].max, 9999999].min
  end
  #--------------------------------------------------------------------------
  # * Lose Gold
  #     n : amount of gold
  #--------------------------------------------------------------------------
  def lose_gold(n)
    gain_gold(-n)
  end
  #--------------------------------------------------------------------------
  # * Increase Steps
  #--------------------------------------------------------------------------
  def increase_steps
    @steps += 1
  end
  #--------------------------------------------------------------------------
  # * Get Number of Items Possessed
  #     item : item
  #--------------------------------------------------------------------------
  def item_number(item)
    case item
    when RPG::Item
      number = @items[item.id]
    #when RPG::Weapon
    #  number = @weapons[item.id]
    #when RPG::Armor
    #  number = @armors[item.id]
    end
    return number == nil ? 0 : number
  end
  #--------------------------------------------------------------------------
  # * Determine Item Possession Status
  #     item          : Item
  #     include_equip : Include equipped items
  #--------------------------------------------------------------------------
  def has_item?(item, include_equip = false)
    if item_number(item) > 0
      return true
    end
    if include_equip
      for actor in members
        return true if actor.equips.include?(item)
      end
    end
    return false
  end
  #--------------------------------------------------------------------------
  # * Gain Items (or lose)
  #     item          : Item
  #     n             : Number
  #     include_equip : Include equipped items
  #--------------------------------------------------------------------------
  def gain_item(item, n, include_equip = false)
    number = item_number(item)
    case item
    when RPG::Item
      @items[item.id] = [[number + n, 0].max, 99].min
    end
    n += number
    if include_equip and n < 0
      for actor in members
        while n < 0 and actor.equips.include?(item)
          actor.discard_equip(item)
          n += 1
        end
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Lose Items
  #     item          : Item
  #     n             : Number
  #     include_equip : Include equipped items
  #--------------------------------------------------------------------------
  def lose_item(item, n, include_equip = false)
    gain_item(item, -n, include_equip)
  end
  #--------------------------------------------------------------------------
  # * Consume Items
  #     item : item
  #    If the specified object is a consumable item, the number in investory
  #    will be reduced by 1.
  #--------------------------------------------------------------------------
  def consume_item(item)
    if item.is_a?(RPG::Item) and item.consumable
      lose_item(item, 1)
    end
  end
  #--------------------------------------------------------------------------
  # * Determine if Item is Usable
  #     item : item
  #--------------------------------------------------------------------------
  def item_can_use?(item)
    return false unless item.is_a?(RPG::Item)
    return false if item_number(item) == 0
    if $game_temp.in_battle
      return item.battle_ok?
    else
      return item.menu_ok?
    end
  end
  #--------------------------------------------------------------------------
  # * Determine if Command is Inputable
  #    Automatic battle is handled as inputable.
  #--------------------------------------------------------------------------
  def inputable?
    for actor in members
      return true if actor.inputable?
    end
    return false
  end
  #--------------------------------------------------------------------------
  # * Determine Everyone is Dead
  #--------------------------------------------------------------------------
  def all_dead?
    if @actors.size == 0 and not $game_temp.in_battle
      return false 
    end
    return existing_members.empty?
  end



end