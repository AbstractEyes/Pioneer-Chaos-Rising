#~     p "Modulo: x #{@main_last_x} , y #{@main_last_y}, w #{@main_last_width}, h #{@main_last_height}"
#~     p "Steps: x #{@main_step_x}, y #{@main_step_y}, w #{@main_step_width}, h #{@main_step_height}"
#~     p "Base: x #{self.x}, y #{self.y}, w #{self.width}, h #{self.height}"
#~     p "Changes: x #{@remain_x}, y #{@remain_y}, w #{@remain_width}, h #{@remain_height}"
#~     p "Adjusted: x #{ax}, y #{ay}, w #{aw}, h #{ah} "
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
    @locked = false
    @hide_tick = 0
    @backup_hide_tick = 0
    @wait_tick = 0
    @backup_wait_tick = 0
    
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
    create_sprites
  end
  
  def create_sprites
    @positions = {}
    for i in 0..5
      @positions[i] = ::Sprite.new(self.viewport)
      @positions[i].x, @positions[i].y = self.x, self.y
      @positions[i].bitmap = Bitmap.new(self.width-8, self.height-8)
      @positions[i].z = self.z + 1
    end
  end
  
  def dispose
    @sub_window.dispose unless @sub_window.disposed?
    @positions.values.each { |sprite|
      sprite.dispose
    }
    super
  end
  
  def can_hide?
    return (@autohide and $game_options.autohide)
  end
  
  def update
    @sub_window.update unless @sub_window.nil?
    refresh
    if can_hide?
      if !backup_the_same?
        instant_unhide unless @locked
        refresh($game_actors[@actor.id].clone)
      else
        unless @locked
          if time_to_hide? and still_hiding?
            step_hide
            @hide_tick -= 1
          else
            @wait_tick -= 1
          end
        end
      end
    end
    super
  end
  
  def backup_the_same?
    return ($game_party.actor_the_same?(@actor))
  end
  
  def hidden?
    return (time_to_hide? and !still_hiding? and @autohide)
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
  
  def hide
    @wait_tick = 0
  end
  
  def refresh(actor=@actor)
    @r = true
    a = @actor.nil?
    @actor = actor if @actor.nil?
    @sub_window.contents.clear
    upgrade_contents
    unless @actor.nil?
      rect = item_rect(0)
      draw_actor_name(actor, rect.x+34,rect.y)
      rect.x += 8
      rect.y += 8
      draw_health_values(actor, rect.x, rect.y+22)
      draw_health_bar(actor, rect.x,rect.y+40)
      draw_magic_values(actor, rect.x,rect.y+36)
      draw_atb_bar(actor, rect.x,rect.y+58)
      draw_magic_bar(actor, rect.x,rect.y+52)
      draw_status_message(actor, rect.x+34, rect.y+4)
      @sub_window.draw_character(@actor.character_name, @actor.character_index, 16, 32)
    end
  end
  
  def upgrade_contents
    #@sub_window.contents.dispose
    #bitmap = Bitmap.new(@sub_window.width-32, @sub_window.height-32)
    ##@sub_window.contents = bitmap
    create_contents
    @sub_window.contents.font.color = normal_color
  end
    
  def item_rect(index)
    return Rect.new(0,0,@sub_window.contents.width, @sub_window.contents.height)
  end

  def draw_actor_name(actor, x,y)
    text = actor.name
    @sub_window.contents.font.size = 12
    text_width = @sub_window.contents.text_size(text).width
    @sub_window.contents.draw_text(x,y,text_width,WLH,text)
  end
  
  def draw_health_values(actor, x,y)
    @positions[0].bitmap.clear
    max_hp = actor.maxhp
    cur_hp = actor.hp
    @positions[0].bitmap.font.size = 12
    @positions[0].bitmap.font.color = PHI.color(:GREEN)
    text = "#{cur_hp} / #{max_hp}"
    text_width = @positions[0].bitmap.text_size(text).width
    @positions[0].bitmap.draw_text(x,y,text_width,WLH,text)
  end
  
  def draw_magic_values(actor, x,y)
    @positions[4].bitmap.clear
    max_hp = actor.maxmp
    cur_hp = actor.mp
    @positions[4].bitmap.font.size = 12
    @positions[4].bitmap.font.color = PHI.color(:CYAN)
    text = "#{cur_hp} / #{max_hp}"
    text_width = @positions[4].bitmap.text_size(text).width
    @positions[4].bitmap.draw_text(x,y,text_width,WLH,text)
  end
  
  def draw_health_bar(actor, x,y)
    @positions[1].bitmap.clear
    bar_width = @positions[1].bitmap.width
    bar_height = 3
    max_hp = actor.maxhp
    cur_hp = actor.hp
    gw = bar_width * cur_hp / max_hp
    fill_rect = Rect.new(x, y, bar_width, bar_height)
    health_rect = Rect.new(x, y, gw, bar_height)
    @positions[1].bitmap.fill_rect(fill_rect, PHI.color(:BLACK))
    @positions[1].bitmap.fill_rect(health_rect, PHI.color(:GREEN))
  end
  
  def draw_magic_bar(actor, x,y)
    @positions[2].bitmap.clear
    bar_width = @positions[2].bitmap.width
    bar_height = 3
    max_mp = actor.maxmp
    cur_mp = actor.mp
    gw = bar_width * cur_mp / max_mp
    fill_rect = Rect.new(x, y, bar_width, bar_height)
    health_rect = Rect.new(x, y, gw, bar_height)
    @positions[2].bitmap.fill_rect(fill_rect, PHI.color(:BLACK))
    @positions[2].bitmap.fill_rect(health_rect, PHI.color(:CYAN))
  end
  
  def draw_atb_bar(actor, x,y)
    @positions[3].bitmap.clear
    bar_width = @positions[3].bitmap.width
    bar_height = 2
    max_atb = BATTLE_DATA::ATB_TIMER
    cur_atb = actor.action.atb
    gw = bar_width * max_atb / (cur_atb + 1)
    fill_rect = Rect.new(x, y, bar_width, bar_height)
    health_rect = Rect.new(x, y, gw, bar_height)
    @positions[3].bitmap.fill_rect(health_rect, PHI.color(:BLACK))
    @positions[3].bitmap.fill_rect(fill_rect, PHI.color(:YELLOW))
  end
  
  def draw_status_message(actor, x,y)
    return if actor.status_update.nil?
    same = @status_message == actor.status_update
    return if same
    @status_message = actor.status_update
    @sub_window.contents.font.size = 12
    @sub_window.contents.draw_text(x,y,self.width, 24, @status_message)
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
      @positions.values.each { |sprite|
        next if sprite.nil?
        sprite.x = @sremain_x
        sprite.y = @sremain_y
#~         sprite.bitmap.width += @smain_step_width
#~         sprite.bitmap.height += @smain_step_height
      }
      set_finished_bitmaps
#~       set_stepping_bitmaps
    else
      self.x              += @main_step_x
      self.y              += @main_step_y
      self.width          += @main_step_width
      self.height         += @main_step_height
      @sub_window.x       += @smain_step_x
      @sub_window.y       += @smain_step_y
      @sub_window.width   += @smain_step_width
      @sub_window.height  += @smain_step_height
      @positions.values.each { |sprite|
        next if sprite.nil?
        sprite.x += @smain_step_x
        sprite.y += @smain_step_y
#~         sprite.bitmap.width += @smain_step_width
#~         sprite.bitmap.height += @smain_step_height
      }
      set_stepping_bitmaps
      hide_sprites
    end
  end
  
  def hide_sprites
    @positions.values.each { |sprite|
      sprite.visible = false
    }
  end
  
  def show_sprites
    @positions.values.each { |sprite|
      sprite.visible = true
    }
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

#~     # Set old bitmap bases.
#~     mb = self.contents
#~     sb = @sub_window.contents
#~     # Adjusted bitmap for main window.
#~     awid = mb.width + @main_step_width
#~     ahei = mb.height + @main_step_height
#~     awid = 1 if awid < 1
#~     ahei = 1 if ahei < 1
#~     mbitmap = Bitmap.new(awid, ahei)
#~     # Adjusted bitmap for sub window.
#~     sawid = sb.width + @smain_step_width
#~     sahei = sb.height + @smain_step_height
#~     sawid = 1 if sawid < 1
#~     sahei = 1 if sahei < 1
#~     sbitmap = Bitmap.new(sawid, sahei)
#~     # Set new parameters.
#~     mbitmap.stretch_blt(mbitmap.rect, mb, mbitmap.rect)
#~     sbitmap.stretch_blt(sbitmap.rect, sb, sbitmap.rect)
#~     self.contents = mbitmap
#~     @sub_window.contents = sbitmap
  end
  
  def define_autohide( wait_ticks, hide_ticks=PHI_WINDOW_HIDE_TICKS,
                      remain_width=0,remain_height=0,
                      remain_x=self.x,remain_y=self.y )
    remain_x = self.x if remain_x.nil?
    remain_y = self.y if remain_y.nil?
    remain_width = self.width if remain_width.nil?
    remain_height = self.height if remain_height.nil?
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
    show_sprites
    reset_sprites
  end
  
  def reset_sprites
    @positions.values.each { |sprite|
      sprite.x = @b_x
      sprite.y = @b_y
    }
  end
  
  def lock
    @locked = true
  end
  
  def unlock
    @locked = false
  end
  
end