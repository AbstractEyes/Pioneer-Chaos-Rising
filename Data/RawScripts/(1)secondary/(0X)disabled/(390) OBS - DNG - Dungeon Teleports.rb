=begin
class Game_Player < Game_Character

  def var_match(derp)
    $game_variables[170] = rand(derp)#Exit
    $game_variables[171] = rand(derp)#Entrance
    while($game_variables[170] == $game_variables[171])
      $game_variables[170] = rand(derp)
      $game_variables[171] = rand(derp)
    end
  end
  
  def ore_spawn(derp)
    $game_variables[181] = rand(derp)
  end
  
  def stone_spawn(derp)
    $game_variables[182] = rand(derp)
  end
  
  def fish_spawn(derp)
    $game_variables[183] = rand(derp)
  end
  
  def chest_spawn(derp)
    $game_variables[184] = rand(derp)
  end
  
  def plant_spawn(derp)
    $game_variables[185] = rand(derp)
  end
  
  def random_trap(derp)
    $game_variables[187] = rand(derp)
  end
  
  def random_artifact(area_odds)
    $game_variables[192] = rand(area_odds)
    if $game_variables[192] >= 1
      $game_switches[36] = true
    else
      $game_switches[36] = false
    end
  end

  def res_tran(map_id, x, y, direction)
    @transferring = true
    @new_map_id = map_id
    @new_x = x
    @new_y = y
    @new_direction = direction
  end
  
  def teleport_floor(map_id)
    $game_player.res_tran(map_id, 1, 1, 0)
  end
  
  def maze_floors(level)
    if level == 1
#~       $game_switches[21] = true#Level 1
      floor = rand(6)
      if floor == 0
        teleport_floor(2)
      elsif floor == 1
        teleport_floor(3)
      elsif floor == 2
        teleport_floor(4)
      elsif floor == 3
        teleport_floor(5)
      elsif floor == 4
        teleport_floor(6)
      elsif floor == 5
        teleport_floor(346)
      elsif floor == 6
        teleport_floor(33)
      end
    elsif level == 5
#~       $game_switches[22] = true#Level 5
      floor = rand(5)
      if floor == 0
        teleport_floor(16)
      elsif floor == 1
        teleport_floor(17)
      elsif floor == 2
        teleport_floor(18)
      elsif floor == 3
        teleport_floor(19)
      elsif floor == 4
        teleport_floor(20)
      elsif floor == 5
        teleport_floor(21)
      end

    elsif level == 10
    elsif level == 15
    elsif level == 20
    elsif level == 30
    elsif level == 40
    elsif level == 50
    elsif level == 60
    elsif level == 70
    end
  end
    
  def bosses(level)
    if level == 1
      $game_player.res_tran(7, 8, 10, 0)
    elsif level == 5
      $game_player.res_tran(23, 8, 10, 0)
    elsif level == 10
      $game_player.res_tran(41, 8, 10, 0)
    elsif level == 15
      $game_player.res_tran(50, 8, 10, 0)
    elsif level == 20
      $game_player.res_tran(62, 8, 10, 0)
    elsif level == 30
      $game_player.res_tran(128, 8, 10, 0)
    elsif level == 40
      $game_player.res_tran(129, 8, 10, 0)
    elsif level == 50
      $game_player.res_tran(130, 8, 10, 0)
    elsif level == 60
      $game_player.res_tran(132, 8, 10, 0)
    elsif level == 70
      $game_player.res_tran(131, 8, 10, 0)
    end
  end
  
  def statistic_artifacts(number)
    pl = $game_variables[1]      #Pioneer Level
    al = $game_variables[417]    #Artifact Level
    n = 0
    r = 0
    if pl.between?(0, 20)
      r = 1
    elsif pl.between?(21, 40)
      r = 2
    elsif pl.between?(41, 70)
      r = 3
    elsif pl.between?(71, 500)
      r = 1
    end
  
    if al == 1
      n = Integer(rand(24))
    elsif al == 2
      n = Integer(rand(28))
    elsif al == 3
      n = Integer(rand(32))
    else 
      n = Integer(rand(24))
    end
    n *= r
    
    case n
    when 0 .. 14
      n2 = Integer(rand(4))
      case n2
      when 0
      #Health/Defense
      $game_variables[402] += 1
      $game_switches[502] = true
      when 1
      #Attack/Agility
      $game_variables[403] += 1
      $game_switches[503] = true
      when 2
      #MP/Spirit
      $game_variables[404] += 1
      $game_switches[504] = true
      when 3
      #Dura/Luck
      $game_variables[405] += 1
      $game_switches[505] = true
      when 4
      #Resist/Dex
      $game_variables[406] += 1
      $game_switches[506] = true
      end
    when 15 .. 24
      
    when 25 .. 34
      
    when 35 .. 38
      
    end
    
    $game_variables[385] = random_output
    return
  end

  
end

#~     def floor(number)
#~       $game_variables[42] = number
#~     end

#~     def hotspot_reset(n)
#~       if $game_switches[] == 1
#~         n = 1
#~       else
#~         n = 0
#~       end
#~     end

#~   def teleport_floors(x, y, map_id)
#~     $game_variables[48] = x
#~     $game_variables[49] = y
#~     $game_variables[50] = map_id
#~   end
#~   
#~     $game_map.screen.pictures[map_id].erase 
#~     
#~     $game_party.perform_transfer
#~     $scene.update
#~   
#~     $scene = Scene_Map.new
=end