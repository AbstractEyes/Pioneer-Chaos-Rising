module PHI
  #PHI::COLORS[:GOLD]
  COLORS = {
    :INV      => Color.new(0,    0,   0,  0),
    :RED      => Color.new(255,  0,   0    ),
    :DRKRED   => Color.new(150,  0,   0    ),
    :BLUE     => Color.new(0,    0,   255  ),
    :DRKBLUE  => Color.new(0,    0,   150  ),
    :VIOLET   => Color.new(191, 95,   255  ),
    
    :CYAN     => Color.new(52,  197, 226  ),
    :DRKCYAN  => Color.new(0,   102, 204  ),
    :TEAL     => Color.new(0,   128, 128  ),

    :GREEN    => Color.new(0,   255, 0    ),

    :ORANGE   => Color.new(255, 160, 0    ),
    :YELLOW   => Color.new(255, 255, 0    ),
    :GOLD     => Color.new(255, 215, 0    ),
    :WHITE    => Color.new(255, 255, 255  ),
    :BLACK    => Color.new(0,   0,   0    ),
    :DRKGREY  => Color.new(80,  80,  80   ),
    :LTGREY   => Color.new(200, 200, 200  ),
    :GREY     => Color.new(140, 140, 140  ),
    :PURPLE   => Color.new(118,   0, 200  ),
    :BROWN    => Color.new(128,  57,   0  ),
    :REDDISH  => Color.new(200,100,100)

  }

  def self.color(sym,opacity=nil)
    color = COLORS[sym].clone
    color.alpha = opacity unless opacity.nil?
    return color
  end

  def self.color_nc(sym, opacity=nil)
    color = COLORS[sym]
    color.alpha = opacity unless opacity.nil?
    return color
  end
end