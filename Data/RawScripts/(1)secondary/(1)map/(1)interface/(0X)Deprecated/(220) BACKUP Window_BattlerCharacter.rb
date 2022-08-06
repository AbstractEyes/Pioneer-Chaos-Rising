#~     p "Modulo: x #{@main_last_x} , y #{@main_last_y}, w #{@main_last_width}, h #{@main_last_height}"
#~     p "Steps: x #{@main_step_x}, y #{@main_step_y}, w #{@main_step_width}, h #{@main_step_height}"
#~     p "Base: x #{self.x}, y #{self.y}, w #{self.width}, h #{self.height}"
#~     p "Changes: x #{@remain_x}, y #{@remain_y}, w #{@remain_width}, h #{@remain_height}"
#~     p "Adjusted: x #{ax}, y #{ay}, w #{aw}, h #{ah} "
=begin
class Float
  def round_down n=0
  s = self.to_s
  l = s.index('.') + 1 + n
  s.length <= l ? self : s[0,l].to_f
  end
end
module PHI
  WINDOW_HIDE_TICKS = 20
end

class Window_BattlerCharacter < Window_Base
  attr_accessor :actor
  attr_accessor :player
  
  # created to house battlers with full atb bars.
  def initialize(x,y,width,height)
    super(x,y,width,height)
    @sub_window = Window_Base.new(x-8,y-8,width+16,height+16)
    @sub_window.visible = true
    @sub_window.opacity = 0
    @sub_window.z = self.z + 1
    @actor = nil
    @player = nil
    @player_sprite = nil
    
    # Autohide variables
    @autohide = false
    @hide_tick = 0
    @backup_hide_tick = 0
    @wait_tick = 0
    @backup_wait_tick = 0
    
    # Adjusted values
    @a_x = 0
    @a_y = 0
    @a_width = 0
    @a_height = 0
    
    # Backup values
    @b_x = self.x
    @b_y = self.y
    @b_width = self.width
    @b_height = self.height
    
    @sb_x = @sub_window.x
    @sb_y = @sub_window.y
    @sb_width = @sub_window.width
    @sb_height = @sub_window.height
    
    # Refreshed bool
    @r = false
  end
  
  def dispose
    @sub_window.dispose unless @sub_window.disposed?
    super
  end
  
  def update
    @sub_window.update unless @sub_window.nil?
    if @autohide
      unless backup_the_same?
        instant_unhide
        refresh($game_actors[@actor.id].clone)
      else
        if time_to_hide? and still_hiding?
          step_hide
          @hide_tick -= 1
        else
          @wait_tick -= 1
        end
      end
    end
    super
  end
  
  def backup_the_same?
    return ($game_party.actor_the_same?(@actor))
  end
  
  def define_autohide( wait_ticks, hide_ticks=PHI_WINDOW_HIDE_TICKS,
                      remain_width=0,remain_height=0,
                      remain_x=self.x,remain_y=self.y )
    @autohide = true
    @hide_tick = hide_ticks
    @backup_hide_tick = hide_ticks
    @wait_tick = wait_ticks
    @backup_wait_tick = wait_ticks

    @remain_x      = remain_x
    @remain_y      = remain_y
    @remain_width  = remain_width
    @remain_height = remain_height
    ax = @remain_x      - self.x
    ay = @remain_y      - self.y
    aw = @remain_width  - self.width
    ah = @remain_height - self.height
    @main_last_x      = -(ax.to_f % @backup_hide_tick)
    @main_last_y      = -(ay.to_f % @backup_hide_tick)
    @main_last_width  = -(aw.to_f % @backup_hide_tick)
    @main_last_height = -(ah.to_f % @backup_hide_tick)
    @main_step_x      = (ax.to_f / @backup_hide_tick).round_down
    @main_step_y      = (ay.to_f / @backup_hide_tick).round_down
    @main_step_width  = (aw.to_f / @backup_hide_tick).round_down
    @main_step_height = (ah.to_f / @backup_hide_tick).round_down
    
    @sremain_x      = remain_x-8
    @sremain_y      = remain_y-8
    @sremain_width  = remain_width+16
    @sremain_height = remain_height+16
    sax = @sremain_x      - @sub_window.x
    say = @sremain_y      - @sub_window.y
    saw = @sremain_width  - @sub_window.width
    sah = @sremain_height - @sub_window.height
    @smain_last_x      = -(sax.to_f % @backup_hide_tick)
    @smain_last_y      = -(say.to_f % @backup_hide_tick)
    @smain_last_width  = -(saw.to_f % @backup_hide_tick)
    @smain_last_height = -(sah.to_f % @backup_hide_tick)
    @smain_step_x      = (sax.to_f / @backup_hide_tick).round_down
    @smain_step_y      = (say.to_f / @backup_hide_tick).round_down
    @smain_step_width  = (saw.to_f / @backup_hide_tick).round_down
    @smain_step_height = (sah.to_f / @backup_hide_tick).round_down
  end
  
  def instant_unhide
    @r = false
    self.contents.clear
    @sub_window.contents.clear
    @hide_tick = @backup_hide_tick
    @wait_tick = @backup_wait_tick
    self.x = @b_x
    self.y = @b_y
    self.width = @b_width
    self.height = @b_height
    @sub_window.x = @sb_x
    @sub_window.y = @sb_y
    @sub_window.width = @sb_width
    @sub_window.height = @sb_height
  end
    
  def time_to_hide?
    return (@wait_tick <= 0)
  end
  def still_hiding?
    return (@hide_tick > 0)
  end
  def refreshed?
    return @r
  end
  
  def refresh(actor=@actor)
    p "#{@actor.name} window refreshed." if !@actor.nil?
    @r = true
    @actor = actor if @actor != actor
    @sub_window.contents.clear
    upgrade_contents
    draw_battler_data(0)
  end
  
  def upgrade_contents
    @sub_window.contents.dispose
    bitmap = Bitmap.new(@sub_window.width-32, @sub_window.height-32)
    @sub_window.contents = bitmap
    @sub_window.contents.font.color = normal_color
  end
    
  def item_rect(index)
    return Rect.new(0,0,@sub_window.contents.width, @sub_window.contents.height)
  end
  
  def draw_battler_data(index)
    return if @actor.nil?
    rect = item_rect(index)
    draw_actor_name(rect.x+34,rect.y)
    draw_health_values(rect.x+34,rect.y+16)
    draw_health_bar(rect.x,rect.y+34)
    draw_magic_bar(rect.x,rect.y+38)
    draw_atb_bar(rect.x,rect.y+42)
    @sub_window.draw_character(@actor.character_name, @actor.character_index, 16, 32)
  end
  
  def draw_character(character_name, character_index, x, y)
    return if character_name == nil
    bitmap = Cache.(0)character(character_name)
    sign = character_name[/^[\!\$]./]
    if sign != nil and sign.include?('$')
      cw = bitmap.width / 3
      ch = bitmap.height / 4
    else
      cw = bitmap.width / 12
      ch = bitmap.height / 8
    end
    n = character_index
    src_rect = Rect.new((n%4*3+1)*cw, (n/4*4)*ch, cw, ch)
    @sub_window.contents.blt(x - cw / 2, y - ch, bitmap, src_rect)
  end

  def draw_actor_name(x,y)
    text = @actor.name
    @sub_window.contents.font.size = 12
    text_width = @sub_window.contents.text_size(text).width
    @sub_window.contents.draw_text(x,y,text_width,WLH,text)
  end
  
  def draw_health_values(x,y)
    max_hp = @actor.maxhp
    cur_hp = @actor.hp
    @sub_window.contents.font.size = 10
    @sub_window.contents.font.color = PHI.color(:GREEN)
    text = "#{cur_hp} / #{max_hp}"
    text_width = @sub_window.contents.text_size(text).width
    @sub_window.contents.draw_text(x,y,text_width,WLH,text)
  end
  
  def draw_health_bar(x,y)
    bar_width = @sub_window.contents.width
    bar_height = 3
    max_hp = @actor.maxhp
    cur_hp = @actor.hp
    gw = bar_width * cur_hp / max_hp
    fill_rect = Rect.new(x, y, bar_width, bar_height)
    health_rect = Rect.new(x, y, gw, bar_height)
    @sub_window.contents.fill_rect(fill_rect, PHI.color(:BLACK))
    @sub_window.contents.fill_rect(health_rect, PHI.color(:GREEN))
  end
  
  def draw_magic_bar(x,y)
    bar_width = @sub_window.contents.width
    bar_height = 3
    max_mp = @actor.maxmp
    cur_mp = @actor.mp
    gw = bar_width * cur_mp / max_mp
    fill_rect = Rect.new(x, y, bar_width, bar_height)
    health_rect = Rect.new(x, y, gw, bar_height)
    @sub_window.contents.fill_rect(fill_rect, PHI.color(:BLACK))
    @sub_window.contents.fill_rect(health_rect, PHI.color(:BLUE))
  end
  
  def draw_atb_bar(x,y)
    bar_width = @sub_window.contents.width
    bar_height = 2
    max_atb = BATTLE_DATA::ATB_TIMER
    cur_atb = @actor.atb
    gw = bar_width * cur_atb / max_atb
    fill_rect = Rect.new(x, y, bar_width, bar_height)
    health_rect = Rect.new(x, y, gw, bar_height)
    @sub_window.contents.fill_rect(fill_rect, PHI.color(:BLACK))
    @sub_window.contents.fill_rect(health_rect, PHI.color(:YELLOW))
  end  
  
  def step_hide
    last = (@hide_tick <= 1)
    # Main window step.
    adx = 0
    ady = 0
    adw = 0
    adh = 0
    if last
      self.x              = @remain_x
      @sub_window.x       = @sremain_x
      self.y              = @remain_y
      @sub_window.y       = @sremain_y
      self.width          = @remain_width
      @sub_window.width   = @sremain_width
      self.height         = @remain_height
      @sub_window.height  = @sremain_height
      set_finished_bitmaps
    else
      self.x              += @main_step_x
      self.y              += @main_step_y
      self.width          += @main_step_width
      self.height         += @main_step_height
      @sub_window.x       += @smain_step_x
      @sub_window.y       += @smain_step_y
      @sub_window.width   += @smain_step_width
      @sub_window.height  += @smain_step_height
      set_stepping_bitmaps
    end
  end
  
  def set_finished_bitmaps
    # Set old bitmap bases.
    mb = self.contents
    sb = @sub_window.contents
    # Adjusted bitmap for main window.
    awid = self.width - 32
    ahei = self.height - 32
    awid = 1 if awid < 1
    ahei = 1 if ahei < 1
    mbitmap = Bitmap.new(awid, ahei)
    # Adjusted bitmap for sub window.
    sawid = @sub_window.width - 32
    sahei = @sub_window.height - 32
    sawid = 1 if sawid < 1
    sahei = 1 if sahei < 1
    sbitmap = Bitmap.new(sawid, sahei)
    # Set new parameters.
    mbitmap.stretch_blt(mbitmap.rect, mb, mbitmap.rect)
    sbitmap.stretch_blt(sbitmap.rect, sb, sbitmap.rect)
    self.contents = mbitmap
    @sub_window.contents = sbitmap
  end
  
  def set_stepping_bitmaps
    # Set old bitmap bases.
    mb = self.contents
    sb = @sub_window.contents
    # Adjusted bitmap for main window.
    awid = mb.width + @main_step_width
    ahei = mb.height + @main_step_height
    awid = 1 if awid < 1
    ahei = 1 if ahei < 1
    mbitmap = Bitmap.new(awid, ahei)
    # Adjusted bitmap for sub window.
    sawid = sb.width + @smain_step_width
    sahei = sb.height + @smain_step_height
    sawid = 1 if sawid < 1
    sahei = 1 if sahei < 1
    sbitmap = Bitmap.new(sawid, sahei)
    # Set new parameters.
    mbitmap.stretch_blt(mbitmap.rect, mb, mbitmap.rect)
    sbitmap.stretch_blt(sbitmap.rect, sb, sbitmap.rect)
    self.contents = mbitmap
    @sub_window.contents = sbitmap
  end

  
end
=end