=begin
class Airship_Scene < Scene_Base
  
  def start
    super
    @viewport = Viewport.new(0, 0, 544, 416)
    @airship_header = Window_Help_Better.new(0,0,544/3,60)
    @airship_header.set_text("Regional Travel")
    @airship_window = Airship_Window.new(0,60,544/3,416-60)
    @airship_help = Airship_Help.new(544/3,0,(544/3)*2,416)
    @saved_index = -1
    @confirm_window = Airship_Confirm.new(544/2-60,416/2-40,120,80)
    @confirm_window.visible = false
    @confirm_window.active = false
  end
  
  def terminate
    super
    @viewport.dispose
    @airship_window.dispose
    @airship_help.dispose
    @confirm_window.dispose
    @airship_header.dispose
  end
  
  def update
    @airship_window.update
    @confirm_window.update
    if @airship_window.active
      update_airship_selection
    elsif @confirm_window.active
      update_confirm_selection
    end
    if @airship_window.active and @airship_window.index != @saved_index
      @saved_index = @airship_window.index
      @region = @airship_window.region(@airship_window.index)
      @airship_help.refresh(@region)
    end
  end
  
  def return_scene
    $scene = Scene_Map.new
  end
  
  def update_airship_selection
    if Input.trigger?(PadConfig.cancel)
      Sound.play_cancel
      return_scene
    elsif Input.trigger?(PadConfig.decision)
      return if @region == nil
      unless @region.name == "Exit"
        Sound.play_equip
        activate_confirm
      else
        Sound.play_cancel
        return_scene
      end
    end
  end
  
  def update_confirm_selection
    if Input.trigger?(PadConfig.cancel)
      Sound.play_cancel
      back_to_areas
    elsif Input.trigger?(PadConfig.decision)
      if @confirm_window.index == 0
        Sound.play_equip
        Graphics.wait(10)
        Sound.play_equip
        Graphics.wait(10)
        Sound.play_equip
        $game_variables[39] = @region.id + 1
        return_scene
      else
        Sound.play_cancel
        back_to_areas
      end
    end
  end
  
  def activate_confirm
    @airship_window.active = false
    @confirm_window.active = true
    @confirm_window.visible = true
  end
  
  def back_to_areas
    @confirm_window.active = false
    @confirm_window.visible = false
    @airship_window.active = true
  end
    
end
=end