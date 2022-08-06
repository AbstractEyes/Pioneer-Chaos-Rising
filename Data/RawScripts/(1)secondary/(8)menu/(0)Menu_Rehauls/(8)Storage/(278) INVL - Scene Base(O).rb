################################################################################
# Scene_Map                                                                    #
#------------------------------------------------------------------------------#

class Scene_Map < Scene_Base

  def update_scene_change
    return if $game_player.moving?
    case $game_temp.next_scene
    when "battle"
      call_battle
    when "shop"
      call_shop
    when "name"
      call_name
    when "menu"
      call_menu
    when "save"
      call_save
    when "debug"
      call_debug
    when "gameover"
      call_gameover
    when "(2)title"
      call_title
    when "item"
      call_item
    when "storage"
      call_storage
    when "resource"
      call_resource
    when "reward"
      call_reward
    when "requirement"
      call_requirement
    else
      $game_temp.next_scene = nil
    end
  end

  def call_item
    if $game_temp.menu_beep
      Sound.play_decision
      $game_temp.menu_beep = false
    end
    $game_temp.next_scene = nil
    $scene = Scene_Item.new
  end
  
  def call_storage
    if $game_temp.menu_beep
      Sound.play_decision
      $game_temp.menu_beep = false
    end
    $game_temp.next_scene = nil
    $scene = Scene_ItemStorage.new
  end
  
  def call_resource
    if $game_temp.menu_beep
      Sound.play_decision
      $game_temp.menu_beep = false
    end
    $game_temp.next_scene = nil
    $scene = Scene_Resource_Chest.new
  end
  
  def call_reward
    if $game_temp.menu_beep
      Sound.play_decision
      $game_temp.menu_beep = false
    end
    $game_temp.next_scene = nil
    $scene = Scene_Reward_Chest.new
  end
  
  def call_requirement
    if $game_temp.menu_beep
      Sound.play_decision
      $game_temp.menu_beep = false
    end
    $game_temp.next_scene = nil
    $scene = Scene_Requirement_Chest.new
  end
  
end
