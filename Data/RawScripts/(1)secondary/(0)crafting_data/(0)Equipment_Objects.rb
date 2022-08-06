class Enchantment_Charge < Hash
  attr_accessor :name
  attr_reader   :modifier
  attr_accessor :icon_index

  def initialize(name, icon_index, stats, modifier=1)
    super(nil)
    @name = name
    @icon_index = icon_index
    @modifier = modifier
    stats.each { |stat|; self[stat.base_type] = stat; }
  end

  def positive_density
    out = 0; self.each_value { |stat|; out += stat.positive_density; }; return out
  end

  def negative_density
    out = 0; self.each_value { |stat|; out += stat.negative_density; }; return out
  end

  def icon_index_pos
    return self[ordered_keys.reverse[0]].icon_index
  end

  def icon_index_neg
    return self[ordered_keys[0]].icon_index
  end

  def color(alpha=100)
    c = self[ordered_keys.reverse[0]].color.clone
    c.alpha = alpha
    return c
  end

  def pos_color(alpha=100)
    return self.color(alpha)
  end

  def neg_color(alpha=100)
    c = self[ordered_keys[0]].color.clone
    c.alpha = alpha
    return c
  end

  def ordered_keys
    return self.keys.sort_by { |key| p key; self[key].value }
  end

  def hp
    out = 0; self.each_value { |stat|; out += stat.hp; }; return out * @modifier
  end

  def mp
    out = 0; self.each_value { |stat|; out += stat.mp; }; return out * @modifier
  end

  def sta
    out = 0; self.each_value { |stat|; out += stat.sta; }; return out * @modifier
  end

  def atk
    out = 0; self.each_value { |stat|; out += stat.atk; }; return out * @modifier
  end

  def agi
    out = 0; self.each_value { |stat|; out += stat.agi; }; return out * @modifier
  end

  def spi
    out = 0; self.each_value { |stat|; out += stat.spi; }; return out * @modifier
  end

  def def
    out = 0; self.each_value { |stat|; out += stat.def; }; return out * @modifier
  end

  def cri
    out = 0; self.each_value { |stat|; out += stat.cri; }; return out * @modifier
  end

  def cri_mul
    out = 0; self.each_value { |stat|; out += stat.cri_mul; }; return out * @modifier
  end

  def all_res
    out = 0; self.each_value { |stat|; out += stat.all_res; }; return out * @modifier
  end

  def ele_res_i
    out = 0; self.each_value { |stat|; out += stat.ele_res_i; }; return out * @modifier
  end

  def phy_res_i
    out = 0; self.each_value { |stat|; out += stat.phy_res_i; }; return out * @modifier
  end

  def sta_res
    out = 0; self.each_value { |stat|; out += stat.sta_res; }; return out * @modifier
  end

  def ele_res(id)
    out = 0; self.each_value { |stat|; out += stat.ele_res(id); }; return out * @modifier
  end

  def ele_dam(id)
    out = 0; self.each_value { |stat|; out += stat.ele_dam(id); }; return out * @modifier
  end

end

class Enchantment_Fragment
  attr_accessor :base_type
  attr_accessor :value
  attr_accessor :ele_id
  attr_accessor :weight
  attr_accessor :icon_index
  attr_accessor :growth
  attr_accessor :costs
  attr_accessor :book_key

  def initialize(type, value, book_key, ele_id=-1, weight=1, costs=[], icon_index=-1, name='')
    @name = name
    @base_type = type
    @value = value
    @weight = weight
    @ele_id = ele_id
    @icon_index = icon_index
    @costs = costs
    @book_key = book_key
  end

  def negate
    @value *= -1
  end

  def positive_density
    return @weight if @value >= 0
    return 0
  end

  def negative_density
    return @weight if @value < 0
    return 0
  end

  def icon_index
    return @icon_index unless @icon_index == -1
    return 0 unless PHI::ICONS::STATS.keys.include? @base_type
    return PHI::ICONS.get_element_icon_int(@ele_id-1) if @ele_id > 0
    return PHI::ICONS::STATS[@base_type][0]
  end

  def icon_index=(new_index)
    @icon_index = new_index
  end

  def color
    return PHI::ICONS.get_element_color(@ele_id) if @ele_id > -1
    return PHI::ICONS::STATS[@base_type][1]
  end

  def value_color
    value >= 0 ?
        color = Color.new(200, 200, 200, 255) :
        color =  Color.new(200, 200, 200, 255)
    return color
  end

  def name
    return @name unless @name.empty?
    n = ''
    n += $data_system.elements[@ele_id] + ' ' if @base_type == :ele_res or @base_type == :ele_dam
    n += PHI::ENCHANTMENT::FRAGMENT_TYPE_DATA[@base_type][0]
    return n
  end

  def short_name
    return @name unless @name.empty?
    n = ''
    n += '+' if value > 0
    val = value.to_s
    n += val + '% '
    #n += $data_system.elements[@ele_id] + ' ' if @base_type == :ele_res or @base_type == :ele_dam
    n += PHI::ENCHANTMENT::CONVERTED_FRAGMENT_KEYS[@base_type].to_s.capitalize
    return n
  end

  def sym_name
    return $data_system.elements[@ele_id].capitalize if @ele_id > -1
    return @base_type.to_s.capitalize
  end

  def name=(new_name)
    @name = new_name
  end

  def invert
    @value = -@value
  end

  def val_out
    return @value
  end

  def hp
    return 0 if not_base_type?(:hp)
    return val_out
  end

  def mp
    return 0 if not_base_type?(:mp)
    return val_out
  end

  def sta
    return 0 if not_base_type?(:sta)
    return val_out
  end

  def atk
    return 0 if not_base_type?(:atk)
    return val_out
  end

  def agi
    return 0 if not_base_type?(:agi)
    return val_out
  end

  def spi
    return 0 if not_base_type?(:spi)
    return val_out
  end

  def def
    return 0 if not_base_type?(:def)
    return val_out
  end

  def cri
    return 0 if not_base_type?(:cri)
    return val_out
  end

  def cri_mul
    return 0 if not_base_type?(:cri_mul)
    return val_out
  end

  def all_res
    return 0 if not_base_type?(:all_res)
    return val_out
  end

  def ele_res_i
    return 0 if not_base_type?(:ele_res_i)
    return val_out
  end

  def phy_res_i
    return 0 if not_base_type?(:phy_res_i)
    return val_out
  end

  def sta_res
    return 0 if not_base_type?(:sta_res)
    return val_out
  end

  def ele_res(id)
    return 0 if not_base_type?(:ele_res)
    return 0 if not_element?(id)
    return val_out
  end

  def ele_dam(id)
    return 0 if not_base_type?(:ele_dam)
    return 0 if not_element?(id)
    return val_out
  end

  def is_element?
    return (!not_base_type?(:ele_dam) or !not_base_type?(:ele_res))
  end

  def not_base_type?(type_in)
    return @base_type != type_in
  end

  def not_element?(id)
    return @ele_id != id
  end

end

class Socket_Container < Hash

  def level_up(socket)
    self[socket].level += 1
  end

  def enchant(socket, enchantment)
    self[socket] = enchantment
  end

  def hp
    out = 0
    self.each_value { |soc| out += soc.hp }
    return out
  end

  def mp
    out = 0
    self.each_value { |soc| out += soc.mp }
    return out
  end

  def sta
    out = 0
    self.each_value { |soc| out += soc.sta }
    return out
  end

  def agi
    out = 0
    self.each_value { |soc| out += soc.agi }
    return out
  end

  def atk
    out = 0
    self.each_value { |soc| out += soc.atk }
    return out
  end

  def spi
    out = 0
    self.each_value { |soc| out += soc.spi }
    return out
  end

  def def
    out = 0
    self.each_value { |soc| out += soc.def }
    return out
  end

  def cri
    out = 0
    self.each_value { |soc| out += soc.cri }
    return out
  end

  def cri_mul
    out = 0
    self.each_value { |soc| out += soc.cri_mul }
    return out
  end

  def all_res
    out = 0
    self.each_value { |soc| out += soc.all_res }
    return out
  end

  def ele_res_i
    out = 0
    self.each_value { |soc| out += soc.ele_res_i }
    return out
  end

  def phy_res_i
    out = 0
    self.each_value { |soc| out += soc.phy_res_i }
    return out
  end

  def sta_res
    out = 0
    self.each_value { |soc| out += soc.sta_res }
    return out
  end

  def ele_res(id)
    out = 0
    self.each_value { |soc| out += soc.ele_res(id) }
    return out
  end

  def ele_dam(id)
    out = 0
    self.each_value { |soc| out += soc.ele_dam(id) }
    return out
  end

end


class Equipment
  attr_accessor :level
  attr_accessor :sockets

  def initialize(base_type, old_equipment_id, level_in=1)
    @type = base_type
    @base = old_equipment_id
    @level = [1, level_in].max
    @sockets = Socket_Container.new
    #@sockets.enchant(0, PHI::ENCHANTMENT::ENCHANTMENT_DATA[rand(4)].clone)
    #@sockets.enchant(1, PHI::ENCHANTMENT::ENCHANTMENT_DATA[rand(4)].clone)
    @socket_density = {}
    @sockets.keys.each { |key| @socket_density[key] = 1 }
    @name = ''
    generate_stats
  end

  def generate_stats
    @stats = {}
    @stats[:hp]        = stat_hp.to_s
    @stats[:mp]        = stat_mp.to_s
    @stats[:sta]       = stat_stamina.to_s
    @stats[:str]       = stat_atk.to_s
    @stats[:int]       = stat_spi.to_s
    @stats[:agi]       = stat_agi.to_s
    @stats[:def]       = stat_def_.to_s
    @stats[:cmul]      = stat_cri_mul.to_s
    @stats[:crat]      = stat_cri.to_s
    @stats[:ares]      = stat_res.to_s
    @stats[:pres]      = stat_phy_res_i.to_s
    @stats[:eres]      = stat_ele_res_i.to_s
    @stats[:sres]      = stat_sta_res.to_s
    @stats = element_both(@stats)
  end

  def stats
    out = {}
    #out[:lvl ] = level.to_s
    out[:hp]        = stat_hp.to_s        if stat_hp != 0 #base.hp > 0
    out[:mp]        = stat_mp.to_s        if stat_mp != 0 #base.mp > 0
    out[:sta]       = stat_stamina.to_s   if stat_stamina != 0 #base.stamina > 0
    out[:str]       = stat_atk.to_s       if stat_atk != 0 #base.atk > 0
    out[:int]       = stat_spi.to_s       if stat_spi != 0 #base.spi > 0
    out[:agi]       = stat_agi.to_s       if stat_agi != 0 #base.agi > 0
    out[:def]       = stat_def_.to_s      if stat_def_ != 0 #base.def > 0
    out[:critmult]  = stat_cri_mul.to_s   if stat_cri_mul != 0 #base.cri_mul > 0
    out[:critrate]  = stat_cri.to_s       if stat_cri != 0 #base.cri > 0
    out[:allres]    = stat_res.to_s       if stat_res != 0 #base.res > 0
    out[:physres]   = stat_phy_res_i.to_s if stat_phy_res_i != 0 #base.phy_res_i > 0
    out[:eleres]    = stat_ele_res_i.to_s if stat_ele_res_i != 0 #base.ele_res_i > 0
    out[:statusres] = stat_sta_res.to_s   if stat_sta_res != 0 #base.sta_res > 0
    return out
  end

  def all_stats
    return @stats
  end

  def element_both(in_hash={})
    for i in 0...PHI::ICONS::SORTED_ELEMENTS.keys.size
      in_hash[PHI::ICONS::SORTED_ELEMENTS[i]] = []
      in_hash[PHI::ICONS::SORTED_ELEMENTS[i]].push stat_ele_dam(i+1) #if ele_dam(i+1) != 0
      in_hash[PHI::ICONS::SORTED_ELEMENTS[i]].push stat_ele_res(i+1) #if ele_res(i+1) != 0
    end
    return in_hash
  end

  def element_damages
    out = {}
    for i in 0...PHI::ICONS::SORTED_ELEMENTS.keys.size
      out[PHI::ICONS::SORTED_ELEMENTS[i]] = stat_ele_dam(i+1) if ele_dam(i+1) != 0
    end
    return out
  end

  def element_resistances
    out = {}
    for i in 0...PHI::ICONS::SORTED_ELEMENTS.keys.size
      out[PHI::ICONS::SORTED_ELEMENTS[i]] = stat_ele_res(i+1) if ele_res(i+1) != 0
    end
    return out
  end

  def upgrade_socket_density(socket, weight=1)
    @socket_density[socket] = 1 unless @socket_density.keys.include?(socket)
    @socket_density[socket] = weight
    generate_stats
  end

  def socket_density(socket)
    @socket_density[socket] = 1 unless @socket_density.keys.include?(socket)
    return @socket_density[socket]
  end

  def disassemble_globs
    return price / 50
  end

  def weapon?
    return @type
  end

  def level_up(amount)
    @level += amount
    generate_stats
  end

  def enchant_multiple(enchantments=[])
    for e in enchantments
      sock = get_last_socket
      enchant(sock, e.clone)
    end
    generate_stats
  end

  def get_last_socket
    out = 0
    while @sockets.keys.include?(out)
      out += 1
    end
    return out if out
  end

  def enchant(socket, enchantment)
    @sockets.enchant(socket, enchantment)
    generate_stats
  end

  def disenchant(index)
    @sockets.delete(index)
    generate_stats
  end

  def max_sockets
    return ([1, @level - 1].max / 10.0).ceil
  end

  def base
    return @type ? $data_weapons[@base] : $data_armors[@base]
  end

  def base_id
    return base.id
  end

  def description
    return base.description
  end

  def dual_attack
    return false unless weapon?
    base.dual_attack
  end

  def kind
    return 0 if weapon? && !dual_attack
    return 1 if weapon? && dual_attack
    return 6 if base.kind == 0
    return base.kind + 1
  end

  def note
    return base.note
  end

  def icon_index
    return base.icon_index
  end

  def name
    return @name unless @name.empty?
    return base.name
  end

  def name=(new_name)
    @name = new_name
  end

  def equip_type
    return base.equip_type
  end

  def price
    return base.price * @level
  end

  def animation_id
    return base.animation_id
  end

  def dash_speed_bonus
    return base.dash_speed_bonus
  end

  def statistic_formula(base_stat, growth_stat, socket_value, actor_base=1)
    return ((actor_base * (base_stat + (growth_stat * (@level - 1))) / 100) + (actor_base * socket_value / 100.0).ceil)
  end

  def elemental_formula(base_stat, growth_stat, socket_value)
    return (base_stat + (growth_stat * (@level - 1))) + socket_value
  end
  def stat_hp(actor_base=100)
    return statistic_formula(base.hp, base.g_hp, @sockets.hp, actor_base)
  end
  def stat_mp(actor_base=100)
    return statistic_formula(base.mp, base.g_mp, @sockets.mp, actor_base)
  end
  def stat_stamina(actor_base=100)
    return statistic_formula(base.sta, base.g_stamina, @sockets.sta, actor_base)
  end
  def stat_atk(actor_base=100)
    return statistic_formula(base.atk, base.g_atk, @sockets.atk, actor_base)
  end
  def stat_spi(actor_base=100)
    return statistic_formula(base.spi, base.g_spi, @sockets.spi, actor_base)
  end
  def stat_agi(actor_base=100)
    return statistic_formula(base.agi, base.g_agi, @sockets.agi, actor_base)
  end
  def stat_def(actor_base=100)
    return statistic_formula(base.def, base.g_def, @sockets.def, actor_base)
  end
  def stat_def_(actor_base=100)
    return statistic_formula(base.def, base.g_def, @sockets.def, actor_base)
  end
  def stat_cri(actor_base=100)
    return statistic_formula(base.cri, base.g_cri, @sockets.cri, actor_base)
  end
  def stat_cri_mul(actor_base=100)
    return statistic_formula(base.cri_mul, base.g_cri_mul, @sockets.cri_mul, actor_base)
  end
  def stat_res(actor_base=100)
    return statistic_formula(base.res, base.g_res, @sockets.all_res, actor_base)
  end
  def stat_sta_res(actor_base=100)
    return statistic_formula(base.sta_res, base.g_sta_res, @sockets.sta_res, actor_base)
  end
  def stat_phy_res_i(actor_base=100)
    return statistic_formula(base.phy_res_i, base.g_phy_res_i, @sockets.phy_res_i, actor_base)
  end
  def stat_ele_res_i(actor_base=100)
    return statistic_formula(base.ele_res_i, base.g_ele_res_i, @sockets.ele_res_i, actor_base)
  end
  def stat_ele_res(id, actor_base=100)
    return elemental_formula(base.ele_res(id), base.g_ele_res(id), @sockets.ele_res(id))
  end
  def stat_ele_dam(id, actor_base=100)
    return elemental_formula(base.ele_dam(id), base.g_ele_dam(id), @sockets.ele_dam(id))
  end

  def hp(actor_base=100)
    return @stats[:hp]
  end
  def mp(actor_base=100)
    return @stats[:mp]
  end
  def stamina(actor_base=100)
    return @stats[:sta]
  end
  def atk(actor_base=100)
    return @stats[:str]
  end
  def spi(actor_base=100)
    return @stats[:int]
  end
  def agi(actor_base=100)
    return @stats[:agi]
  end
  def def(actor_base=100)
    return @stats[:def]
  end
  def def_(actor_base=100)
    return @stats[:def]
  end
  def cri(actor_base=100)
    return @stats[:crat]
  end
  def cri_mul(actor_base=100)
    return @stats[:cmul]
  end
  def res(actor_base=100)
    return @stats[:ares]
  end
  def sta_res(actor_base=100)
    return @stats[:sres]
  end
  def phy_res_i(actor_base=100)
    return @stats[:pres]
  end
  def ele_res_i(actor_base=100)
    return @stats[:eres]
  end
  def ele_res(id, actor_base=100)
    return @stats[PHI::ICONS::SORTED_ELEMENTS[id]][1].clone.to_i
  end
  def ele_dam(id, actor_base=100)
    return @stats[PHI::ICONS::SORTED_ELEMENTS[id]][0].clone.to_i
  end

end