class Window_StatusCharacter < Window_Selectable
  def initialize(x,y,w,h)
    super(x,y,w,h)
    self.opacity = 0
    self.visible = true
    self.active = true
    self.index = 0
  end

  def item_rect(inde)
    return Rect.new(0,
                    inde*self.contents.height/5,
                    self.contents.width-8,
                    self.contents.height/5)
  end

  def update
    super
  end

  def index=(n_index)
    @index = n_index
  end

  def refresh
    @item_max = $game_party.members.size
    create_contents
    for i in 0...@item_max
      rect = item_rect(i)
      draw_outline(rect, i) if i == index
      update_bars($game_party.members[i], rect)
      update_numbers($game_party.members[i], rect)
    end
  end

  def draw_outline(rect, i)
    self.contents.fill_rect(rect, PHI.color(:BLACK))
    rect.x += 2; rect.y += 2; rect.width -= 4; rect.height -=4
    self.contents.fill_rect(rect, PHI.color(:INV))
    draw_character($game_party.members[i].character_name,
                   $game_party.members[i].character_index, rect.x + 2, rect.y + 2)
  end

  def update_numbers(actor, rect)
    draw_character(actor.character_name, actor.character_index, rect.x+18, rect.y+68)
    draw_actor_name(actor, rect.x+34,rect.y)
    draw_actor_level(actor, rect.x+rect.width - 64, rect.y)
    draw_health_values(actor, rect.x, rect.y+22, rect.width - 12)
    draw_magic_values(actor, rect.x, rect.y+35, rect.width - 12)
    draw_stamina_values(actor, rect.x+16, rect.y+46, rect.width - 12)
  end

  def update_bars(actor, rect)
    draw_magic_bar(actor, rect.x+18,rect.y+52)
    draw_health_bar(actor, rect.x+18,rect.y+40)
    draw_stamina_bar(actor, rect.x+18, rect.y+64)
    #draw_atb_bar(rect.x,rect.y+58, i)
  end

  def draw_actor_level(actor, x, y)
    text = "LVL " + actor.level.to_s
    old_font = self.contents.font.size
    self.contents.font.size = 22
    rect = Rect.new(x, y, self.contents.text_size(text).width, 20)
    self.contents.draw_text(rect, text)
    self.contents.font.size = old_font
    self.contents.font.size = Font.default_size
  end

  def draw_actor_name(actor, xi, yi)
    text = actor.name
    self.contents.font.size = 22
    self.contents.font.color = normal_color
    text_width = self.contents.text_size(text).width
    self.contents.draw_text(xi-12,yi,text_width,WLH,text)
    self.contents.font.size = Font.default_size
  end

  def draw_health_values(actor, xi, yi, wi)
    max_hp = actor.maxhp
    cur_hp = actor.hp
    self.contents.font.size = 16
    self.contents.font.color = PHI.color(:GREEN).clone
    text = "#{cur_hp} / #{max_hp}"
    text_width = self.contents.text_size(text).width
    xo = wi - text_width
    self.contents.draw_text(xo,yi,text_width,WLH,text)
    self.contents.font.size = Font.default_size
  end

  def draw_magic_values(actor, xi, yi, wi)
    max_hp = actor.maxmp
    cur_hp = actor.mp
    self.contents.font.size = 16
    self.contents.font.color = PHI.color(:CYAN).clone
    text = "#{cur_hp} / #{max_hp}"
    text_width = self.contents.text_size(text).width
    xo = wi - text_width
    self.contents.draw_text(xo,yi,text_width,WLH,text)
    self.contents.font.size = Font.default_size
  end

  def draw_stamina_values(actor, xi, yi, wi)
    max_hp = actor.maxstamina
    cur_hp = actor.stamina
    self.contents.font.size = 16
    self.contents.font.color = PHI.color(:YELLOW).clone
    text = "#{cur_hp}%"
    text_width = self.contents.text_size(text).width
    xo = wi - text_width
    self.contents.draw_text(xo,yi,text_width,WLH,text)
    self.contents.font.size = Font.default_size
  end

  #def draw_character(character_name, character_index, xi, yi)
  #  return if character_name == nil
  #  bitmap = Cache.character(character_name)
  #  sign = character_name[/^[\!\$\~]./]
  #  p1 = 1
  #  if sign != nil and sign.include?('$')
  #    cw = bitmap.width / 3
  #    ch = bitmap.height / 4
  #  elsif sign != nil and sign.include?('~')
  #    cw = 48
  #    ch = 64
  #    p1 = 0
  #    p 'is special'
  #  else
  #    cw = bitmap.width / 12
  #    ch = bitmap.height / 8
  #  end
  #  n = character_index
  #  src_rect = Rect.new((n%4*3+p1)*cw, (n/4*4)*ch, cw, ch)
  #  self.contents.blt(xi - cw / 2, yi - ch, bitmap, src_rect)
  #end

  def draw_health_bar(actor, xi, yi)
    bar_width = self.contents.width - 32 - 8
    bar_height = 2
    max_hp = actor.maxhp
    cur_hp = actor.hp
    gw = bar_width * cur_hp / max_hp
    fill_rect = Rect.new(xi, yi, bar_width, bar_height)
    health_rect = Rect.new(xi, yi, gw, bar_height)
    self.contents.fill_rect(fill_rect, PHI.color(:BLACK))
    if cur_hp < max_hp / 4
      health_color = PHI.color(:RED).clone
      health_color.red -= 50
    elsif cur_hp < max_hp / 2
      health_color = PHI.color(:YELLOW).clone
      health_color.green -= 50
      health_color.blue -= 50
      health_color.red += 100
    else
      health_color = PHI.color(:GREEN).clone
    end
    self.contents.fill_rect(health_rect, health_color)
  end

  def draw_magic_bar(actor, xi, yi)
    bar_width = self.contents.width - 32 - 8
    bar_height = 2
    max_mp = actor.maxmp
    cur_mp = actor.mp
    gw = bar_width * cur_mp / max_mp
    fill_rect = Rect.new(xi, yi, bar_width, bar_height)
    health_rect = Rect.new(xi, yi, gw, bar_height)
    self.contents.fill_rect(fill_rect, PHI.color(:BLACK))
    if cur_mp < max_mp / 4
      mp_color = PHI.color(:CYAN).clone
      mp_color.blue -= 50
    elsif cur_mp < max_mp / 2
      mp_color = PHI.color(:CYAN).clone
      mp_color.blue -= 25
    else
      mp_color = PHI.color(:CYAN).clone
    end
    self.contents.fill_rect(health_rect, mp_color)
  end

  def draw_stamina_bar(actor, xi, yi)
    bar_width = self.contents.width - 32 - 8
    bar_height = 2
    max_mp = actor.maxstamina
    cur_mp = actor.stamina
    gw = bar_width * cur_mp / max_mp
    fill_rect = Rect.new(xi, yi, bar_width, bar_height)
    health_rect = Rect.new(xi, yi, gw, bar_height)
    self.contents.fill_rect(fill_rect, PHI.color(:BLACK))
    if cur_mp < max_mp / 4
      mp_color = PHI.color(:YELLOW).clone
      mp_color.blue -= 50
    elsif cur_mp < max_mp / 2
      mp_color = PHI.color(:YELLOW).clone
      mp_color.blue -= 25
    else
      mp_color = PHI.color(:YELLOW).clone
    end
    self.contents.fill_rect(health_rect, mp_color)
  end

end