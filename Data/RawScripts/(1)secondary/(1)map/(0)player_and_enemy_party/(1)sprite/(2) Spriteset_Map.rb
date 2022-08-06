#==============================================================================
# ** Spriteset_Map
#------------------------------------------------------------------------------
#  This class brings together map screen sprites, tilemaps, etc. It's used
# within the Scene_Map class.
#==============================================================================

class Spriteset_Map
  attr_accessor :input_attack_grid
  attr_reader   :player_sprites
  attr_reader   :character_sprites
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  #Todo: Expand to allow visibility of attack shapes.
  def initialize
    create_viewports
    create_tilemap
    create_parallax
    create_characters
    create_caterpillar
    create_shadow
    create_weather
    create_pictures
    create_timer
    create_sights
    create_animation_holder
    update
  end
  def create_animation_holder
    @animations = []
  end
  #--------------------------------------------------------------------------
  # * Create Viewport
  #--------------------------------------------------------------------------
  def create_viewports
    @viewport1 = Viewport.new(0, 0, $screen_width, $screen_height)
    @viewport2 = Viewport.new(0, 0, $screen_width, $screen_height)
    @viewport3 = Viewport.new(0, 0, $screen_width, $screen_height)
    @viewport2.z = 50
    @viewport3.z = 100
  end
  #--------------------------------------------------------------------------
  # * Create Tilemap
  #--------------------------------------------------------------------------
  def create_tilemap
    @tilemap = Tilemap.new(@viewport1)
    MAP_SWAP_DATA.has_map?(:a1, $game_map.map_id) ?
        @tilemap.bitmaps[0] = Cache.system(
            'TileA1('+MAP_SWAP_DATA.get_replacement_id(:a1, $game_map.map_id).to_s+')'
        ) : @tilemap.bitmaps[0] = Cache.system('TileA1')

    MAP_SWAP_DATA.has_map?(:a2, $game_map.map_id) ?
        @tilemap.bitmaps[1] = Cache.system(
            'TileA2('+MAP_SWAP_DATA.get_replacement_id(:a2, $game_map.map_id).to_s+')'
        ) : @tilemap.bitmaps[1] = Cache.system('TileA2')

    MAP_SWAP_DATA.has_map?(:a3, $game_map.map_id) ?
        @tilemap.bitmaps[2] = Cache.system(
            'TileA3('+MAP_SWAP_DATA.get_replacement_id(:a3, $game_map.map_id).to_s+')'
        ) : @tilemap.bitmaps[2] = Cache.system('TileA3')

    MAP_SWAP_DATA.has_map?(:a4, $game_map.map_id) ?
        @tilemap.bitmaps[3] = Cache.system(
            'TileA4('+MAP_SWAP_DATA.get_replacement_id(:a4, $game_map.map_id).to_s+')'
        ) : @tilemap.bitmaps[3] = Cache.system('TileA4')

    MAP_SWAP_DATA.has_map?(:a5, $game_map.map_id) ?
        @tilemap.bitmaps[4] = Cache.system(
            'TileA5('+MAP_SWAP_DATA.get_replacement_id(:a5, $game_map.map_id).to_s+')'
        ) : @tilemap.bitmaps[4] = Cache.system('TileA5')

    MAP_SWAP_DATA.has_map?(:b, $game_map.map_id) ?
        @tilemap.bitmaps[5] = Cache.system(
            'TileB('+MAP_SWAP_DATA.get_replacement_id(:b, $game_map.map_id).to_s+')'
        ) :
        @tilemap.bitmaps[5] = Cache.system('TileB')

    MAP_SWAP_DATA.has_map?(:c, $game_map.map_id) ?
        @tilemap.bitmaps[6] = Cache.system(
            'TileC('+MAP_SWAP_DATA.get_replacement_id(:c, $game_map.map_id).to_s+')'
        ) :
        @tilemap.bitmaps[6] = Cache.system('TileC')

    MAP_SWAP_DATA.has_map?(:d, $game_map.map_id) ?
        @tilemap.bitmaps[7] = Cache.system(
            'TileD('+MAP_SWAP_DATA.get_replacement_id(:d, $game_map.map_id).to_s+')'
        ) :
        @tilemap.bitmaps[7] = Cache.system('TileD')

    MAP_SWAP_DATA.has_map?(:e, $game_map.map_id) ?
        @tilemap.bitmaps[8] = Cache.system(
            'TileE('+MAP_SWAP_DATA.get_replacement_id(:e, $game_map.map_id).to_s+')'
        ) :
        @tilemap.bitmaps[8] = Cache.system('TileE')
    @tilemap.map_data = $game_map.data
    @tilemap.passages = $game_map.passages

  end
  #--------------------------------------------------------------------------
  # * Create Parallax
  #--------------------------------------------------------------------------
  def create_parallax
    @parallax = Plane.new(@viewport1)
    @parallax.z = -100
  end
  #--------------------------------------------------------------------------
  # * Create Character Sprite
  #--------------------------------------------------------------------------
  def create_characters
    @character_sprites = []
    for i in $game_map.events.keys.sort
      sprite = Sprite_Character.new(@viewport1, $game_map.events[i])
      @character_sprites.push(sprite)
    end
    for vehicle in $game_map.vehicles
      sprite = Sprite_Character.new(@viewport1, vehicle)
      @character_sprites.push(sprite)
    end
  end
  
  def create_caterpillar
    @player_sprites = []
    for i in 0...5#$game_party.players.values.sort_by {|m| m.actor_id}.reverse
      next if $game_party.sorted_members[i] == -1
      member = $game_party.players[$game_party.sorted_members[i]]
      player = Sprite_Character.new(@viewport1, member)
      player.z = 100 - i
      @player_sprites.push(player)
    end
  end
  
  def create_sights
#~     create_player_sights
  end
  
  def create_player_sights
    # Draw text names for events in player sight.
    #@player_sights = Spriteset_Player_Sight.new(@viewport1,$game_player)
  end
  
  #--------------------------------------------------------------------------
  # * Create Airship Shadow Sprite
  #--------------------------------------------------------------------------
  def create_shadow
    @shadow_sprite = Sprite.new(@viewport1)
    @shadow_sprite.bitmap = Cache.system("Shadow")
    @shadow_sprite.ox = @shadow_sprite.bitmap.width / 2
    @shadow_sprite.oy = @shadow_sprite.bitmap.height
    @shadow_sprite.z = 180
  end
  #--------------------------------------------------------------------------
  # * Create Weather
  #--------------------------------------------------------------------------
  def create_weather
    @weather = Spriteset_Weather.new(@viewport2)
  end
  #--------------------------------------------------------------------------
  # * Create Picture Sprite
  #--------------------------------------------------------------------------
  def create_pictures
    @picture_sprites = []
    for i in 1..20
      @picture_sprites.push(Sprite_Picture.new(@viewport2,
        $game_map.screen.pictures[i]))
    end
  end
  #--------------------------------------------------------------------------
  # * Create Timer Sprite
  #--------------------------------------------------------------------------
  def create_timer
    @timer_sprite = Sprite_Timer.new(@viewport2)
  end

  #--------------------------------------------------------------------------
  # * Dispose
  #--------------------------------------------------------------------------
  def dispose
    dispose_tilemap
    dispose_parallax
    dispose_characters
    dispose_players
    dispose_shadow
    dispose_weather
    dispose_pictures
    dispose_timer
    dispose_sights
    dispose_viewports
    dispose_animation_holder
  end

  def dispose_animation_holder
    @animations.each { |ani| ani.dispose}
    @animations.clear
  end

  def dispose_sights
    dispose_player_sights
  end
  
  def dispose_player_sights
#~     return if @player_sights.sprites.empty?
#~     for sprite in @player_sights.sprites.values
#~       sprite.dispose
#~     end
#~     @player_sights.sprites.clear
  end
  
  def dispose_event_sights
    return if @event_sights.nil?
    return if @event_sights.keys.empty?
    for spritemap in @event_sights.values
      for sprite in spritemap.positions.values
        sprite.dispose
      end
      spritemap.sprites.clear
    end
  end
  
  #--------------------------------------------------------------------------
  # * Dispose of Tilemap
  #--------------------------------------------------------------------------
  def dispose_tilemap
    @tilemap.dispose
  end
  #--------------------------------------------------------------------------
  # * Dispose of Parallax
  #--------------------------------------------------------------------------
  def dispose_parallax
    @parallax.dispose
  end
  #--------------------------------------------------------------------------
  # * Dispose of Character Sprite
  #--------------------------------------------------------------------------
  def dispose_characters
    for sprite in @character_sprites
      sprite.dispose
    end
  end
  def dispose_players
    for sprite in @player_sprites
      sprite.dispose
    end
  end
  #--------------------------------------------------------------------------
  # * Dispose of Airship Shadow Sprite
  #--------------------------------------------------------------------------
  def dispose_shadow
    @shadow_sprite.dispose
  end
  #--------------------------------------------------------------------------
  # * Dispose of Weather
  #--------------------------------------------------------------------------
  def dispose_weather
    @weather.dispose
  end
  #--------------------------------------------------------------------------
  # * Dispose of Picture Sprite
  #--------------------------------------------------------------------------
  def dispose_pictures
    for sprite in @picture_sprites
      sprite.dispose
    end
  end
  #--------------------------------------------------------------------------
  # * Dispose of Timer Sprite
  #--------------------------------------------------------------------------
  def dispose_timer
    @timer_sprite.dispose
  end
  #--------------------------------------------------------------------------
  # * Dispose of Viewport
  #--------------------------------------------------------------------------
  def dispose_viewports
    @viewport1.dispose
    @viewport2.dispose
    @viewport3.dispose
  end
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  def update
    update_tilemap
    update_parallax
    update_characters
    update_players
    update_shadow
    update_weather
    update_pictures
    update_timer
    update_sights
    update_viewports
    update_animation_holder
    update_new_events
  end

  def update_new_events
    $new_events = false if $new_events.nil?
    if $new_events
      keys = $game_map.events.keys
      for ki in 0...keys.size
        i = keys[ki]
        if i >= 1000 && !has_sprite?($game_map.events[i])
          @character_sprites.push(Sprite_Character.new(@viewport1, $game_map.events[i]))
        end
      end
      $new_events = false
    end
    $removed_events = [] if $removed_events.nil?
    if $removed_events.size > 0
      for i in 0...$removed_events.size
        destroy_sprite($removed_events[i])
      end
      $removed_events.clear
      $scene.spriteset.minimap_refresh if $scene.is_a?(Scene_Map)
    end
  end

  def destroy_sprite(id)
    for i in 0...@character_sprites.size
      char = @character_sprites[i]
      next if char.nil?
      if char.stored_id == id
        char.dispose
        @character_sprites[i] = nil
        break
      end
    end
    @character_sprites.compact!
  end

  def has_sprite?(event)
    for i in 0...@character_sprites.size
      return true if @character_sprites[i].character == event
    end
    return false
  end

  def update_animation_holder
    for i in 0...@animations.size
      @animations[i].update if @animations[i] != nil
    end
  end

  def update_sights
#~     update_player_sights
  end

  def update_player_sights
    #if $game_player.attack_grid
    #  @player_sights.update
    #end
  end
   
  def update_event_sights
    #return if @event_sights.nil?
    #for spriteset in @event_sights.values
    #  spriteset.update
    #end
  end
  #--------------------------------------------------------------------------
  # * Update Tilemap
  #--------------------------------------------------------------------------
  def update_tilemap
    @tilemap.ox = $game_map.display_x / 8
    @tilemap.oy = $game_map.display_y / 8
    @tilemap.update
  end
  #--------------------------------------------------------------------------
  # * Update Parallax
  #--------------------------------------------------------------------------
  def update_parallax
    if @parallax_name != $game_map.parallax_name
      @parallax_name = $game_map.parallax_name
      if @parallax.bitmap != nil
        @parallax.bitmap.dispose
        @parallax.bitmap = nil
      end
      if @parallax_name != ""
        @parallax.bitmap = Cache.parallax(@parallax_name)
      end
      Graphics.frame_reset
    end
    @parallax.ox = $game_map.calc_parallax_x(@parallax.bitmap)
    @parallax.oy = $game_map.calc_parallax_y(@parallax.bitmap)
  end
  #--------------------------------------------------------------------------
  # * Update Character Sprite
  #--------------------------------------------------------------------------
  def update_characters
    for sprite in @character_sprites
      sprite.update
    end
  end
  def update_players
    for sprite in @player_sprites
      sprite.update
    end
  end
  #--------------------------------------------------------------------------
  # * Update Airship Shadow Sprite
  #--------------------------------------------------------------------------
  def update_shadow
    airship = $game_map.airship
    @shadow_sprite.x = airship.screen_x
    @shadow_sprite.y = airship.screen_y + airship.altitude
    @shadow_sprite.opacity = airship.altitude * 8
    @shadow_sprite.update
  end
  #--------------------------------------------------------------------------
  # * Update Weather
  #--------------------------------------------------------------------------
  def update_weather
    @weather.type = $game_map.screen.weather_type
    @weather.max = $game_map.screen.weather_max
    @weather.ox = $game_map.display_x / 8
    @weather.oy = $game_map.display_y / 8
    @weather.update
  end
  #--------------------------------------------------------------------------
  # *Update Picture Sprite
  #--------------------------------------------------------------------------
  def update_pictures
    for sprite in @picture_sprites
      sprite.update
    end
  end
  #--------------------------------------------------------------------------
  # * Update Timer Sprite
  #--------------------------------------------------------------------------
  def update_timer
    @timer_sprite.update
  end
  #--------------------------------------------------------------------------
  # * Update Viewport
  #--------------------------------------------------------------------------
  def update_viewports
    @viewport1.tone = $game_map.screen.tone
    @viewport1.ox = $game_map.screen.shake
    @viewport2.color = $game_map.screen.flash_color
    @viewport3.color.set(0, 0, 0, 255 - $game_map.screen.brightness)
    @viewport1.update
    @viewport2.update
    @viewport3.update
  end

  #--------------------------------------------------------------------------
  # * Determine if animation is being displayed
  #--------------------------------------------------------------------------
  def animation?
    for sprite in @player_sprites + @character_sprites + @animations
      return true if sprite.animation?
    end
    return false
  end

  def dump_battle
    for sprite in @player_sprites + @character_sprites
      sprite.dump_battle
    end
  end

end