class Spriteset_Player_Sight
  attr_reader   :sprites
  attr_accessor :x
  attr_accessor :y
  
  def initialize(viewport, bound_character)
    @character = bound_character
    # Logical map x,y
    @x,@y = @character.x, @character.y
    # Viewport for the sprites themselves.
    @viewport = viewport
    @colors = PHI::COLORS
    @ev_colors = EVENT_TAGS::EVENT_IDENT_COLORS
    # Screen width and height in tiles
    @screen_width = 20
    @screen_height = 15
    # Determine sight handler.
    #@handler = @character.attack_range
    @positions,@bubbles,@coords = {},{},{}
    @map_coords = {}
    # Create sprites.
    create_sight_tiles
  end
  
#~   def create_key_coords
#~     data = {}
#~     for x in 0...17
#~       for y in 0...13
#~         data[[x,y]] = 0
#~       end
#~     end
#~     return data
#~   end
  
  def create_key_coords
    data = {}
    x1 = @x-8
    x2 = @x+8
    y1 = @y-5
    y2 = @y+6
    xb,yb = -1,-1
    xf,yf = -1,-1
    for x in x1...x2
      xb += 1
      for y in y1...y2
        yb += 1
        xf, yf = x, y
        data[[xb,yb]] = [xf,yf]
      end
      yb = 0
    end
    return data
  end
  
  # Creates all sight tiles.
  def create_sight_tiles
    return if @handler.nil?
    @handler.spot
    @coords = create_key_coords
    for i in 0...@screen_width * @screen_height
      # Creates the sprite.
      xny = get_x_and_y(i)
      x, y = xny[0],xny[1]

      sprite = Sprite_Tile_Square.new(@viewport)
      sprite.move(x*32+16,y*32+32)
      # Map x and map y
      sprite.draw_square(x*32+16,y*32+32,@colors[:WHITE])
      sprite.visible = false
      sprite.mx, sprite.my = x, y
      @positions[i] = sprite
      
      bubble = Sprite_Info_Bubble.new(@viewport)
      bubble.visible = false
      @bubbles[i] = bubble
    end
  end
    
  def get_x_and_y(i)
    x,y = 0,0
    if inside_screen_width?
      x = (i % @screen_width) + ($game_player.x - (@screen_width / 2))
    else
      x = (i % @screen_width)# + ($game_player.x - (@screen_width / 2))
    end
    if inside_screen_height?
      y = (i / @screen_width) + ($game_player.y - (@screen_height / 2))
    else
      y = (i / @screen_width)# + ($game_player.y - (@screen_height / 2))
    end
    return [x,y]
  end

  def inside_screen_width?
    return ($game_player.x > (@screen_width / 2) and
            $game_player.x - (@screen_width / 2) < $game_map.width)
  end
  def inside_screen_height?
    return ($game_player.y > (@screen_height / 2) and
        $game_player.y - (@screen_height / 2) < $game_map.height)
  end
  
  def update
    
    @x,@y = @character.x, @character.y
    @handler.move(@x,@y,@character.direction)
    @handler.spot
    update_tile_sprites
    update_bubble_sprites
  end
  
  # Updates the entire tile set for the tile sprites.
  def update_tile_sprites
    for i in 0...@screen_width * @screen_height
      # Gets x and y of sprite.
      xny = get_x_and_y(i)
      x, y = xny[0],xny[1]
      sprite = @positions[i]
      sprite.mx, sprite.my = x, y
      if @handler.inside?([x,y]) and !sprite.visible
        p "X #{x} - Y #{y}"
        sprite.visible = true
#~       elsif @handler.inside?([x,y]) and sprite.visible
#~         
      else
        sprite.visible = false
      end
      sprite.update
    end
  end
  
  # Updates the entire bubble set for the bubbles.
  def update_bubble_sprites
    # Creates the reserved spots for the bubble events.
#~     keys = @bubbles.keys
#~     for tile_dif in keys
#~       # Pulls tile and sprite for bubble.
#~       bubble = @bubbles[tile_dif]
#~       x_dif,y_dif = tile_dif[0],tile_dif[1]
#~       # Restore x/y to proper state, using new @x and @y position.
#~       x_r,y_r = x_restore(x_dif), y_restore(y_dif)
#~       color = find_color(x_r,y_r)
#~       # Set screen relativity based on the newly restored x_r/y_r.
#~       x_f, y_f = @(0)character.relative_screen_x(x_r), @(0)character.relative_screen_y(y_r)
#~       # Every tile needs a square.
#~       b_data = get_bubble_data(x_r,y_r)
#~       if !b_data.nil?
#~         bubble.draw_bubble(x_f,y_f,color,b_data)
#~       else
#~         bubble.visible = false
#~       end
#~       bubble.update
#~     end
  end
  
  # Return bool to determine if the bubble should be active
  def get_bubble_data(x,y)
    events = @handler.events.values
    for spot in events
      if spot[1].x == x and spot[1].y == y
        return spot
      end
    end
    return nil
  end
    
  # Test piece, to force everything visible.
  def make_all_visible
    for sprite in @positions.values
      sprite.visible = true
    end
  end
  
  # Used for adjusting to and from key form.
  def x_restore(x)
    return x + @x
  end
  def y_restore(y)
    return y + @y
  end
  def x_adjusted(x)
    return x - @x
  end
  def y_adjusted(y)
    return y - @y
  end
    
  # This will be used to determine which sight tiles need bubbles.
  def refresh
  end
    
  def find_color(x,y)
    color = nil
    type = @handler.coords[[x,y]]
    case type
    when 0
      # Must be passable.
      color = @colors[:WHITE]
    when 1
      # Must be unpassable.
      color = @colors[:GREY]
    when 2
      # Must be player.
      color = @colors[:INV]
    when 3
      # Must be event.
      event = @handler.raw_events[[x,y]]
      tags = event.tags
      if tags[1] != ""
        color = @ev_colors[tags[1].to_sym] if @ev_colors.keys.include?(tags[1].to_sym)
      else
        color = @colors[:GOLD]
      end
    else
      color = @colors[:WHITE]
    end
    return color
  end
  
end