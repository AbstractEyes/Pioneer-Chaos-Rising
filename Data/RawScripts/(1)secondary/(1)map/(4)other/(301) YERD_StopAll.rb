#===============================================================================
#
# Yanfly Engine RD - Stop All Movement
# Last Date Updated: 2009.06.28
# Level: Normal
# 
# This was an old feature in (0X)RPG.rb Maker 2000 that wasn't brought over. When used,
# all events on the map would stop moving on their own (unless you force them
# to move) and they'll wait until ready. All of this is bound to a simple switch
# which will freeze all events on the map when on. Once off, everything will
# resume normally again.
#
#===============================================================================
# Updates:
# ----------------------------------------------------------------------------
# o 2009.06.28 - Started script and finished script.
#===============================================================================
# Instructions
#===============================================================================
#
# Scroll down and bind STOP_ALL to a switch. Then, when you want to use the
# "Stop All" command, just turn the switch on. Once you want it off, just turn
# the switch off.
#
#===============================================================================
#
# Compatibility
# - Alias: Game_Character: update_self_movement
#
#===============================================================================

$imported = {} if $imported == nil
$imported["StopAllMovement"] = true

module YE
  module EVENT
    module SWITCH
      
      # Bind this switch to "Stop All" self movement on the map.
      STOP_ALL = 434
      
    end # SWITCH
  end # EVENT
end # YE

#===============================================================================
# Editting anything past this point may potentially result in causing computer
# damage, incontinence, explosion of user's head, coma, death, and/or halitosis.
# Therefore, edit at your own risk.
#===============================================================================

#===============================================================================
# Game_Character
#===============================================================================

class Game_Character

  #--------------------------------------------------------------------------
  # alias update_self_movement
  #--------------------------------------------------------------------------
  alias update_self_movement_sam update_self_movement unless $@
  def update_self_movement
    unless $game_switches[YE::EVENT::SWITCH::STOP_ALL]
      update_self_movement_sam
    end
  end
  
end # Game_Character

#===============================================================================
#
# END OF FILE
#
#===============================================================================