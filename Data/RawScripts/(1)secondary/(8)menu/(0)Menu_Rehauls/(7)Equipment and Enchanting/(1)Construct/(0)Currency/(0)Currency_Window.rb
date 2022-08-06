class Currency_Window < Window_Base

  def initialize(x,y)
    super(x, y, 200, 176)
    #$game_party.add_currency(:markers, rand(1500))
    #$game_party.add_currency(:collateral, rand(1500))
    #$game_party.add_currency(:carbon, rand(1500))
    #$game_party.add_currency(:metal, rand(1500))
    #$game_party.add_currency(:elemental, rand(1500))
    #$game_party.add_currency(:chaos, rand(1500))
  end

  # 0 currencies verbose,
  # 1 currencies condensed,
  # 2 currencies / costs verbose,
  # 3 currencies / costs condensed
  def refresh(display=0, costs={}, currencies=$game_party.currency_hash)
    @display = display
    @costs = costs
    @currencies = currencies
    self.opacity = 5000
    case display
      when 0
        draw_currencies(true, false)
      when 1
        draw_currencies(false, false)
      when 2
        draw_currencies(true, true)
      when 3
        draw_currencies(false, true)
    end
  end

  def draw_currencies(verbose, include_costs)
    verbose ? self.width = 200 : self.width = 120
    self.width += 80 if include_costs
    create_contents
    pos_i = -1
    for i in 0...PHI::CURRENCY::TYPES.size
      next if include_costs && !@costs.keys.include?(PHI::CURRENCY::TYPES[i])
      pos_i += 1
      rect = item_rect(pos_i)
      sym, value = PHI::CURRENCY::TYPES[i], @currencies[PHI::CURRENCY::TYPES[i]]
      #icon
      icon_index = currency_icon_index(sym)
      color = currency_color(sym)
      #draw icon then value
      self.draw_icon(icon_index, rect.x, rect.y)
      ocolor = self.contents.font.color.clone
      size = self.contents.font.size
      self.contents.font.color = color
      if verbose
        rect.x += 25
        self.contents.font.size = 20
        self.contents.draw_text(rect, sym.to_s.capitalize)
      end
      if include_costs
        cvalue = @costs[PHI::CURRENCY::TYPES[i]].to_s
        self.contents.font.color = normal_color
        rect.x = self.contents.width - self.contents.text_size(cvalue).width
        rect.width = self.contents.width - self.contents.text_size(cvalue).width
        self.contents.draw_text(rect, cvalue)
        rect.x -= self.contents.text_size(' / ').width
        self.contents.draw_text(rect, ' / ')
        can_afford?(sym, cvalue.to_i) ? clr = PHI.color(:CYAN) : clr = PHI.color(:REDDISH)
        self.contents.font.color = clr
        rect.x -= self.contents.text_size(value.to_s).width
        self.contents.draw_text(rect, value.to_s)
      else
        self.contents.font.color = normal_color
        rect.x = self.contents.width - self.contents.text_size(value.to_s).width
        rect.width = self.contents.width - self.contents.text_size(value.to_s).width
        self.contents.draw_text(rect, value.to_s)
      end
      self.contents.font.color = ocolor
      self.contents.font.size = size
    end
  end

  def can_afford?(sym, value)
    return $game_party.can_afford?(sym, value)
  end

  def item_rect(i)
    return Rect.new(0, i*24, self.contents.width, 24)
  end

end