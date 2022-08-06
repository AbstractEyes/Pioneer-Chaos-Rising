class Window_BattlerMacros < Window_Selectable
  attr_reader   :position

  def initialize(x,y,width,height)
    super(x,y,width,height)
    @spacing = 0
    @help = Window_MacroHelp.new(x+32*4,y-8,width,32+24)
    @help.opacity = 100
    self.index = 0
    self.visible = false
    self.active = false
    self.opacity = 0
    @last_index = -1
    @wlh2 = 32
    @position = 0
  end

  def update
    @help.update unless @help.nil? || @help.disposed?
    if self.index != @last_index
      p 'updating battler macros'
      @help.width = self.contents.text_size(macro[1][2]).width unless macro.nil?
      @help.draw_text(macro[1][2], normal_color) unless macro.nil?
      @last_index = self.index
      $game_index.macro_index = @last_index
    end
    super
  end

  def dispose
    @help.dispose unless @help.nil? || @help.disposed?
    super
  end
  def width=(new_width)
    return if new_width.nil?
    @help.width = new_width unless @help.nil?
    super
  end
  def visible=(new_visible)
    return if new_visible.nil?
    @help.visible = new_visible
    super
  end

  #def index=(new_index)
  #  $game_index.macro_index = new_index
  #  @index = new_index
  #end

  #def index
  #  return $game_index.macro_index
  #end

  def macro_key
    return @data[self.index][0]
  end

  def has_member?
    return member != nil
  end

  def last
    clear_last_position
    member.action.clear
  end

  def macro
    return @data[self.index] unless @data.nil? || self.index < 0
    return nil
  end

  def done?
    return @position < 0
  end

  def has_ready_member?
    for pos in 0...party.size
      return true if party[pos].battler.action.nothing_selected? && party[pos].battler.action.atb_full? && !party[pos].battler.action.performing?
    end
    return false
  end

  def next_active_position
    @position = -1
    for pos in 0...party.size
      if party[pos].battler.action.nothing_selected? && party[pos].battler.action.atb_full?
        @position = pos
        break
      end
    end
  end

  def clear_last_position
    temp_pos = -1
    for pos in 0...party.size
      temp_pos = [temp_pos, pos].max if !party[pos].battler.action.nothing_selected? && party[pos].battler.action.atb_full? && !party[pos].battler.action.performing?
    end
    party[temp_pos].battler.action.clear if temp_pos > -1
    next_active_position
  end

  def party
    return $game_party.sorted_players
  end

  def refresh
    p "Position: " + @position.to_s
    self.contents.clear
    @data = PHI::PLAYER_MACROS::MACRO_VALUES
    @data = @data.sort { |a,b| a[1][0] <=> b[1][0] }
    self.width = @data.size * 32 + 16
    @help.width = self.contents.text_size(macro[1][2]).width unless macro.nil?
    @help.draw_text(macro[1][2], normal_color)
    @column_max = @data.size
    @item_max = @data.size
    create_contents
    self.index = -1
    for i in 0...@item_max
      draw_macro(i)
    end
    self.index = $game_index.macro_index
  end
  
  def draw_macro(index)
    rect = item_rect(index)
    macro_icon = @data[index][1][1]
    color = PHI.color(:BLACK)
    self.contents.fill_rect(rect, color)
    rect.x, rect.y, rect.width, rect.height = rect.x + 1, rect.y + 1, rect.width - 2, rect.height - 2
    color = PHI.color(:BLACK)
    color.alpha = 120
    self.contents.fill_rect(rect, color)
    self.draw_map_icon(macro_icon, rect.x-4, rect.y-1)
  end

  def member
    #Todo: get lowest numerical member with full atb bar.
    return nil if character.nil?
    return character.battler
  end

  def character
    return nil if @position < 0
    return party[@position]
  end

  def set_movement
    member.battle_movement = !member.battle_movement
  end

  def battle_movement?
    return !character.nil? && character.battler.battle_movement
  end

end