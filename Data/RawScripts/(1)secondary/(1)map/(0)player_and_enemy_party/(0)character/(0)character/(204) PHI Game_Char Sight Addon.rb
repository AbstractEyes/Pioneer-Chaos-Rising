class Game_Character
  attr_reader   :sight
  attr_reader   :battle_range
  attr_reader   :sight_range
  attr_reader   :moving
  attr_reader   :stopped
  attr_accessor :battler
  attr_accessor :battle_animations
  attr_accessor :battle_character_animation
  attr_accessor :battle_numerics
  attr_accessor :trail
  attr_accessor :unit_number
  attr_reader   :in_line
  attr_accessor :leader
  attr_accessor :unit_leader
  attr_reader   :last_direction
  attr_accessor :moved
  attr_accessor :added_item
  alias char_battle_initialize initialize
  def initialize(*args)
    char_battle_initialize(*args)
    @attack_grid = false
    @battle_start_range = PHI::BATTLE_CFG::SIGHT_RANGE
    @battle_sight_range = PHI::BATTLE_CFG::BATTLE_RANGE
    # Checks if the (0)character is in battle.
    #@battle_range.add_matrix(Line_Matrix.new(@x, @y, @direction, 7))
    @battle_range = Player_Sight.new(self)
    @battle_range.add_matrix(Rect_Matrix.new(self.x, self.y, @battle_sight_range))
    @sight_range = Player_Sight.new(self)
    @sight_range.add_matrix(Rect_Matrix.new(self.x, self.y, @battle_start_range))
    @in_battle = false
    @battle_animations = []
    @battle_numerics = []
    @trail = []
    @in_line = true
    @last_direction = -1
    @moved = false

    enable_sight
  end

  def is_enemy?
    return @battler_id.is_a?(String) && !self.is_player?
  end

  def dead?
    return false if @battler.nil?
    return @battler.dead?
  end

  def is_item?
    return false
  end

  def xy
    return Coord.new(@x,@y)
  end
  
  def enable_sight
    @attack_grid = true
    @battle_range.enables
  end
  
  def disable_sight
    @attack_grid = false
    @battle_range.disable
  end
  
  def relative_screen_x(new_x)
    new_x = new_x * 256
    return ($game_map.adjust_x(new_x) + 8007) / 8 - 1000 + 16
  end
  #--------------------------------------------------------------------------
  # * Get Screen Y-Coordinates
  #--------------------------------------------------------------------------
  def relative_screen_y(new_y)
    new_y = new_y * 256
    y = ($game_map.adjust_y(new_y) + 8007) / 8 - 1000 + 32
    y -= 4 unless object?
    if @jump_count >= @jump_peak
      n = @jump_count - @jump_peak
    else
      n = @jump_peak - @jump_count
    end
    return y - (@jump_peak * @jump_peak - n * n) / 2
  end

  def update
    @trail = [] if @trail.nil?
    @trail.clear unless self.leader?
    @battle_range.move(self.x, self.y, self.direction)
    @sight_range.move(self.x, self.y, self.direction)
  end
  
  def in_sight?(character)
    return false if @battle_range.nil?
    return false if character.nil?
    return @battle_range.inside?(character.x, character.y)
  end

  def is_player?
    return self.is_a?(Game_Player)
  end
  
  def is_event?
    return self.is_a?(Game_Event)
  end
  
  def is_monster?
    return self.tags.include?('monster')
  end

  def is_a_item?
    return false
  end

  #--------------------------------------------------------------------------
  # * Determine if Passable
  #     x : x-coordinate
  #     y : y-coordinate
  #--------------------------------------------------------------------------
  def passable?(x, y)
    x = $game_map.round_x(x)                        # Horizontal loop adj.
    y = $game_map.round_y(y)                        # Vertical loop adj.
    return false unless $game_map.valid?(x, y)      # Outside map?
    return true if @through or debug_through?       # Through ON?
    return false unless map_passable?(x, y)         # Map Impassable?
    return false if collide_with_characters?(x, y)  # Collide with (0)character?
    #p x.inspect, y.inspect if x.is_a?(Array) or y.is_a?(Array)
    return false if collide_with_players?(x, y)
    return true                                     # Passable
  end
  
  def collide_with_players?(x, y)
    return false if self.is_a?(Game_Player) or $game_temp.in_battle
    for member in $game_party.players.values
      return true if (member.x == x && member.y == y)
    end
    return false
  end  

end

class Game_Event < Game_Character
  def is_mining_spot?
    return self.name.include?('rock')
  end
  def is_fishing_spot?
    return self.name.include?('fish')
  end
  def is_tree_spot?
    return self.name.include?('tree')
  end
  def is_elemental_spot?
    return self.name.include?('element')
  end
  def is_a_item?
    return self.name == 'item'
  end

  def is_item?
    return false if self.list.size == 1
    id = -1
    for command in self.list
      if command.code == 126
        id = command.parameters[0]
      end
    end
    return is_a_item? && id >= 0
  end

  def get_item
    return -1 unless is_a_item?
    id = -1
    for command in self.list
      if command.code == 126
        id = command.parameters[0]
        break
      end
    end
    return id
  end

end