#==============================================================================
# ** Scene_File
#------------------------------------------------------------------------------
#  This class performs the save and load screen processing.
#==============================================================================

class Scene_File < Scene_Base
  #--------------------------------------------------------------------------
  # * Write Save Data
  #     file : write file object (opened)
  #--------------------------------------------------------------------------
  def write_save_data(file)
    characters = []
    for actor in $game_party.all_members
      next if actor.nil?
      characters.push([actor.character_name, actor.character_index])
    end
    $game_system.save_count += 1
    $game_system.version_id = $data_system.version_id
    @last_bgm = RPG::BGM::last
    @last_bgs = RPG::BGS::last
    Marshal.dump(characters,                file)
    Marshal.dump(Graphics.frame_count,      file)
    Marshal.dump(@last_bgm,                 file)
    Marshal.dump(@last_bgs,                 file)
    Marshal.dump($game_system,              file)
    Marshal.dump($game_message,             file)
    Marshal.dump($game_switches,            file)
    Marshal.dump($game_variables,           file)
    Marshal.dump($game_self_switches,       file)
    Marshal.dump($game_actors,              file)
    Marshal.dump($game_party,               file)
    Marshal.dump($game_troop,               file)
    Marshal.dump($game_map,                 file)
    Marshal.dump($game_player,              file)
    Marshal.dump($v_maps,                   file)
    Marshal.dump($map_extra_events,         file)
    Marshal.dump($input_config,             file)
    Marshal.dump($game_options,             file)
    Marshal.dump(PHI::Formation.formations, file)
    Marshal.dump($hotspot_container,        file)
    Marshal.dump($game_index,               file)
    Marshal.dump($hotspot_container,        file)
    Marshal.dump($quests,                   file)
#~     Marshal.dump($game_caterpillar,    file)
    $input_config.save_inputs
  end
  #--------------------------------------------------------------------------
  # * Read Save Data
  #     file : file object for reading (opened)
  #--------------------------------------------------------------------------
  def read_save_data(file)
    characters           = Marshal.load(file)
    Graphics.frame_count = Marshal.load(file)
    @last_bgm            = Marshal.load(file)
    @last_bgs            = Marshal.load(file)
    $game_system         = Marshal.load(file)
    $game_message        = Marshal.load(file)
    $game_switches       = Marshal.load(file)
    $game_variables      = Marshal.load(file)
    $game_self_switches  = Marshal.load(file)
    $game_actors         = Marshal.load(file)
    $game_party          = Marshal.load(file)
    $game_troop          = Marshal.load(file)
    $game_map            = Marshal.load(file)
    $game_player         = Marshal.load(file)
    begin
      $v_maps            = Marshal.load(file)
      $map_extra_events  = Marshal.load(file)
      $input_config      = Marshal.load(file)
      $game_options      = Marshal.load(file)
      PHI::Formation.set_formations(Marshal.load(file))
      $hotspot_container = Marshal.load(file)
      $game_index        = Marshal.load(file)
      $quests            = Marshal.load(file)
#~       $game_caterpillar  = Marshal.load(file)
    rescue
      p "Save file out of date, updating save file." if $enable_console
      $v_maps = V_Maps.new  if $v_maps.nil?
      $map_extra_events = {} if $map_extra_events.nil?
      $input_config     = Game_InputConfig.new if $input_config.nil?
      $game_options     = Game_Options.new if $game_options.nil?
      $hotspot_container= Hotspot_Manager.new if $hotspot_container.nil?
      $game_index       = Game_Index.new if $game_index.nil?
      $quests           = Pioneer_Book.new if $quests.nil?
#~       $game_caterpillar = Game_Caterpillar.new if $game_caterpillar.nil?
    end
    if $game_system.version_id != $data_system.version_id
      $game_map.setup($game_map.map_id)
      $game_player.center($game_player.x, $game_player.y)
    end
    $input_config.set_inputs($start_keyboard_preset)

    $game_party.moveto($game_player.x, $game_player.y)
    $game_party.refresh
    $game_party.prepare_line
    $game_party.snap_line
  end

end
