class Game_Interpreter
  
  def enable_player_sight
    $game_player.enable_sight
    $new_events = true
  end
  
  def disable_player_sight
    $game_player.disable_sight
    $new_events = true
  end
  
  def enable_sight
    $game_map.events[@event_id].enable_sight
    $new_events = true
  end
  
  def disable_sight
    $game_map.events[@event_id].disable_sight
    $new_events = true
  end
  
  def bacon_method_bacon
    $game_party.members[0].set_message("Tacos")
  end
  def bacon_method_bacon2
    $game_party.members[0].set_message("Bacon")
  end
  def bacon_method_bacon3
    $game_party.members[0].set_message("Taquitos")
  end
  
end