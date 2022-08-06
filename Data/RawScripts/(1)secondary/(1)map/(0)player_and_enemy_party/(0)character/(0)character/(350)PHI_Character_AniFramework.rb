class Game_Interpreter
  #def custom_animation(animation_sym, animation_sequence = [])
  def custom_animation(animation_sym, animation_type=0, custom_sequence = [], reverse=false)
    @character.custom_animation(animation_sym, animation_type, custom_sequence, reverse)
  end

  def unlock_custom_animation
    @character.unlock_o_animation
  end

  def mv_left
    custom_animation(:move_left)
  end

  def mv_right
    custom_animation(:move_right)
  end

  def mv_up
    custom_animation(:move_up)
  end

  def mv_down
    custom_animation(:move_down)
  end

  def btl_mv_left
    custom_animation(:bat_move_left)
  end

  def btl_mv_right
    custom_animation(:bat_move_right)
  end

  def btl_mv_up
    custom_animation(:bat_move_up)
  end

  def btl_mv_down
    custom_animation(:bat_move_down)
  end

  def dialog(direction, lock)
    sym = 'dialog_'
    case direction
      when 0
        sym += 'left'
      when 1
        sym += 'right'
    end
    custom_animation(sym)
    #left right
  end

  def dead_ani
    custom_animation(:dead)
  end

  def dead_pause
    custom_animation(:dead, 1)
  end

  def dead_rise
    custom_animation(:dead, 3, [], true)
  end

  def victory
    custom_animation(:victory)
  end

  def unsheath
    custom_animation(:show_weapons)
  end

  def sheath
    custom_animation(:hide_weapons)
  end

  def idle_prep
    custom_animation(:idle_stance)
  end

  def idle_ani
    custom_animation(:idle_ani)
  end

  def bat_idle
    custom_animation(:bat_idle_stance)
  end

  def defend
    custom_animation(:defend)
  end

  def hitstun
    custom_animation(:hitstun)
  end

  def dodge
    custom_animation(:dodge)
  end

  def channel
    custom_animation(:channel)
  end

  def interrupted
    custom_animation(:interrupted)
  end

  def skill(index)
    sym = ('skill' + index.to_s).to_sym
    custom_animation(sym)
    #1-8
  end

  def mine
    custom_animation(:mine)
  end

  def use_item
    custom_animation(:use_item)
  end

  def gather
    custom_animation(:gather_item)
  end

  def fish
    custom_animation(:fish)
  end

  def alchemize
    custom_animation(:alchemize)
  end

  def disassemble
    custom_animation(:disassemble)
  end


end