$interpreter_messages = []
class Game_Interpreter
  
  def epic_command
#~     scroll_here
    for i in 0...1
      $game_map.events[@event_id].battle_animations.push 101+i
    end
  end

  def snap_camera_here
    $game_map.snap_to_event(@event_id)
  end

  def display_item(item_id)
    message = Window_MessagePopup.new($screen_width/2-85,$screen_height-85,100,60)
    message.item_popup(item_id,0,nil,nil,nil,nil,nil,2,nil,120)
    $interpreter_messages.push(message)
  end

  def display_full(item_id)
    message = Window_MessagePopup.new($screen_width/2-85,$screen_height-85,100,60)
    message.inventory_full_popup(item_id,0,nil,nil,nil,nil,nil,2,nil,120)
    $interpreter_messages.push(message)
  end

  def check_hotspot(level)
    #Todo; build functionality for the hotspot checker.
  end

  #def display_failed_item(name)
  #  return unless text.is_a?(String)
  #  message = Window_MessagePopup.new(544/2-50,416-60,100,60)
  #  message.popup("Cannot hold: " + name,60,nil,nil,nil,nil,nil,6)
  #  $interpreter_messages.push(message)
  #end
    
end