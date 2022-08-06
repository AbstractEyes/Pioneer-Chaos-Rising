class Window_ElementalData < Window_Base
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
    draw_elemental_affinity
    #draw_status_resistances
  end


  ###################################################################
  #--------------------------------------------------------------------------
  # draw_elemental_affinity
  #--------------------------------------------------------------------------
  def draw_elemental_affinity
    self.contents.font.size = Font.default_size
    affinities = YEZ::STATUS::AFFINITIES
    dx = 12; dy = 0; sw = self.width - 32
    if affinities[:elements_shown].size < 10
      self.contents.font.color = system_color
      text = affinities[:elements_title]
      self.contents.draw_text(dx, dy, sw/2-24, WLH, text, 0)
      dy += WLH
    end
    dw = calc_ele_width(affinities[:elements_shown])
    for ele_id in affinities[:elements_shown]
      if ele_id.is_a?(String)
        color = self.contents.font.color
        size = self.contents.font.size
        self.contents.font.color = PHI.color(:BLACK, 180)
        self.contents.font.size = 26
        self.contents.draw_text(dx, dy, self.contents.width, 26, ele_id, 0)
        self.contents.font.color = color
        self.contents.font.size = size
        dy += 26
      else
        next if ele_id > $data_system.elements.size
        draw_icon(PHI::ICONS::STATS[PHI::ICONS::SORTED_ELEMENTS[ele_id - 1]][0], dx, dy)
        name = $data_system.elements[ele_id]
        self.contents.font.color = PHI.color(:BLACK, 180)
        t_size = 24
        self.contents.font.size = t_size
        self.contents.draw_text(dx+24, dy, dw+10, t_size, name, 0)
        self.contents.font.color = PHI.color(:BLACK, 180) #affinity_colour(@actor.element_resistance(ele_id))
        self.contents.font.size = affinities[:rank_size]
        self.contents.draw_text(dx+34+dw-20, dy, 80, t_size, element_damage_rate(ele_id) + ' / ' + element_rate(ele_id), 2)
        self.contents.font.size = Font.default_size
        dy += t_size
      end
    end
  end

  #--------------------------------------------------------------------------
  # calc_ele_width
  #--------------------------------------------------------------------------
  def calc_ele_width(elements)
    return self.contents.width - 120
    return $game_temp.status_ele_width if $game_temp.status_ele_width != nil
    n = 0
    for ele_id in elements
      next if ele_id > $data_system.elements.size
      text = $data_system.elements[ele_id]
      n = [n, contents.text_size(text).width].max
    end
    $game_temp.status_ele_width = n
    return n
  end

  #--------------------------------------------------------------------------
  # affinity_colour
  #--------------------------------------------------------------------------
  def affinity_colour(amount)
    if amount > 200; n = YEZ::STATUS::AFFINITIES[:rank_colour][:srank]
    elsif amount > 150; n = YEZ::STATUS::AFFINITIES[:rank_colour][:arank]
    elsif amount > 100; n = YEZ::STATUS::AFFINITIES[:rank_colour][:brank]
    elsif amount > 50; n = YEZ::STATUS::AFFINITIES[:rank_colour][:crank]
    elsif amount > 0; n = YEZ::STATUS::AFFINITIES[:rank_colour][:drank]
    elsif amount == 0; n = YEZ::STATUS::AFFINITIES[:rank_colour][:erank]
    else; n = YEZ::STATUS::AFFINITIES[:rank_colour][:frank]
    end
    return text_color(n)
  end

  #--------------------------------------------------------------------------
  # rank_colour
  #--------------------------------------------------------------------------
  def rank_colour(amount)
    if amount > 100; n = YEZ::STATUS::AFFINITIES[:rank_colour][:srank]
    elsif amount > 80; n = YEZ::STATUS::AFFINITIES[:rank_colour][:arank]
    elsif amount > 60; n = YEZ::STATUS::AFFINITIES[:rank_colour][:brank]
    elsif amount > 40; n = YEZ::STATUS::AFFINITIES[:rank_colour][:crank]
    elsif amount > 20; n = YEZ::STATUS::AFFINITIES[:rank_colour][:drank]
    elsif amount > 0; n = YEZ::STATUS::AFFINITIES[:rank_colour][:erank]
    else; n = YEZ::STATUS::AFFINITIES[:rank_colour][:frank]
    end
    return text_color(n)
  end

  #--------------------------------------------------------------------------
  # element_rate
  #--------------------------------------------------------------------------
  def element_rate(ele_id)
    rate = @actor.element_resistance(ele_id)
    if rate >= 0; text = sprintf("%+d%%", rate - 100)
    elsif rate < 0; text = sprintf("%d%%", -rate)
    end
    return text
  end

  def element_damage_rate(ele_id)
    rate = @actor.element_damage(ele_id)
    if rate >= 0; text = sprintf("%+d%%", rate - 100)
    elsif rate < 0; text = sprintf("%d%%", -rate)
    end
    return text
  end


end