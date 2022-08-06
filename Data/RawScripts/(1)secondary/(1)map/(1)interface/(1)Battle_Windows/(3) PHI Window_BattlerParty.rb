class TempStats
  attr_accessor :hp
  attr_accessor :mp
  attr_accessor :atb
  attr_accessor :stamina
  attr_accessor :first
  attr_accessor :atb_ready

  def initialize
    self.hp = 0
    @last_hp = -1
    self.mp = 0
    @last_mp = -1
    self.atb = 0
    @last_atb = -1
    self.first = true
    @last_stamina = -1
    self.atb_ready = false
  end

  def set(hp, mp, atb, stamina)
    @last_hp = self.hp
    self.hp = hp
    @last_mp = self.mp
    self.mp = mp
    @last_atb = self.atb
    self.atb = atb
    @last_stamina = self.stamina
    self.stamina = stamina
  end

  def first?
    out = self.first
    self.first = false
    return out
  end

  def hp?
    self.hp != @last_hp
  end

  def mp?
    self.mp != @last_mp
  end

  def stamina?
    self.stamina != @last_stamina
  end

  def atb?
    if self.atb != @last_atb
      self.atb_ready = false
      return true
    else
      self.atb_ready = true
      return false
    end
  end

end

class ATB_Circle < Sprite

  def initialize(viewport, pos)
    super(viewport)
    @pos = pos
    @counter = 0
    @iteration = 10
    self.bitmap = Bitmap.new(60,60)
    self.z = 10001
    @index = 0
    @last_index = -1
  end

  def update
    super
    return if member.nil?
    if @counter < @iteration
      @counter += 1
    else
      #@done = member.action.atb == BATTLE_DATA::ATB_TIMER
      #if !member.action.atb_full? || !member.action.skill_startup_complete? || !member.action.skill_cooldown_complete?
      #  self.bitmap.clear if @circle_drawn
      #  @circle_drawn = false
      #end
      draw_circle
    end
  end

  def ready_to_draw?
    return member.action.atb_full? || member.action.skill_startup_complete?
  end

  def member
    return $game_party.members[@pos]
  end

  def trip_bools?
    if @index != @last_index
      @last_index = @index
      return true
    end
    return false
  end

  def draw_circle
    self.bitmap.draw_circle(20, 20, 10, PHI.color(:BLACK, 255), 4, 1, 1)
    if !member.action.skill_startup_complete?
      @index = 0
      fill_tripped_text('Startup') if trip_bools?
      self.bitmap.draw_circle(20, 20, 10, PHI.color(:BLUE), 4, member.action.s_startup, BATTLE_DATA::SKILL_TIMER)
    elsif !member.action.skill_cooldown_complete?
      @index = 1
      fill_tripped_text('Cooldown') if trip_bools?
      self.bitmap.draw_circle(20, 20, 10, PHI.color(:CYAN), 4, member.action.s_cooldown, BATTLE_DATA::COOLDOWN_TIMER)
    elsif member.action.performing? && member.action.atb_full?
      @index = 2
      fill_tripped_text('Acting') if trip_bools?
      self.bitmap.draw_circle(20, 20, 10, PHI.color(:GREEN), 4, member.action.s_cooldown, BATTLE_DATA::COOLDOWN_TIMER)
    else
      if member.action.atb_full?
        if member.battle_movement
          @index = 5
          color = PHI.color(:RED, 125)
          fill_tripped_text('Moving') if trip_bools?
        else
          @index = 3
          color = PHI.color(:RED)
          fill_tripped_text('Ready') if trip_bools?
        end
      else
        color =  PHI.color(:YELLOW)
        @index = 4
        fill_tripped_text('Wait') if trip_bools?
      end
      self.bitmap.draw_circle(20, 20, 10, color, 4, member.action.atb, BATTLE_DATA::ATB_TIMER)
    end
  end

  def fill_tripped_text(text)
    self.bitmap.clear
    size = self.bitmap.font.size
    self.bitmap.font.size = 16
    self.bitmap.draw_text(0, 20, 80, 32, text)
    self.bitmap.font.size = size
  end

end

class Window_BattlerParty < Window_Selectable
  FLASH_TIMER = 12

  def initialize(x,y,width,height)
    x-=16
    super(x,y,width,height)
    @column_max = 1
    @item_max = 5
    @changed = true
    self.visible = true
    @stat_array = {}
    @current_size = 0
    @color_flash = 0
    @increment = true
    self.index = -1
    self.opacity = 0
    @shown = true
    @hidden = false
    @atb_sprites = {}
    @saved_x = x
    @saved_y = y
    @show_count = 0
    @hide_count = 0
    @max_show_count = 40
    update
  end

  def prepare_atb_sprites
    p "preparing atb sprites"
    for i in 0...$game_party.members.size
      next if @atb_sprites.keys.include?(i)
      @atb_sprites[i] = ATB_Circle.new(nil, i)
      @atb_sprites[i].x = item_rect(i).x + 70
      @atb_sprites[i].y = item_rect(i).y + 12
      @atb_sprites[i].z = self.z + 1
    end
    p "done preparing"
  end

  def animate_hide
    return if @hiding or @hidden
    #@saved_x = self.x
    #@saved_y = self.y
    @hiding = true
    @hide_count = @max_show_count
  end

  def animate_show
    return if @showing or @shown
    @showing = true
    @show_count = @max_show_count
  end

  def visible=(new_visible)
    @atb_sprites.each_value {|sprite| sprite.visible = new_visible } unless @atb_sprites.nil?
    super
  end

  def x=(new_x)
    @atb_sprites.each_value {|sprite| sprite.x -= (self.x - new_x) } unless @atb_sprites.nil?
    super
  end

  def y=(new_y)
    @atb_sprites.each_value {|sprite| sprite.y -= (self.y - new_y) } unless @atb_sprites.nil?
    super
  end

  def cursor_movable?
    false
  end

  def index=(n)
    @index = n unless n.nil?
    super
  end

  def animating?
    return (@hiding or @showing)
  end
  
  def update
    super
    if @hiding
      @hide_count -= 1
      if @hide_count > 0
        @hide_count -= 1
        self.x -= 5
      else
        @hiding = false
        @hidden = true
        @shown = false
        self.visible = false
      end
      return
    end
    if @showing
      if @show_count > 0
        @show_count -= 1
        self.visible = true
        if self.x + 5 >= @saved_x
          self.x = @saved_x
          @show_count = 0
        else
          self.x += 5
        end
      else
        @showing = false
        @shown = true
        @hidden = false
        self.x = @saved_x
        self.y = @saved_y
      end
      return
    end
    return unless self.visible
    update_color
    #p 'testing update update'
    #Time.lock(self)
    draw_actors
    #Time.finish
    #self.wait_frame(10)
    #Graphics.wait(2)
  end

  def cursor_up; end
  def cursor_down; end
  def cursor_left; end
  def cursor_right; end
  def cursor_pageup; end
  def cursor_pagedown; end

  def update_color
    @color_flash = 0 if @color_flash.nil?
    if @increment
      @color_flash += 1
    else
      @color_flash -= 1
    end
    if @color_flash <= -BATTLE_DATA::FLASH_TIMER
      @increment = true
    elsif @color_flash >= BATTLE_DATA::FLASH_TIMER
      @increment = false
    end
  end

  def dispose
    @atb_sprites.each_value {|sprite| sprite.dispose}
    @atb_sprites.clear
    @atb_sprites = nil
    super
  end

  def stats(actor)
    unless @stat_array.keys.include?(actor.id)
      set_stats(actor)
    end
    return @stat_array[actor.id]
  end

  def mp?(actor)
    stats(actor).mp?
  end

  def hp?(actor)
    stats(actor).hp?
  end

  def stamina?(actor)
    stats(actor).stamina?
  end

  def atb?(actor)
    stats(actor).atb?
  end

  def first?(actor)
    stats(actor).first?
  end

  def set_stats(actor)
    @stat_array[actor.id] = TempStats.new unless @stat_array.has_key?(actor.id)
    @stat_array[actor.id].set(actor.hp, actor.mp, actor.action.atb, actor.stamina)
  end
  
  def draw_actors
    for i in 0...$game_party.members.size
      if $game_party.members.size != @current_size
        @current_size = $game_party.members.size
        @stat_array.clear
        prepare_atb_sprites
        create_contents
        return
      end
      actor = $game_party.members[i]
      set_stats(actor)
      refresh(actor, i)
    end
    update_atb_sprites
  end

  def update_atb_sprites
    for i in 0...@atb_sprites.size; @atb_sprites[@atb_sprites.keys[i]].update; end;
  end

  def force_refresh
    @stat_array.clear
    prepare_atb_sprites
    @color_flash = 0
    @increment = true
    update
  end

  def refresh(actor, i)
    unless actor.nil?
      rect = item_rect(i)
      rect.x += 8
      rect.y += 8
      rect.width -= 8
      rect.height -= 8
      if hp?(actor) || mp?(actor) || stamina?(actor) || first?(actor)
        # p "numbers updated for " + actor.name
        self.contents.clear_rect(rect)
        update_numbers(actor, rect)
        update_bars(actor, rect, i)
      end
    end
  end
  
  def update_numbers(actor, rect)
    draw_character(actor.character_name, actor.character_index, rect.x+6, rect.y+34)
    draw_actor_name(actor, rect.x+34,rect.y)
    draw_actor_level(actor, rect.x, rect.y+20)
    draw_health_values(actor, rect.x, rect.y+22, rect.width)
    draw_magic_values(actor, rect.x, rect.y+35, rect.width)
    draw_stamina_values(actor, rect.x+16, rect.y+46, rect.width)
  end

  def update_bars(actor, rect, i)
    draw_magic_bar(actor, rect.x,rect.y+52)
    draw_health_bar(actor, rect.x,rect.y+40)
    draw_stamina_bar(actor, rect.x, rect.y+64)
  end

  def draw_actor_level(actor, x, y)
    text = "LVL " + actor.level.to_s
    old_font = self.contents.font.size
    self.contents.font.size = 10
    rect = Rect.new(x, y, self.contents.text_size(text).width, 20)
    self.contents.draw_text(rect, text)
    self.contents.font.size = old_font
  end

  def item_rect(index)
    return Rect.new(
      0,
      self.contents.height/5*index,
      self.contents.width,
      self.contents.height/5
    )
  end

  def draw_actor_name(actor, xi, yi)
    text = actor.name
    self.contents.font.size = 12
    self.contents.font.color = normal_color
    text_width = self.contents.text_size(text).width
    self.contents.draw_text(xi-12,yi,text_width,WLH,text)
  end
  
  def draw_health_values(actor, xi, yi, wi)
    max_hp = actor.maxhp
    cur_hp = actor.hp
    self.contents.font.size = 12
    self.contents.font.color = PHI.color(:GREEN)
    text = "#{cur_hp} / #{max_hp}"
    text_width = self.contents.text_size(text).width
    xo = wi - text_width
    self.contents.draw_text(xo,yi,text_width,WLH,text)
  end
  
  def draw_magic_values(actor, xi, yi, wi)
    max_hp = actor.maxmp
    cur_hp = actor.mp
    self.contents.font.size = 12
    self.contents.font.color = PHI.color(:CYAN)
    text = "#{cur_hp} / #{max_hp}"
    text_width = self.contents.text_size(text).width
    xo = wi - text_width
    self.contents.draw_text(xo,yi,text_width,WLH,text)
  end

  def draw_stamina_values(actor, xi, yi, wi)
    max_hp = actor.maxstamina
    cur_hp = actor.stamina
    self.contents.font.size = 12
    self.contents.font.color = PHI.color(:YELLOW)
    text = "#{cur_hp}%"
    text_width = self.contents.text_size(text).width
    xo = wi - text_width
    self.contents.draw_text(xo,yi,text_width,WLH,text)
  end

  def draw_health_bar(actor, xi, yi)
    bar_width = self.contents.width-8
    bar_height = 2
    max_hp = actor.maxhp
    cur_hp = actor.hp
    gw = bar_width * cur_hp / max_hp
    fill_rect = Rect.new(xi, yi, bar_width, bar_height)
    health_rect = Rect.new(xi, yi, gw, bar_height)
    self.contents.fill_rect(fill_rect, PHI.color(:BLACK))
    if cur_hp < max_hp / 4
      health_color = PHI.color(:RED)
      health_color.red -= 50
    elsif cur_hp < max_hp / 2
      health_color = PHI.color(:YELLOW)
      health_color.green -= 50
      health_color.blue -= 50
      health_color.red += 100
    else
      health_color = PHI.color(:GREEN)
    end
    self.contents.fill_rect(health_rect, health_color)
  end
  
  def draw_magic_bar(actor, xi, yi)
    bar_width = self.contents.width - 8
    bar_height = 2
    max_mp = actor.maxmp
    cur_mp = actor.mp
    gw = bar_width * cur_mp / max_mp
    fill_rect = Rect.new(xi, yi, bar_width, bar_height)
    health_rect = Rect.new(xi, yi, gw, bar_height)
    self.contents.fill_rect(fill_rect, PHI.color(:BLACK))
    if cur_mp < max_mp / 4
      mp_color = PHI.color(:CYAN)
      mp_color.blue -= 50
    elsif cur_mp < max_mp / 2
      mp_color = PHI.color(:CYAN)
      mp_color.blue -= 25
    else
      mp_color = PHI.color(:CYAN)
    end
    self.contents.fill_rect(health_rect, mp_color)
  end

  def draw_stamina_bar(actor, xi, yi)
    bar_width = self.contents.width - 8
    bar_height = 2
    max_mp = actor.maxstamina
    cur_mp = actor.stamina
    gw = bar_width * cur_mp / max_mp
    fill_rect = Rect.new(xi, yi, bar_width, bar_height)
    health_rect = Rect.new(xi, yi, gw, bar_height)
    self.contents.fill_rect(fill_rect, PHI.color(:BLACK))
    if cur_mp < max_mp / 4
      mp_color = PHI.color(:YELLOW)
      mp_color.blue -= 50
    elsif cur_mp < max_mp / 2
      mp_color = PHI.color(:YELLOW)
      mp_color.blue -= 25
    else
      mp_color = PHI.color(:YELLOW)
    end
    self.contents.fill_rect(health_rect, mp_color)
  end
  
  def draw_atb_bar(xi, yi, i)
    @atb_sprites[i].update
  end
  
  def draw_status_message(actor, xi,yi)
    return if actor.status_update.nil?
    same = @status_message == actor.status_update
    return if same
    @status_message = actor.status_update
    self.contents.font.size = 12
    self.contents.draw_text(xi,yi,self.width, 24, @status_message)
  end

  def flash_color(color)
    if @increment
      color.red += @color_flash
      color.blue += @color_flash
      color.green += @color_flash
    else
      color.red -= @color_flash
      color.blue -= @color_flash
      color.green -= @color_flash
    end
    return color
  end


end