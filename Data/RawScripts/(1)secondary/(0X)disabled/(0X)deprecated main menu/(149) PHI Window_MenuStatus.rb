=begin
#==============================================================================
# ** Window_MenuStatus
#------------------------------------------------------------------------------
#  This window displays party member status on the menu screen.
#==============================================================================

class Window_MenuStatus < Window_Selectable
  #--------------------------------------------------------------------------
  # * Object Initialization
  #     x : window X coordinate
  #     y : window Y coordinate
  #--------------------------------------------------------------------------
  def initialize(x, y,width=384,height=$screen_height-64)
    super(x, y, width, height)
    refresh
    self.active = false
    self.index = 0
  end

  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh
    self.contents.clear
    @column_max = 1
    @item_max = $game_party.members.size
    @wlh2 = (self.height-40) / 5 
    create_contents
    for i in 0...$game_party.members.size
      actor = $game_party.members[i]
      rect = item_rect(i)
      draw_character(actor,
                      actor.character_name,
                      actor.character_index,
                      rect.x+32,
                      rect.y+32)
      x = rect.x + 64
      y = rect.y# * 96 + WLH / 2
      draw_actor_name(actor, x, y)
#~       draw_actor_class(actor, x + 88, y)
      draw_actor_level(actor, x, y + WLH * 1)
      draw_actor_state(actor, x, y + WLH * 2)
      draw_actor_hp(actor, x + 128, y)
      draw_actor_mp(actor, x + 128, y + WLH)
    end
  end
  
  def draw_actor_hp_values(actor, cur_rect)
    self.contents.font.size = 14
    self.contents.font.color = PHI.color(:GREEN)
    self.contents.draw_text(cur_rect, PHI::Vocab::HP_SHORT + ": ")
    cur_rect.x = cur_rect.x + self.contents.text_size(PHI::Vocab::HP_SHORT).width
    cur_rect.x = cur_rect.x + self.contents.text_size(": ").width + 4
    self.contents.draw_text(cur_rect, actor.hp.to_s)
    cur_rect.x = cur_rect.x + self.contents.text_size(actor.hp.to_s).width+4
    self.contents.draw_text(cur_rect, "/")
    cur_rect.x = cur_rect.x +  self.contents.text_size("/").width + 4
    self.contents.draw_text(cur_rect, actor.maxhp.to_s)
    self.contents.font.size = Font.default_size
#~     self.contents.font.color = normal_color
  end
  
  def draw_actor_mp_values(actor, rect)
    
  end
  #--------------------------------------------------------------------------
  # * Draw HP
  #     actor : actor
  #     x     : draw spot x-coordinate
  #     y     : draw spot y-coordinate
  #     width : Width
  #--------------------------------------------------------------------------
  def draw_actor_hp(actor, x, y, width = 120)
    draw_actor_hp_gauge(actor, x, y, width)
    self.contents.font.color = system_color
    self.contents.draw_text(x, y, 30, WLH, Vocab::hp_a)
    self.contents.font.color = hp_color(actor)
    last_font_size = self.contents.font.size
    xr = x + width
    if width < 120
      self.contents.draw_text(xr - 44, y, 44, WLH, actor.hp, 2)
    else
      self.contents.draw_text(xr - 99, y, 44, WLH, actor.hp, 2)
      self.contents.font.color = normal_color
      self.contents.draw_text(xr - 55, y, 11, WLH, "/", 2)
      self.contents.draw_text(xr - 44, y, 44, WLH, actor.maxhp, 2)
    end
  end
  #--------------------------------------------------------------------------
  # * Draw HP gauge
  #     actor : actor
  #     x     : draw spot x-coordinate
  #     y     : draw spot y-coordinate
  #     width : Width
  #--------------------------------------------------------------------------
  def draw_actor_hp_gauge(actor, x, y, width = 120)
    gw = width * actor.hp / actor.maxhp
    gc1 = hp_gauge_color1
    gc2 = hp_gauge_color2
    self.contents.fill_rect(x, y + WLH - 8, width, 6, gauge_back_color)
    self.contents.gradient_fill_rect(x, y + WLH - 8, gw, 6, gc1, gc2)
  end

  def draw_actor_mp_bar(actor, rect)
    
  end
  
  def update_cursor(*args, &block)
    super(*args, &block)
  end

end
=end