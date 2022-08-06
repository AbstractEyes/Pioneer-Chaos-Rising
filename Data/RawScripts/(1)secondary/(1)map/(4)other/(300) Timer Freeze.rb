class Game_Interpreter
  
  def freeze_timer
    @last_timer_value = $game_system.timer
    $game_system.timer_working = false
  end
  
  def continue_timer
    $game_system.timer = @last_timer_value
    $game_system.timer_working = true
  end
  
end