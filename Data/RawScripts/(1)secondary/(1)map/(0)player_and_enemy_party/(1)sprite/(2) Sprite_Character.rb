#==============================================================================
# ** Sprite_Character
#------------------------------------------------------------------------------
#  This sprite is used to display characters. It observes a instance of the
# Game_Character class and automatically changes sprite conditions.
#==============================================================================
class Sprite_Character < Sprite_Base
  #--------------------------------------------------------------------------
  # * Constants
  #--------------------------------------------------------------------------
  BALLOON_WAIT = 12                      # Final balloon frame wait time
  WHITEN        = 1                      # Flash white (start action)
  BLINK         = 2                      # Blink (damage)
  APPEAR        = 3                      # Appear (appear, revive)
  DISAPPEAR     = 4                      # Disappear (escape)
  COLLAPSE      = 5                      # Collapse (incapacitated)
  FLASH_RED     = 6
  FLASH_GREEN   = 7
  RESURRECT     = 8
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_accessor :character
  attr_accessor :new_sprite
  attr_reader   :stored_id
  attr_reader   :effect_duration
  attr_accessor :battle_numerics
  #--------------------------------------------------------------------------
  # * Object Initialization
  #     viewport  : viewport
  #     (0)character : (0)character (Game_Character)
  #--------------------------------------------------------------------------
  def initialize(viewport, character = nil)
    super(viewport)
    @character = character
    @stored_id = @character.__id__
    @balloon_duration = 0
    @new_sprite = false
    @effect_duration = 0
    @numeric_color = nil
    @battler_visible = true
    @attack_tiles = []
    @last_x = 0
    @last_y = 0
    @leader_sprite = nil
    @individual_sprite = nil
    @hidden = false
    @collapsed = false
    @item_id = -1
    @animation_sequence = []
    @targeting_battlers = []
    @shove_startup_counter = 0
    @shove_interval = 0
    @battle_numerics = []
    if !@character.battler.nil? && @character.battler.dead?
      @battler_visible = false
      self.bitmap = Bitmap.new(2,2)
    end
    update
  end
  #--------------------------------------------------------------------------
  # overwrite method: update_src_rect
  #--------------------------------------------------------------------------
  alias n_update_src_rect update_src_rect unless $@
  def update_src_rect
    n_update_src_rect
  end

  def perform_shove_startup
    @shove_startup_counter += 1
    # shove interval = potential shove frames
    if @shove_startup_counter >= 16 && @shove_interval < 2
      @shove_interval += 1
      @shove_startup_counter = 0
    else
      @shove_startup_counter += 1
    end
    self.src_rect.set((6+@shove_interval)*@cw, 6*@ch, @cw, @ch)
  end

  def perform_shove_cooldown
    @shove_counter += 1
    if @shove_counter >= 16
      @shove_interval -= 1
      @shove_counter = 0
    else
      @shove_counter += 1
    end
    self.src_rect.set((6+@shove_interval)*@cw, 6*@ch, @cw, @ch)
  end


  #--------------------------------------------------------------------------
  # * SE and Flash Timing Processing
  #     timing : timing data ((0X)RPG.rb::Animation::Timing)
  #--------------------------------------------------------------------------
  def animation_process_timing(timing)
    if timing.se.name != '0CHAR_DIR'
      timing.se.play
      case timing.flash_scope
        when 1
          self.flash(timing.flash_color, timing.flash_duration * 4)
        when 2
          if viewport != nil
            viewport.flash(timing.flash_color, timing.flash_duration * 4)
          end
        when 3
          self.flash(nil, timing.flash_duration * 4)
      end
    else
      # Function used to set the src_rect if the sound effect uses the 0CHAR_DIR name.
      self.src_rect.set(timing.flash_color.red * @cw, timing.flash_color.green * @ch, @cw, @ch)
    end
  end

  #--------------------------------------------------------------------------
  # * Dispose
  #--------------------------------------------------------------------------
  def dispose
    dispose_balloon
    dispose_bar
    dispose_icon
    @character.battle_numerics.each { |numeric| numeric.dispose if numeric != nil } if @character != nil
    @character.battler.clear_everything if @character != nil && @character.battler != nil
    dispose_battle_rects
    super
  end

  def dispose_battle_rects
    dispose_battle_grid
    dispose_individual_rect
    dispose_bar
  end

  def dispose_battle_grid
    @leader_sprite.bitmap.clear unless @leader_sprite.nil?
    @leader_sprite.dispose unless @leader_sprite.nil?
    @leader_sprite = nil
  end

  def dispose_individual_rect
    @individual_sprite.bitmap.clear unless @individual_sprite.nil?
    @individual_sprite.dispose unless @individual_sprite.nil?
    @individual_sprite = nil
  end

  #--------------------------------------------------------------------------
  # * Dispose of Balloon Icon
  #--------------------------------------------------------------------------
  def dispose_balloon
    if @balloon_sprite != nil
      @balloon_sprite.dispose
      @balloon_sprite = nil
    end
  end

  def dispose_bar
    unless @bar_sprite.nil?
      @bar_sprite.dispose
      @bar_sprite = nil
    end
  end

  def hide
    self.bitmap.clear unless self.bitmap.nil?
    dispose_balloon
    dispose_bar
    dispose_battle_rects
    dispose_battle_grid
    dispose_icon
    dispose_individual_rect
    dump_battle
  end

  def animation?
    return (@animation != nil ||
        #!@character.battle_numerics.empty? ||
        @effect_duration > 0 ||
        @animation_list.size > 0)
  end

=begin
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  def update
    super()
    update_bitmap
    self.visible = (not @character.transparent)
    update_src_rect
    self.x = @character.screen_x
    self.y = @character.screen_y
    self.z = @character.screen_z unless @character.is_a?(Game_Player)
    self.opacity = @character.opacity
    self.blend_type = @character.blend_type
    self.bush_depth = @character.bush_depth
    setup_new_effect
    update_effect
    update_balloon
    update_icon
    update_battle_numerics

    update_attack_tiles unless @attack_tiles.empty?

    update_battle_animations

    if @character.animation_id > 0
      animation = $data_animations[@character.animation_id]
      start_animation(animation)
      @character.animation_id = 0
    end
    if @character.balloon_id != 0
      @balloon_id = @character.balloon_id
      start_balloon
      @character.balloon_id = 0
    end
    if @icon_sprite.nil?
      start_icon
    end
    if $game_temp.in_battle
      update_leader_grid if @character.leader?
      update_single_rect
      update_bar
    else
      dispose_battle_rects
    end
  end
=end
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  def update
    super()
    update_bitmap
    self.visible = (not @character.transparent)
    update_src_rect
    self.x = @character.screen_x
    self.y = @character.screen_y
    self.z = @character.screen_z unless @character.is_a?(Game_Player)
    self.opacity = @character.opacity
    self.blend_type = @character.blend_type
    self.bush_depth = @character.bush_depth
    setup_new_effect
    update_effect
    update_balloon
    update_icon
    update_battle_numerics
    update_attack_tiles unless @attack_tiles.empty?
    update_battle_animations
    update_addons
  end

  def update_addons
    if @character.animation_id > 0
      animation = $data_animations[@character.animation_id]
      start_animation(animation)
      @character.animation_id = 0
    end
    if @character.balloon_id != 0
      @balloon_id = @character.balloon_id
      start_balloon
      @character.balloon_id = 0
    end
    if @icon_sprite.nil?
      start_icon
    end
    if $game_temp.in_battle
      update_leader_grid if @character.leader?
      update_single_rect
      update_bar
    else
      dispose_battle_rects
    end
  end


  def update_battle_animations
    unless @character.battle_animations.empty?
      if !@character.battle_animations[0].is_a?(Array)
        animation = $data_animations[@character.battle_animations.shift]
      else
        p 'testing animation'
        ani_data = @character.battle_animations.shift
        ani_id = ani_data.shift
        target_id = ani_data.shift
        animation = $data_animations[ani_id]
        unless @targeting_battlers.include?(target_id)
          @targeting_battlers.push target_id
        end
      end
      start_f_animation(animation)
    end
  end

  def animation_from_this_battler?(battler_id)
    for i in 0...@targeting_battlers.size
      return true if @targeting_battlers[i][1] == battler_id
    end
    return false
  end

  def popup_from_this_battler?(battler_id)
    for popup in @character.battle_numerics
      next if popup.nil?
      return true if popup.matching_host?(battler_id)
    end
    return false
  end

  def update_single_rect
    return if @character.battler.nil?
    if $game_party.get_leader.battle_range.inside?(@character.x, @character.y)
      @individual_sprite.nil? ? start_individual_rect : update_individual_rect
    else
      dispose_individual_rect
    end
  end

  def update_leader_grid
    return if $game_party.leader != @character
    @leader_sprite.nil? ? start_grid : update_grid
  end

  def update_individual_rect
    if @character.battler.dead?
      return if @individual_sprite.nil?
      @individual_sprite.dispose
      @individual_sprite = nil
      return
    else
      @individual_sprite.x = x
      @individual_sprite.y = y
      @individual_sprite.update
    end
  end

  def start_individual_rect
    @individual_sprite = ::Sprite.new(self.viewport)
    @individual_sprite.bitmap = Bitmap.new(64,64)
    if @character.is_a?(Game_Event) && !@character.battler.nil?
      @individual_sprite.bitmap.fill_ellipse(Ellipse.new(0,0,16), PHI.color(:RED, 45))
      @backup_z = self.z - 1 if @backup_z.nil?
      self.z = @backup_z if self.z != @backup_z
    elsif @character.is_a?(Game_Player)
      @individual_sprite.bitmap.fill_ellipse(Ellipse.new(0,0,16), PHI.color(:BLUE, 45))
    end
    @individual_sprite.x = x
    @individual_sprite.y = y
    @individual_sprite.ox = 16
    @individual_sprite.oy = 32
  end

  def start_grid
    @leader_sprite = ::Sprite.new
    @leader_sprite.x = x - (@character.battle_range.width * 32 / 2)
    @leader_sprite.y = y - (@character.battle_range.height * 32 / 2) - 16
    @leader_sprite.bitmap = Bitmap.new(@character.battle_range.width*32,@character.battle_range.height*32)
    @leader_sprite.z = self.z - 2
    @leader_sprite.bitmap.clear
    @leader_sprite.bitmap.fill_rect(0, 0, @character.battle_range.width * 32, @character.battle_range.height * 32, PHI.color(:BLACK, 35))
    @leader_sprite.update
    for x in 0...@character.battle_range.width
      for y in 0...@character.battle_range.height
        rect = Rect.new(x*32,y*32,32,32)
        rect.x += 1
        rect.y += 1
        rect.width -= 2
        rect.height -= 2
        @leader_sprite.bitmap.fill_rect(rect, PHI.color(:RED, 30))
      end
    end
  end

  def update_grid
    return if @leader_sprite.nil?
    @leader_sprite.x = x - (@character.battle_range.width * 32 / 2)
    @leader_sprite.y = y - (@character.battle_range.height * 32 / 2) - 16
    @leader_sprite.update
  end

  def update_attack_tiles
    return if @attack_tiles.empty?
    for i in 0...@attack_tiles.size
      sprite = @attack_tiles[i]
      next if sprite.nil?
      if sprite.done?
        sprite.dispose
        @attack_tiles[i] = nil
      else
        sprite.x = @character.screen_x - 16 - ((sprite.offset.x * 32) + (sprite.offset.x * 32) % 32)
        sprite.y = @character.screen_y - 16 - ((sprite.offset.y * 32) + (sprite.offset.y * 32) % 32)
        sprite.update
      end
    end
    @attack_tiles.compact!
  end

  def dump_battle
    @attack_tiles.each { |tile| tile.dispose; } unless @attack_tiles.nil?
    @attack_tiles.clear unless @attack_tiles.nil?
    dispose_animation
  end
  #--------------------------------------------------------------------------
  # Converts map xy to window xy
  def to_window_xy(x,y)
    w = get_window_pos
    outx, outy = x - w[0], y - w[1]
    return [outx, outy]
  end

  # Gets the upper left corner xy of the window, on the map.
  def get_window_pos
    outx, outy = @character.x - 10, @character.y - 7
    outx = 0 if outx < 0
    outx = $game_map.width - 20 if outx > $game_map.width - 20
    outy = 0 if outy < 0
    outy = $game_map.height - 15 if outy > $game_map.height - 15
    return [outx, outy]
  end

  def update_battle_numerics
    if @character.battle_numerics.size > 0
      for i in 0...@character.battle_numerics.size
        numeric_data = @character.battle_numerics[i]
        character = numeric_data[0]
        attacker = numeric_data[1]
        hp = numeric_data[2]
        text = hp.to_s
        sprite = Sprite_NumericPopup.new
        sprite.set_host(attacker.id)
        if hp > 0; color = PHI.color(:WHITE) else color = PHI.color(:RED) end
        sprite.set_number(character, text, color)
        sprite.oy += 48
        @battle_numerics.push sprite
      end
      @character.battle_numerics.clear
    end
    for i in 0...@battle_numerics.size
      unless @battle_numerics[i].nil?
        if @battle_numerics[i].executing
          @battle_numerics[i].dispose
          @battle_numerics[i] = nil
        else
          @battle_numerics[i].x = self.x
          @battle_numerics[i].y = self.y
          @battle_numerics[i].z = self.z + 1000
          @battle_numerics[i].update
        end
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Get tile set image that includes the designated tile
  #     tile_id : Tile ID
  #--------------------------------------------------------------------------
  def tileset_bitmap(tile_id)
    set_number = tile_id / 256
    return Cache.system("TileB") if set_number == 0
    return Cache.system("TileC") if set_number == 1
    return Cache.system("TileD") if set_number == 2
    return Cache.system("TileE") if set_number == 3
    return nil
  end
  #--------------------------------------------------------------------------
  # * Update Transfer Origin Bitmap
  #--------------------------------------------------------------------------
  def update_bitmap
    if @tile_id != @character.tile_id or
       @character_name != @character.character_name or
       @character_index != @character.character_index or
       (@character.is_a?(Game_Event) && @item_id != @character.item_id)
      @tile_id = @character.tile_id
      @item_id = @character.item_id if @character.is_a?(Game_Event)
      @character_name = @character.character_name
      @character_index = @character.character_index
      set_bitmap_params
    end
  end
  
  def set_bitmap_params
    if @tile_id > 0
      sx = (@tile_id / 128 % 2 * 8 + @tile_id % 8) * 32
      sy = @tile_id % 256 / 8 % 16 * 32
      self.bitmap = tileset_bitmap(@tile_id)
      self.src_rect.set(sx, sy, 32, 32)
      self.ox = 16
      self.oy = 32
    elsif @item_id > -1
      self.bitmap = Cache.system("Iconset2")
      rect = Rect.new($data_items[@item_id].icon_index % 16 * 32, $data_items[@item_id].icon_index / 16 * 32, 32, 32)
      self.src_rect.set(rect.x, rect.y, 32, 32)
      self.ox = 16
      self.oy = 32
    else
      self.bitmap = Cache.character(@character_name).clone
      sign = @character_name[/^[\!\$\~]./]
      if sign != nil and sign.include?('$')
        @cw = bitmap.width / 3
        @ch = bitmap.height / 4
        self.ox = @cw / 2
        self.oy = @ch
      elsif sign != nil and sign.include?('~')
        @cw = bitmap.width / 14
        @ch = bitmap.height / 17
        self.ox = @cw / 2
        self.oy = @ch
      else
        @cw = bitmap.width / 12
        @ch = bitmap.height / 8
        self.ox = @cw / 2
        self.oy = @ch
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Update Transfer Origin Rectangle
  #--------------------------------------------------------------------------
  #def update_src_rect
    #deprecated
    #if @tile_id == 0 && @item_id == -1
    #  if @character.shoved?
    #    self.src_rect.set(6*@cw, 6*@ch, @cw, @ch)
    #  elsif !@character.is_a?(Game_Player) && @character.dead?
    #  else
    #    index = @character.character_index
    #    pattern = @character.pattern < 3 ? @character.pattern : 1
    #    sx = (index % 4 * 3 + pattern) * @cw
    #    sy = (index / 4 * 4 + (@character.direction - 2) / 2) * @ch
    #    self.src_rect.set(sx, sy, @cw, @ch)
    #  end
    #end
  #end
  #--------------------------------------------------------------------------
  # * Start Balloon Icon Display
  #--------------------------------------------------------------------------
  def start_balloon
    dispose_balloon
    @balloon_duration = 8 * 8 + BALLOON_WAIT
    @balloon_sprite = ::Sprite.new(viewport)
    @balloon_sprite.bitmap = Cache.system("Balloon")
    @balloon_sprite.ox = 16
    @balloon_sprite.oy = 32
    update_balloon
  end
  #--------------------------------------------------------------------------
  # * Update Balloon Icon
  #--------------------------------------------------------------------------
  def update_balloon
    if @balloon_duration > 0
      @balloon_duration -= 1
      if @balloon_duration == 0
        dispose_balloon
      else
        @balloon_sprite.x = x
        @balloon_sprite.y = y - height
        @balloon_sprite.z = z + 200
        if @balloon_duration < BALLOON_WAIT
          sx = 7 * 32
        else
          sx = (7 - (@balloon_duration - BALLOON_WAIT) / 8) * 32
        end
        sy = (@balloon_id - 1) * 32
        @balloon_sprite.src_rect.set(sx, sy, 32, 32)
      end
    end
  end
  
  def create_bar
    dispose_bar
    @bar_sprite = ::Sprite.new(viewport)
    @bar_sprite.bitmap = Bitmap.new(32,12)
    @bar_sprite.ox = @bar_sprite.width/2
    @bar_sprite.oy = 12
    update_bar
  end
  
  def update_bar_graphic
    @bar_sprite.bitmap.clear
    actor = @character.battler
    return if actor.dead?
    @bar_sprite.x = x
    @bar_sprite.y = y - height
    @bar_sprite.z = z + 500
    actor.maxhp > 0 ? mhp = actor.maxhp : mhp = 1
    actor.maxmp > 0 ? mmp = actor.maxmp : mmp = 1
    actor.maxstamina > 0 ? msp = actor.maxstamina : msp = 1
    whp = @bar_sprite.width * actor.hp / mhp; whp = 0 if actor.maxhp == 0
    wmp = @bar_sprite.width * actor.mp / mmp; wmp = 0 if actor.maxmp == 0
    wsp = @bar_sprite.width * actor.stamina / msp; wsp = 0 if actor.maxstamina == 0
    div = 1; div += 1 if wmp > 0; div += 1 if wsp > 0
    back_rect = Rect.new(0, 0, @bar_sprite.width, @bar_sprite.height)
    health_rect = Rect.new(1, 1, whp-2, @bar_sprite.height / div-2)
    mp_rect = Rect.new(1, 1+@bar_sprite.height / div, wmp-2, @bar_sprite.height / div-2)
    stam_rect = Rect.new(1, 1+(@bar_sprite.height / div) * 2, wsp-2, @bar_sprite.height / div-2)
    @bar_sprite.bitmap.fill_rect(back_rect, PHI.color(:BLACK, 200))
    @bar_sprite.bitmap.fill_rect(health_rect, PHI.color(:GREEN, 200))
    @bar_sprite.bitmap.fill_rect(mp_rect, PHI.color(:CYAN, 200))
    @bar_sprite.bitmap.fill_rect(stam_rect, PHI.color(:YELLOW, 200))
  end
  
  def update_bar
    return if @character.battler.nil?
    if $game_temp.in_battle
      @bar_sprite.nil? ? create_bar : update_bar_graphic
    else
      dispose_bar
    end
  end

  def start_icon
    dispose_icon
    return unless @character.is_a?(Game_Player)
    return if @character.added_item.nil?
    @icon_sprite = ::Sprite.new(viewport)
    @icon_sprite.bitmap = Bitmap.new(32,32)
    i_bitmap = Cache.system("Iconset2")
    i_icon_index = @character.added_item.icon_index
    i_rect = Rect.new(i_icon_index % 16 * 32, i_icon_index / 16 * 32, 32, 32)
    @icon_sprite.bitmap.blt(0, 0, i_bitmap, i_rect, 255)
    @icon_sprite.x = x
    @icon_sprite.y = y
    @icon_sprite.z = z + 500
    @icon_sprite.ox = 102
    @icon_sprite.oy = 16
    @icon_sprite_timer = 60
    update_icon
  end
  
  def update_icon
    return if @icon_sprite.nil? or !@character.is_a?(Game_Player)
    @icon_sprite_timer -= 1
    if @text_sprite.nil?
      @text_sprite = ::Sprite.new(viewport)
      @text_sprite.bitmap = Bitmap.new(140,32)
      @text_sprite.x = x
      @text_sprite.y = y
      @text_sprite.z = z + 500
      @text_sprite.ox = @text_sprite.bitmap.width/2
      @text_sprite.oy = @icon_sprite.oy
      @text_sprite.bitmap.draw_text(0,0,140,32,@character.added_item.name)
    end
    if @icon_sprite_timer <= 0
      dispose_icon
    else
      @icon_sprite.x = x
      @icon_sprite.y = y
      @text_sprite.x = x
      @text_sprite.y = y
      if @icon_sprite_timer % 20 == 0
        @text_sprite.ox += 1 unless @text_sprite.nil?
        @icon_sprite.oy += 1 
      end
    end
  end

  def dispose_icon
    unless @icon_sprite.nil?
      @icon_sprite.dispose
      @icon_sprite = nil
      @character.added_item = nil
    end
    unless @text_sprite.nil?
      @text_sprite.dispose
      @text_sprite = nil
    end
  end
    #--------------------------------------------------------------------------
  # * Set New Effect
  #--------------------------------------------------------------------------
  def setup_new_effect
    return if @character.battler == nil
    if @character.battler.white_flash
      p "White flash"
      @effect_type = WHITEN
      @effect_duration = 16
      @character.battler.white_flash = false
    end
    if @character.battler.blink
      p "Blink"
      @effect_type = BLINK
      @effect_duration = 20
      @character.battler.blink = false
    end
    if not @battler_visible and @character.battler.exist? and @character.battler.appear
      p "Appear"
      @effect_type = APPEAR
      @effect_duration = 16
      @battler_visible = true
    end
    if @battler_visible and @character.battler.hidden
      p "disappear"
      @effect_type = DISAPPEAR
      @effect_duration = 32
      @battler_visible = false
    end
    if @character.battler.collapse
      p "Collapse"
      @effect_type = COLLAPSE
      @effect_duration = 48
      @character.battler.collapse = false
      @battler_visible = false
    end
    if @character.battler.red_flash
      p "Red flash"
      @effect_type = FLASH_RED
      @effect_duration = 30
      @character.battler.red_flash = false
    end
    if @character.battler.green_flash
      p "Green flash"
      @effect_type = FLASH_GREEN
      @effect_duration = 30
      @character.battler.green_flash = false
    end
    if @character.battler.resurrect
      p "Resurrect"
      @effect_type = RESURRECT
      @effect_duration = 30
      @character.battler.resurrect = false
    end
    if @character.battler.animation_id != 0
      animation = $data_animations[@character.battler.animation_id]
      mirror = @character.battler.animation_mirror
      start_animation(animation, mirror)
      @character.battler.animation_id = 0
    end
  end
  #--------------------------------------------------------------------------
  # * Update Effect
  #--------------------------------------------------------------------------
  def update_effect
    if @effect_duration > 0
      @effect_duration -= 1
      case @effect_type
        when WHITEN
          update_whiten
        when BLINK
          update_blink
        when APPEAR
          update_appear
        when DISAPPEAR
          update_disappear
        when COLLAPSE
          update_collapse
        when FLASH_RED
          update_red_flash
        when FLASH_GREEN
          update_green_flash
        when RESURRECT
          update_resurrection
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Update White Flash Effect
  #--------------------------------------------------------------------------
  def update_whiten
    self.blend_type = 0
    self.color.set(255, 255, 255, 128)
    self.opacity = 255
    self.color.alpha = 128 - (16 - @effect_duration) * 10
  end
  #--------------------------------------------------------------------------
  # * Update Blink Effect
  #--------------------------------------------------------------------------
  def update_blink
    self.blend_type = 0
    self.color.set(255, 0, 0, 0)
    self.opacity = 255
    self.visible = (@effect_duration % 10 < 5)
  end
  #--------------------------------------------------------------------------
  # * Update Appearance Effect
  #--------------------------------------------------------------------------
  def update_appear
    self.blend_type = 0
    self.color.set(0, 0, 0, 0)
    self.opacity = (16 - @effect_duration) * 16
  end
  #--------------------------------------------------------------------------
  # * Updated Disappear Effect
  #--------------------------------------------------------------------------
  def update_disappear
    self.blend_type = 0
    self.color.set(0, 0, 0, 0)
    self.opacity = 256 - (32 - @effect_duration) * 10
  end
  #--------------------------------------------------------------------------
  # * Update Collapse Effect
  #--------------------------------------------------------------------------
  def update_collapse
    self.blend_type = 1
    self.color.set(255, 128, 128, 128)
    self.opacity = 256 - (48 - @effect_duration) * 6
  end

  def update_green_flash
    self.blend_type = 1
    self.color.set(255, 0, 0, 128)
    self.color.alpha = 128 - (16 - @effect_duration) * 10
  end

  def update_red_flash
    self.blend_type = 1
    self.color.set(0, 255, 0, 128)
    self.color.alpha = 128 - (16 - @effect_duration) * 10
  end

  def update_resurrection
    self.blend_type = 1
    self.color.set(self.color.red, 64, self.color.blue, 255)
    self.opacity = (@effect_duration * 6)
    if @effect_duration == 1 or @effect_duration == 0
      self.opacity = 255
      self.color = Color.new(0, 0, 0, 255)
    end
  end

end