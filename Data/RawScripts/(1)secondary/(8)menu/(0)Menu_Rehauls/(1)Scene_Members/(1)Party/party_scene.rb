class Scene_Party < Scene_Base

  def start
    super
    @title_window = Party_Help.new(0, 0, 120, 58)
    @title_window.set("Party")
    @party_window = Window_Party.new(0, 58, 78*5+32, 78*3+32)
    @party_window.active = true
    @last_party_index = -1
  end

  def terminate
    super
    @title_window.dispose
    @party_window.dispose
  end

  def update
    super
    @title_window.update
    @party_window.update
    if @last_party_index != @party_window.index
      @last_party_index = @party_window.index
      @party_window.refresh
    end
    if @party_window.active
      update_inputs
    end
  end

  def update_inputs
    if Input.trigger?(PadConfig.decision)
      if @party_window.locked?
        @party_window.set
        @party_window.unlock
        Sound.play_equip
      else
        @party_window.lock
        if !@party_window.member.nil?
          Sound.play_decision
        else
          @party_window.unlock
          Sound.play_buzzer
        end
      end
      @party_window.refresh
    elsif Input.trigger?(PadConfig.cancel)
      Sound.play_cancel
      if @party_window.locked?
        @party_window.unlock
        @party_window.refresh
      else
        $scene = Scene_Pioneer_Book.new
      end
    end
  end

end