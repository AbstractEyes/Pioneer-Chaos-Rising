module MAP_SWAP_DATA

  TILESETS = {
      :a1 => [0, 1],
      :a2 => [0],
      :a3 => [0],
      :a4 => [0],
      :a5 => [0],
      :b  => [0],
      :c  => [0],
      :d  => [0],
      :e  => [0]
  }

  MAPS = {
      :a1 => [],
      :a2 => [
          #[[31, 32, 33, 34, 35, 36, 37, 38, 39, 40], 1]
      ],
      :a3 => [],
      :a4 => [],
      :a5 => [],
      :b  => [],
      :c  => [],
      :d  => [],
      :e  => []
  }

  def self.has_map?(sym, map_id)
    return false if MAPS[sym].empty?
    for segment in MAPS[sym]
      next if segment.empty?
      return true if segment[0].include?(map_id)
    end
    return false
  end

  def self.get_map(sym, map_id)
    return '' if MAPS[sym].empty?
    for segment in MAPS[sym]
      next if segment.empty?
      return segment[1].to_s if segment[0].include?(map_id)
    end
    return ''
  end

  def self.get_replacement_id(sym, map_id)
    return get_map(sym, map_id)
  end

end