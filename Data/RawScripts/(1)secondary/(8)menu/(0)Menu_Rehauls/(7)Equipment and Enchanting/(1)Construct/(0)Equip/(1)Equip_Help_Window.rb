# -------------------------------------------------------------------------------------------------------------- #
# -------------------------------------------------------------------------------------------------------------- #
# -------------------------------------------------------------------------------------------------------------- #
# -------------------------------------------------------------------------------------------------------------- #
# -------------------------------------------------------------------------------------------------------------- #

class Equipment_Help < Window_Base

  def initialize(x,y,width,height)
    super(x,y,width,height)
    @x1 = x
    @y1 = y
    @w1 = width
    @h1 = height
    @equip = nil
    @column_max = 3.0
    self.back_opacity = 255
  end

  def equip
    return $game_party.equipment[@equip]
  end

  def equip_c
    return $game_party.equipment[@equip_compare]
  end

  def equipped?
    return $game_party.equipment.equipped?(@equip)
  end

  def comparing?
    return @equip_compare != nil
  end

  def equipped_member
    return nil if @equip == nil
    return $game_party.equipment.get_equipped_member(@equip)
  end

  def draw_columns
    height = self.contents.height - 76
    width = self.contents.width/3
    (0...3).each do |i|
      rect = Rect.new(0+i*width, 72, width - 2, height)
      case i
        when 0
          color = PHI.color(:GREY, 120)
          text = 'Stats'
        when 1
          color = PHI.color(:RED, 60)
          text = 'Damage'
        else
          color = PHI.color(:BLUE, 60)
          text = 'Resistance'
      end
      self.contents.fill_rect(rect, PHI.color(:BLACK))
      rect.x += 2
      rect.y += 2
      rect.width -= 4
      rect.height -= 4
      self.contents.fill_rect(rect, color)
      rect.height = 20
      self.contents.draw_text(rect, text, 2)
    end
  end

  def draw_equipment_stats
    for i in 0...PHI::ICONS::EQUIPMENT_STAT_ORDER.size
      stat_sym = PHI::ICONS::EQUIPMENT_STAT_ORDER[i]
      draw_stat(stat_sym, 0, i, true, true, -1, PHI.color(:GREY, 180))
    end
  end

  def draw_element_stats
    for i in 0...PHI::ICONS::EQUIPMENT_ELEMENT_ORDER.size
      ele_sym = PHI::ICONS::EQUIPMENT_ELEMENT_ORDER[i]
      draw_stat(ele_sym, 1, i, false, true, 0, PHI.color(:RED, 120))
      draw_stat(ele_sym, 2, i, false, false, 1, PHI.color(:BLUE, 120))
    end
  end

  def draw_stat(sym, column, i, verbose, use_icon = true, val_pos=-1, bg_color=PHI.color(:GREY, 180))
    self.contents.font.color = normal_color
    self.draw_icon( PHI::ICONS.safe_icon(sym), 0+column*self.contents.width/3, 82+i*24) if use_icon
    self.contents.font.size = 14
    self.contents.font.color = PHI::ICONS.safe_color(sym)
    self.contents.draw_text(0+column*self.contents.width/3, 82+i*24, 32, 16, sym.to_s) if verbose
    if comparing?
      stats1 = @stats_c
      stats2 = @stats
    else
      stats1 = @stats
      stats2 = @all_stats
    end
    pos_color = PHI.color(:GREEN, 255)
    neg_color = Color.new(255, 100, 100, 255)
    stat_val = stats1[sym]
    stat_val = stats1[sym][0] if val_pos == 0
    stat_val = stats1[sym][1] if val_pos == 1
    stat_val_all = stats2[sym]
    if stat_val_all.is_a?(Array)
      stat_val_all = stats2[sym][0] if val_pos == 0
      stat_val_all = stats2[sym][1] if val_pos == 1
    end
    if comparing?
      stat_val.to_i - stat_val_all.to_i > 0 ?
          self.contents.font.color = pos_color :
          self.contents.font.color = neg_color
    else
      stat_val.to_i >= 0 ?
          self.contents.font.color = pos_color :
          self.contents.font.color = neg_color
    end
    self.contents.draw_text(0+column*self.contents.width/3+24, 82+i*24,
                            self.contents.width/3-30, 24, stat_val.to_i.to_s, 2) if stat_val.to_i != 0
    if comparing?
      stat_val_all.to_i - stat_val.to_i > 0 ?
          self.contents.font.color = pos_color :
          self.contents.font.color = neg_color
    else
      #if stats2[sym].is_a?(Array)
      #  stat_val_all.to_i >= 0 ?
      #      self.contents.font.color = pos_color :
      #      self.contents.font.color = neg_color
      #else
        self.contents.font.color = normal_color
      #end
    end
    self.contents.draw_text(0+column*self.contents.width/3+24, 82+i*24,
                            self.contents.width/3-30, 24, stat_val_all.to_i.to_s) if stat_val_all.to_i != 0
    self.contents.fill_rect(0+column*self.contents.width/3+24, 82+i*24+20, self.contents.width/3-30, 1, bg_color)
    self.contents.font.color = normal_color
  end

  def refresh(equip_in, compare_equip=nil, actor=nil)
    create_contents if self.contents.nil?
    self.contents.clear
    return if equip_in.nil? or equip_in == -1
    @equip = equip_in
    @equip_compare = compare_equip
    @stats = nil
    @stats_c = nil
    if compare_equip != nil
      @stats = self.equip.all_stats
      @stats_c = self.equip_c.all_stats
    else
      @stats = self.equip.all_stats
      @all_stats = equipped_member.stats
    end
    draw_primary_information
    draw_columns
    draw_equipment_stats
    draw_element_stats
  end

  def draw_primary_information
    rounded_outline = Rect.new(0, 0, self.contents.width-2, 68)
    rounded_fill = Rect.new(2, 2, self.contents.width-6, 64)
    self.contents.fill_rect(rounded_outline,PHI.color(:BLACK))
    self.contents.fill_rect(rounded_fill, PHI.color(:GREY, 160))
    draw_map_icon(equip.icon_index, rounded_fill.x, rounded_fill.y)
    self.contents.font.size = 14
    rounded_fill.x += 32
    rounded_fill.y -= 24
    #equipped? ? e = ' - E' : e = ''
    self.contents.draw_text(rounded_fill, equip.name)
    self.contents.font.size = 12
    rounded_fill.y += 64
    #draw level
    draw_level(rounded_fill)
    #draw sockets
    #draw_sockets(rounded_fill)
    #draw face of equipped character
    #fill_character(rounded_fill)
  end

  def fill_character(rect)
    if equipped?
      mem = $game_party.equipment.get_equipped_member(@equip)
      draw_character_face(mem.character_name, mem.character_index, 16, rect.y+64-12)
    end
  end

  def draw_level(rect)
    self.contents.font.color = PHI.color(:CYAN, 255)
    twidth = self.contents.text_size('lvl ' + equip.level.to_s).width
    cl = rect.clone
    cl.x = self.contents.width - twidth - 8
    cl.y = 8
    cl.width = twidth + 4
    cl.height = 20
    self.contents.fill_rect(cl, PHI.color(:GREY, 255))
    self.contents.draw_text(cl, 'lvl ' + equip.level.to_s)
    self.contents.font.color = normal_color
  end

  def draw_sockets(rect)
    max_sockets_before_squish = 14
    rrect = Rect.new(48, rect.height - 36, 16, 12)
    rrect.width = (self.contents.width - 48 - 8)/self.equip.max_sockets if self.equip.max_sockets > max_sockets_before_squish
    (0...self.equip.max_sockets).each do |i|
      self.equip.max_sockets > max_sockets_before_squish ?
          rrect.x = 48 + i * ((self.contents.width - 48 - 8)/self.equip.max_sockets) :
          rrect.x = 48 + i * 16
      nrect = rrect.clone
      nrect.y += 12
      soc = self.equip.sockets[i]
      if soc == nil
        pos_color = PHI.color(:GREY, 255)
        neg_color = PHI.color(:GREY, 255)
      else
        pos_color = soc.pos_color
        neg_color = soc.neg_color
      end
      self.contents.fill_rect(rrect, PHI.color(:BLACK, 200))
      rrect2 = rrect.clone; rrect2.x += 1; rrect2.y += 1; rrect2.width -= 2; rrect2.height -= 2
      self.contents.fill_rect(rrect2, pos_color)
      self.contents.fill_rect(nrect, PHI.color(:BLACK, 200))
      nrect2 = nrect.clone; nrect2.x += 1; nrect2.y += 1; nrect2.width -= 2; nrect2.height -= 2
      self.contents.fill_rect(nrect2, neg_color)
      if soc != nil
        self.draw_sized_icon(rrect, soc.icon_index_pos)
        self.draw_sized_icon(nrect, soc.icon_index_neg)
      end
      soc_level = self.equip.socket_density(i)
      num_rect = rrect.clone
      num_rect.width = 8
      num_rect.x += 4
      num_rect.y += 8
      self.contents.fill_rect(num_rect, PHI.color(:BLACK, 150))
      self.contents.draw_text(num_rect, soc_level.to_s)
    end
  end

end
