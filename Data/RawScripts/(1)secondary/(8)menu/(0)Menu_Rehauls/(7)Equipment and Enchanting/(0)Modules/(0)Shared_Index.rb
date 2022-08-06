class Game_Index
  attr_accessor :equip_index
  attr_accessor :equip_inventory_index
  attr_accessor :locked_equip
  attr_accessor :locked_equip_index
  attr_accessor :socket_index
  attr_accessor :battery_index
  attr_accessor :enchant_index
  attr_accessor :lock_type
  @equip_index = 0
  @locked_equip_index = -1
  @locked_equip = -1
  @socket_index = 0
  @battery_index = 0
  @enchant_index = 0
  @lock_type = -1
  @equip_inventory_index = 0

  def dump_equip_indexes
    self.equip_index = 0
    self.locked_equip_index = -1
    self.locked_equip = -1
    self.socket_index = 0
    self.battery_index = 0
    self.enchant_index = 0
    self.lock_type = -1
    self.equip_inventory_index = 0
  end

  alias initi_equip_index initialize unless $@
  def initialize(*args, &block)
    #super(*args,&block)
    initi_equip_index(*args,&block)
    dump_equip_indexes
  end

end