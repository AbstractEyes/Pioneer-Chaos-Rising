# ---------------------------------------------------------------------------- #
# PHI - Item Parameters Upgrade #
# ----------------------------- #
# This is essentially a redesign of the entire item structure.
# The design was terrible, difficult to work with algorithmically, 
# and just plain clunky when you try to modify it.
#
# This redesign will allow you to include new statistics via
# notebox comments.  Fairly simple and straightforward, not too
# much work, and with a little bit of tweaking can become your own.
#
# This was essentially inspired by the efficiency fo the list inside
# (0X)RPG.rb Maker VX Ace items.
# I felt the need to create something that functions similarly.
#
# Default Note Tags:
#   (use only one parameter per line please)
#   <hp:  +- value>
#   <mp:  +- value>
#   <sta: +- value>
#   <cri: +- value>
#   <cri_mul: +- value>
#   <ele_res: id_int +- value>
#   <ele_dam: id_int +- value>
#   <ele_res_i: +- value>
#   <phy_res_i: +- value>
#   <all_res: +- value>
#   <state_res: +- value>
#
#   Examples:
#   <str: + 5>
# ---------------------------------------------------------------------------- #
# Credits:
#   Funplayer - Author
#   KGC for the limit breaker as a reference point, this works in junction
#   with or without the limit breaker.  This is basically a glorified string
#   splitter that modifies the base statistics of gear.  Fairly fast though.
# ---------------------------------------------------------------------------- #
module PHI
  module GEAR_CONFIG
    # If you wish for a statistic to remain unaltered,
    # exclude it from the list with a #
      #sym => "strings here"

    NOTES = [:hp, :mp, :stam,
             :cri, :cri_mul,
             :all_res, :ele_res_i, :phy_res_i,
             :ele_res, :ele_dam,
             :phy_res, :phy_dam, :sta_res,

             :g_atk, :g_def, :g_int, :g_agi, :g_hp, :g_mp,
             :g_stam, :g_cri, :g_cri_mul, :g_all_res,
             :g_ele_res_i, :g_ele_dam_i,
             :g_ele_res, :g_ele_dam, :g_sta_res,
             :equip_type
    ]
  end

end

class ElementContainer
  attr_accessor :data

  def initialize
    self.data = {}
  end

  def []=(id, value)
    self.data[id] = 0 unless self.data.keys.include?(id)
    self.data[id] += value
  end

  def [](id)
    return 0 unless self.data.keys.include?(id)
    return self.data[id]
  end

end


class StatNode
  attr_accessor :base
  attr_accessor :mods
  attr_accessor :value
  def initialize(base=0, value=[])
    self.base = base
    self.value = value
  end

  def calculate(level)
    out = self.base #* (level - 1)
    for piece in self.value
      out += piece
    end
    return out
  end
end

class StatContainer
  attr_accessor :get
  def initialize
    self.get = {
      :hp           => StatNode.new,
      :mp           => StatNode.new,
      :stam         => StatNode.new,
      :cri          => StatNode.new,
      :cri_mul      => StatNode.new,
      :sta_res      => StatNode.new,
      :all_res      => StatNode.new,
      :phy_res_i    => StatNode.new,
      :ele_res_i    => StatNode.new,
      :ele_res      => ElementContainer.new,
      :ele_dam      => ElementContainer.new,
      :g_hp         => StatNode.new,
      :g_mp         => StatNode.new,
      :g_stam       => StatNode.new,
      :g_atk        => StatNode.new,
      :g_agi        => StatNode.new,
      :g_spi        => StatNode.new,
      :g_def        => StatNode.new,
      :g_cri        => StatNode.new,
      :g_cri_mul    => StatNode.new,
      :g_sta_res    => StatNode.new,
      :g_all_res    => StatNode.new,
      :g_phy_res_i  => StatNode.new,
      :g_ele_res_i  => StatNode.new,
      :g_ele_res    => ElementContainer.new,
      :g_ele_dam    => ElementContainer.new,
    }
  end

  def [](id)
    return nil unless self.get.keys.include?(id)
    return self.get[id]
  end

end

module RPG
  class BaseItem
    #Universal
    attr_accessor :param_list
    attr_accessor :damage
    attr_accessor :hp
    attr_accessor :mp
    attr_accessor :stats
    attr_accessor :level
    #Skills Exclusive
    attr_accessor :skill_id
    #Weapons + Armors
    attr_accessor :value
    attr_accessor :item_type

    attr_accessor :carbon
    attr_accessor :metal
    attr_accessor :elemental
    attr_accessor :chaotic
    attr_accessor :collateral

    # stats are used for weapons and armor, to add boosts to a character's overall stats.
    # stats used during skills add boosts for the skills themselves.

    def hp
      get_stat(:hp)
    end
    def g_hp
      get_stat(:g_hp)
    end
    def mp
      get_stat(:mp)
    end
    def g_mp
      get_stat(:g_mp)
    end
    def stamina
      get_stat(:stam)
    end
    def sta
      return stamina
    end
    def g_stamina
      get_stat(:g_stam)
    end
    def atk
      @atk
    end
    def g_atk
      return get_stat(:g_atk)
    end
    def spi
      @spi
    end
    def g_spi
      get_stat(:g_spi)
    end
    def agi
      @agi
    end
    def g_agi
      get_stat(:g_agi)
    end
    def def
      @def
    end
    def g_def
      get_stat(:g_def)
    end
    def cri
      get_stat(:cri)
    end
    def g_cri
      get_stat(:g_cri)
    end
    def res
      get_stat(:all_res)
    end
    def g_res
      get_stat(:g_all_res)
    end
    def cri_mul
      get_stat(:cri_mul)
    end
    def g_cri_mul
      get_stat(:g_cri_mul)
    end
    def sta_res
      get_stat(:sta_res)
    end
    def g_sta_res
      get_stat(:g_sta_res)
    end
    def ele_res_i
      get_stat(:ele_res_i)
    end
    def g_ele_res_i
      get_stat(:g_ele_res_i)
    end
    def phy_res_i
      get_stat(:phy_res_i)
    end
    def g_phy_res_i
      get_stat(:g_phy_res_i)
    end
    def ele_res(id)
      get_ele(:ele_res, id)
    end
    def g_ele_res(id)
      get_ele(:g_ele_res, id)
    end
    def ele_dam(id)
      get_ele(:ele_dam, id)
    end
    def g_ele_dam(id)
      get_ele(:g_ele_dam, id)
    end
    def get_stat(key)
      return self.stats[key].calculate(self.level).to_i
    end
    def get_ele(key, id)
      return self.stats[key][id]
    end
    ################################################
    def level
      return 1
    end
    def level=(new_level)
      @level = new_level
    end

    def setup_list_for_self
      # Establish currency
      self.carbon = 0
      self.elemental = 0
      self.metal = 0
      self.chaotic = 0
      self.collateral = 0
      # Establish statistic container
      self.stats = StatContainer.new
      # Splits the possible note params into keys and sequences them.
      self.note.split(/[\r\n]/).each do |baseline|
        # Deletes and records the main parameters.
        next if baseline.empty?
        line = baseline.delete(':').delete('<').delete('>').split(' ')
        next unless PHI::GEAR_CONFIG::NOTES.include?(line[0].to_sym)
        #   <ele_dam: id_int +- value>
        #   <ele_res_i: +- value>
        case line[0].to_sym
          when :item_type
            self.item_type = line[1].to_s
          when :str, :def, :int, :agi, :hp, :mp,
              :stam, :cri, :cri_mul, :all_res,
              :ele_res_i, :ele_dam_i,
              :g_atk, :g_def, :g_int, :g_agi, :g_hp, :g_mp,
              :g_stam, :g_cri, :g_cri_mul, :g_all_res,
              :g_ele_res_i, :g_ele_dam_i
            line[2] = line[2].to_i
            line[2] = -(line[2].to_i) if line[1] == '-'
            self.stats[line[0].to_sym].value.push line[2]
          when :ele_res, :ele_dam, :sta_res, :g_ele_res, :g_ele_dam, :g_sta_res
            line[3] = line[3].to_i
            line[3] = -(line[3]) if line[1] == '-'
            self.stats[line[0].to_sym][line[1].to_i] = line[3]
          when :carbon
            self.carbon = line[1].to_i
          when :metal
            self.metal = line[1].to_i
          when :elemental
            self.elemental = line[1].to_i
          when :collateral
            self.collateral = line[1].to_i
          when :chaotic
            self.chaotic = line[1].to_i
          else
            next
        end
      end
    end
    
    def process_stat(key, raw, chg)
      return 0 if chg.nil?
      if chg[1]
        percent = 100
        percent = eval("#{percent} #{chg[0]} #{chg[2]}")
        raw *= (percent / 100)
        return raw
      else
        raw = eval("#{chg[0]} #{chg[2]}")
        return raw
      end
    end
    
  end # End class
=begin
  class Weapon < UsableItem
    #undef :atk
    #undef :atk=
    #undef :spi
    #undef :spi=
    #undef :def
    #undef :def=
    #undef :agi
    #undef :agi=

    def hp
      get_stat(:hp)
    end
    def hp=(val)
      @hp = val
    end
    def mp
      @mp
    end
    def mp=(val)
      @mp = val
    end
    def atk
      @atk
    end
    def atk=(val)
      @atk=val
    end
    def spi
      @spi
    end
    def spi=(val)
      @spi = val
    end
    def agi
      @agi
    end
    def agi=(val)
      @agi = val
    end
    def def
      @def
    end
    def def=(val)
      @def = val
    end
    def two_handed
      return false
    end
  end
=end
end # End module

=begin
    def process_param_list
      return @param_list.clear unless PHI::GEAR_CONFIG::ENABLE
      for key in @param_list.keys
        type = @param_list[key]
        next if type.empty?
        case key.to_s
        when "str", "def", "int", "agi", "hp", "mp", "stam", "cri"
          if @base_atk.nil?
            @base_atk = @atk
            @atk = 0
          end
          for chg in type
            @atk += process_stat(key, @base_atk, chg)
          end
        when
          if @base_def.nil?
            @base_def = @def
            @def = 0
          end
          for chg in type
            @def += process_stat(key, @base_def, chg)
          end
        when "spi"
          if @base_spi.nil?
            @base_spi = @spi
            @spi = 0
          end
          for chg in type
            @spi += process_stat(key, @base_spi, chg)
          end
        when "agi"
          if @base_agi.nil?
            @base_agi = @agi
            @agi = 0
          end
          for chg in type
            @agi += process_stat(key, @base_agi, chg)
          end
        when "hp"
          if @base_hp.nil?
            self.hp = 0 if self.hp.nil?
            @base_hp = self.hp
            self.hp = 0
          end
          for chg in type
            self.hp += process_stat(key, @base_hp, chg)
          end
        when "mp"
          if @base_mp.nil?
            @base_mp = self.mp
            self.mp = 0
          end
          for chg in type
            self.mp += process_stat(key, @base_mp, chg)
          end
        when "cri"
          if @base_cri.nil?
            @base_cri = @cri
            @cri = 0
          end
          for chg in type
            @cri += process_stat(key, @base_cri, chg)
          end
        when "ele_res"
          for chg in type
            self.ele_res[key] = [] unless self.ele_res.keys.include?(key)
            self.ele_res[key].push chg
          end
        when "ele_dam"
          for chg in type
            self.ele_damage[key] = [] unless self.ele_damage.keys.include?(key)
            self.ele_damage[key].push chg
          end
        when "state_res"
          for chg in type
            self.status_res[key] = [] unless self.status_res.keys.include?(key)
            self.status_res[key].push chg
          end
        when "state_dam"
          for chg in type
            self.status_damage[key] = [] unless self.status_damage.keys.include?(key)
            self.status_damage[key].push chg
          end
        when "skill"

        when "level"

        when"req_var"

        when"var_change"

        when"switch"

        when "attack"
          self.attack_type = type[0][0]
        when "shape"
          self.shape = type[0][0]
        when "size"
          self.size_length = type[0][0].to_i
          self.size_width = type[0][1].to_i
        when "damage_type"
          self.damage_type = type[0][0]
        when "startup"
          self.startup = type[0][0].to_f
        when "cooldown"
          self.cooldown = type[0][0].to_f
        when "offset"
          self.offset = type[0][0].to_i
        when "damage"
          self.damage += type[0][0].to_i
        else
          next
        end
      end
    end
=end