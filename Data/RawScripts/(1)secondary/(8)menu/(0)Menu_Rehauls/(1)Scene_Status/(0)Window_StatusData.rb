module PHI
  module STATUS
    STAT_NAMES = {
      :hp   => 'Health Points',
      :mp   => 'Element Points',
      :sta  => 'Stamina',
      :str  => 'Strength',
      :agi  => 'Agility',
      :int  => 'Intelligence',
      :def  => 'Defense',
      :res  => 'All Resistance',
      :pres => 'Physical Resistance',
      :eres => 'Element Resistance',
      :sres => 'Status Resistance',
      :ccha => 'Critical Chance',
      :cmul => 'Critical Multiplier'
    }
    def self.stat_names_safe(stat)
      if STAT_NAMES.keys.include?(stat)
        return STAT_NAMES[stat]
      else
        return 'ERROR'
      end
    end
  end
end

class Window_StatusData < Window_Base
  attr_accessor :actor_id

  def initialize(x,y,w,h)
    super(x,y,w,h)
    @actor_id = -1
    self.opacity = 0
  end

  def update
    super
    if @actor_id != @last_actor_id
      refresh(@actor_id)
      @last_actor_id = @actor_id
    end
  end

  def refresh(actor_id)
    @actor_id = actor_id
    @actor = nil
    return if actor_id == -1
    @actor = $game_party.all_members[@actor_id]
    create_contents
    draw_page
  end

  def draw_page
    draw_status_character(self.contents.width - 64, 0)
    draw_actor_name(  0, 0)
    draw_actor_class( 6, 32)
    draw_actor_level( 0, 32+30)
    draw_actor_exp(   0, 32+30+20)
    stat_pos = 150
    draw_stat(:str,   0, stat_pos + 30 * 0)
    draw_stat(:agi,   0, stat_pos + 30 * 1)
    draw_stat(:int,   0, stat_pos + 30 * 2)
    draw_stat(:def,   0, stat_pos + 30 * 3)
    draw_stat(:res,   0, stat_pos + 30 * 4)
    draw_stat(:pres,  0, stat_pos + 30 * 5)
    draw_stat(:eres,  0, stat_pos + 30 * 6)
    draw_stat(:sres,  0, stat_pos + 30 * 7)
    draw_stat(:ccha,  0, stat_pos + 30 * 8)
    draw_stat(:cmul,  0, stat_pos + 30 * 9)
    Graphics.update
    Graphics.frame_reset
  end
  ###################################################################
  def draw_actor_name(x, y)
    size = self.contents.font.size
    self.contents.font.size = 36
    self.contents.font.color = PHI.color(:BLACK)
    self.contents.draw_text(x,y,self.contents.text_size(@actor.name).width, self.contents.font.size, @actor.name)
    self.contents.font.size = size
  end

  def draw_actor_class(x, y)
    size = self.contents.font.size
    self.contents.font.size = 30
    self.contents.font.color = PHI.color(:BLACK)
    self.contents.draw_text(x,
                            y,
                            self.contents.text_size('Class: ' + @actor.class.name).width,
                            self.contents.font.size,
                            'Class: ' + @actor.class.name)
    self.contents.font.size = size
  end

  def draw_actor_level(x, y)
    size = self.contents.font.size
    self.contents.font.size = 22
    self.contents.font.color = PHI.color(:BLACK)
    self.contents.draw_text(x,
                            y,
                            self.contents.text_size('Level: ' + @actor.level.to_s).width,
                            self.contents.font.size,
                            'Level: ' + @actor.level.to_s)
    self.contents.font.size = size
  end

  def draw_actor_exp(x, y)
    size = self.contents.font.size
    self.contents.font.size = 20
    self.contents.font.color = PHI.color(:BLACK, 160)
    exp_name_1 = 'Total EXP: '
    exp_string_1 = @actor.exp.to_s
    exp_name_2 = 'To Next: '
    exp_string_2 = @actor.next_exp.to_s
    self.contents.draw_text(x, y, self.contents.text_size(exp_name_1).width, self.contents.font.size, exp_name_1)
    self.contents.draw_text(x + self.contents.width - self.contents.text_size(exp_string_1).width,y, self.contents.text_size(exp_string_1).width, self.contents.font.size, exp_string_1)
    self.contents.draw_text(x, y + 18, self.contents.text_size(exp_name_2).width, self.contents.font.size, exp_name_2)
    self.contents.draw_text(x + self.contents.width - self.contents.text_size(exp_string_2).width,y+18, self.contents.text_size(exp_string_2).width, self.contents.font.size, exp_string_2)
    self.contents.fill_rect(x + 8, y + 18 + 18, self.contents.width, 4, PHI.color(:BLACK))
    if @actor.next_exp != 0
      gw = self.contents.width * @actor.now_exp
      gw /= @actor.next_exp
    else
      gw = self.contents.width
    end
    self.contents.fill_rect(x + 8, y + 18 + 18, gw, 4, PHI.color(:YELLOW))
    if @actor.next_exp != 0
      expercent = @actor.now_exp * 100.000
      expercent /= @actor.next_exp
    else
      expercent = 100.000
    end
    expercent = 100.000 if expercent > 100.000
    format = '%1.2f%%'
    text = sprintf(format, expercent)
    self.contents.draw_text(x + self.contents.width - self.contents.text_size(text).width, y + 32, self.contents.text_size(text).width, 32, text, 2)
    self.contents.font.size = size
  end

  def draw_stat(stat, x, y)
    val = 0
    icon = PHI::ICONS.safe_icon(stat)
    case stat
      when :hp
        val = @actor.hp
      when :mp
        val = @actor.mp
      when :sta
        val = @actor.stamina
      when :str
        val = @actor.atk
      when :agi
        val = @actor.agi
      when :int
        val = @actor.spi
      when :def
        val = @actor.def
      when :res
        val = '+' + @actor.res.to_s + '%'
      when :pres
        val = '+' + @actor.phy_res.to_s + '%'
      when :eres
        val = '+' + @actor.ele_res.to_s + '%'
      when :sres
        val = '+' + @actor.sta_res.to_s + '%'
      when :ccha
        val = @actor.cri.to_s + '%'
      when :cmul
        val = @actor.cri_mul.to_s + 'x'
    end
    name = PHI::STATUS.stat_names_safe(stat)
    draw_map_icon(icon, x, y)
    self.contents.draw_text(x + 32, y, 128, 32, name)
    self.contents.draw_text(x + self.contents.width - 64, y, 64, 32, val, 2)
  end

  def draw_status_character(xi, yi)
    character_name = @actor.character_name
    character_index = @actor.character_index
    return unless character_name.is_a?(String)
    bitmap = Cache.character(character_name)
    sign = character_name[/^[\!\$\~]./]
    p1 = 1
    if sign != nil and sign.include?('$')
      cw = bitmap.width / 3
      ch = bitmap.height / 4
    elsif sign != nil and sign.include?('~')
      cw = 48
      ch = 64
      p1 = 0
    else
      cw = bitmap.width / 12
      ch = bitmap.height / 8
    end
    n = character_index
    src_rect = Rect.new((n%4*3+p1)*cw, (n/4*4)*ch, cw, ch)
    self.contents.blt(xi - cw / 2, yi - ch, bitmap, src_rect)
  end

end