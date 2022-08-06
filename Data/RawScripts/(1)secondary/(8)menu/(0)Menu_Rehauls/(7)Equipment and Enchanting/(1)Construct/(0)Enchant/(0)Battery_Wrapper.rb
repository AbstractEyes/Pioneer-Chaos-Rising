class Hash
  def compact
    delete_if { |k, v| v.nil? }
  end
end

class Battery_Wrapper
  attr_accessor :name
  attr_accessor :icon_index
  attr_accessor :modifier
  attr_reader   :positive_fragments
  attr_reader   :negative_fragments
  def refresh(db_id, socket_id)
    return if socket_id < 0
    @equip = $game_party.equipment[db_id]
    @socket = @equip.sockets[socket_id]
    @socket_id = socket_id
    @name = ''
    @icon_index = 0
    @modifier = 1
    @positive_fragments = []
    @negative_fragments = []
    @positive = true
  end

  def costs
    coins = 0
    carbon = 0
    metal = 0
    elemental = 0
    chaos = 0
    resources = 0
    for cap in fragments
      for e in cap.costs
        value, sym = e[1], e[0]
        coins += value if sym == :markers
        resources += value if sym == :collateral
        carbon += value if sym == :carbon
        metal += value if sym == :metal
        elemental += value if sym == :elemental
        chaos += value if sym == :chaos
      end
    end
    return [coins, resources, carbon, metal, elemental, chaos]
  end

  def costs_hash
    c = costs
    temp = {
        :markers => c[0],
        :collateral => c[1],
        :carbon => c[2],
        :metal => c[3],
        :elemental => c[4],
        :chaotic => c[5]
    }
    for t in temp.keys
      if temp[t] == 0
        temp[t] = nil
      end
    end
    return temp.compact
  end

  def raw_costs
    c = costs
    return [[:markers, c[0]], [:carbon, c[1]], [:metal, c[2]], [:elemental, c[3]], [:chaos, c[4]]]
  end

  def can_pay?
    c = costs
    return c[0] <= $game_party.gold &&
        c[1] <= $game_party.carbon &&
        c[2] <= $game_party.metal &&
        c[3] <= $game_party.elemental &&
        c[4] <= $game_party.chaotic
  end

  def positive_full?
    return @positive_fragments.size == @equip.socket_density(@socket_id)
  end

  def negative_complete?
    return @positive_fragments.size == @negative_fragments.size
  end

  def add_positive(enchantment)
    @positive_fragments.push enchantment
  end

  def add_negative(enchantment)
    enchantment.negate
    @negative_fragments.push enchantment
  end

  def remove_positive
    @positive_fragments.pop
  end

  def remove_negative
    @negative_fragments.pop
  end

  def set_negative
    @positive = false
  end

  def set_positive
    @positive = true
  end

  def positive
    return @positive
  end

  def has_positive?
    return @positive_fragments.size > 0
  end

  def has_negative?
    return @negative_fragments.size > 0
  end

  def fragments
    return @positive_fragments + @negative_fragments
  end

  def can_use_book?(book_key, index)
    return $game_party.book_unlocked?(book_key, index)
  end

  def enchantment
    return Enchantment_Charge.new(@name, @icon_index, @positive_fragments + @negative_fragments, @modifier)
  end

end

