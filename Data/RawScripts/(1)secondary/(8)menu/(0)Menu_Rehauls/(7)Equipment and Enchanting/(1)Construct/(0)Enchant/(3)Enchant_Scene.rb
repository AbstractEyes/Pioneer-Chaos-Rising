class Enchant_Scene < Scene_Base

  def initialize(preserved_windows = nil)
    @preserved_windows = preserved_windows
  end

  def start
    super
    @background = Sprite.new
    @background.bitmap = Cache.system('/book/background')

    @equip_window = Equip_Inventory.new(0,0,$screen_width/2, $screen_width, 2)
    @equip_window.visible = true
    @equip_window.opacity = 0
    @equip_window.active = true

    @equip_help = Equipment_Help.new($screen_width/2, 0, $screen_width/2, $screen_height)
    @equip_help.visible = true
    @equip_help.opacity = 0

    @socket_window = Enchant_Socket_List.new(0, 80, $screen_width / 2, $screen_height - 80)
    @socket_window.visible = false
    @socket_window.opacity = 0
    @socket_window.active = false

    @socket_decision = Enchant_Socket_Decision.new(160, 80, 142, $screen_height - 80)
    @socket_decision.opacity = 0
    @socket_decision.active = false
    @socket_decision.visible = false

    @socket_header = Enchant_Socket_Header.new(0, 0, $screen_width / 2, 80)
    @socket_header.visible = false
    @socket_header.opacity = 0

    @socket_help = Enchant_Socket_Details.new($screen_width / 2, 0, $screen_width / 2, $screen_height)
    @socket_help.visible = false
    @socket_help.opacity = 0

    #todo: replace with element check, book, + memory for both
    @enchant_grid_list = Enchant_Grid_Interface.new(200, 0, $screen_width/2+128-64, 288+32)
    @enchant_grid_list.visible = false
    @enchant_grid_list.active = false
    #######################################################################
    @enchant_battery = Enchant_Battery_Interface.new(0,0,140,$screen_height)
    @enchant_battery.visible = false
    @enchant_battery.active = false

    @currency_window = Currency_Window.new(200 - 64, 288+32)
    @currency_window.refresh(2)
    @currency_window.visible = false

    @enchant_confirmation = Window_Command.new(120,
                                               ['Confirm', 'Cancecl'],
                                               1, 0, 4,
                                               @currency_window.x + @currency_window.width,
                                               @enchant_grid_list.height)
    @enchant_confirmation.visible = false
    @enchant_confirmation.active = false

    @disenchant_confirmation = Window_Command.new(240, ['Disenchant', 'Cancel'],
                                                           1, 2, 4,
                                                  $screen_width / 2 - 120,
                                                  32*2 + 24)
    @disenchant_confirmation.visible = false
    @disenchant_confirmation.active = false
    @disenchant_confirmation.refresh

    @last_enchant_index = $game_index.enchant_index

    @battery_wrapper = Battery_Wrapper.new
    @harmony_checker = Harmony.new(@battery_wrapper)

    @last_equip_index = -1
    open_equip_interface
  end

  def update
    super
    update_windows
    update_activity
    update_enchantment_indexes
    update_equipment_indexes
    #update_enchant_battery_indexes
  end
  def update_activity
    if @equip_window.active
      update_equip_inputs
    elsif @socket_decision.active
      update_enchant_decision_inputs
    elsif @disenchant_confirmation.active
      update_disenchant_confirmation_inputs
    elsif @enchant_grid_list.active
      update_enchant_grid_inputs
    elsif @enchant_confirmation.visible
      update_decision_confirmation_inputs
    end
  end

  def update_windows
    @background.update
    @socket_window.update
    @socket_header.update
    @socket_help.update
    @socket_decision.update
    @enchant_grid_list.update
    @enchant_battery.update
    @enchant_confirmation.update
    @currency_window.update
    @disenchant_confirmation.update
    @equip_window.update
    @equip_help.update
    #@enchant_costs.update
    #@enchant_battery_help.update
  end

  def terminate
    super
    @background.dispose
    @socket_window.dispose
    @socket_header.dispose
    @socket_help.dispose
    @socket_decision.dispose
    @enchant_grid_list.dispose
    #@enchant_battery_help.dispose
    @enchant_battery.dispose
    @enchant_confirmation.dispose
    @currency_window.dispose
    @disenchant_confirmation.dispose
    @equip_window.dispose
    @equip_help.dispose
    #@enchant_costs.update
  end

  def update_equipment_indexes
    if @last_equip_index != @equip_window.index
      @last_equip_index = @equip_window.index
      @equip_help.refresh(@equip_window.equip)
    end
  end
  def update_enchantment_indexes
    if @last_enchant_index != @socket_decision.index
      @last_enchant_index = @socket_decision.index
      $game_index.socket_index = @socket_decision.index / 3
      @socket_window.index = $game_index.socket_index
      @socket_help.refresh(@equip_window.equip, @last_enchant_index / 3)
    end
  end
  def update_enchant_battery_indexes
    if @last_battery_index != @enchant_battery.index
      @last_battery_index = @enchant_battery.index
      $game_index.battery_index = @enchant_battery.index
      #@enchant_battery_help.refresh
    end
  end

  def open_equip_interface
    @equip_window.visible = true
    @equip_window.active = true
    @equip_help.visible = true
  end

  def close_equip_interface
    @equip_window.visible = false
    @equip_window.active = false
    @equip_help.visible = false
  end

  def open_enchant_socket_interface
    @socket_window.visible = true
    @socket_header.visible = true
    @socket_help.visible = true
    @socket_window.refresh(@equip_window.equip)
    @socket_decision.refresh(@equip_window.equip)
    @socket_header.refresh(@equip_window.equip)
    @socket_help.refresh(@equip_window.equip, 0)
    @socket_window.active = true
    open_ec_interface
  end

  def refresh_socket_safe
    sindex = @socket_window.index
    @socket_window.refresh(@equip_window.equip)
    @socket_window.index = sindex
    sdec = @socket_decision.index
    @socket_decision.refresh(@equip_window.equip)
    @socket_decision.index = sdec
  end

  def open_ec_interface
    @socket_decision.visible = true
    @socket_decision.active = true
  end

  def close_ec_interface
    @socket_decision.visible = false
    @socket_decision.active = false
  end

  def close_enchant_socket_interface
    @socket_window.visible = false
    @socket_header.visible = false
    @socket_help.visible = false
    @socket_window.active = false
    @socket_window.active = false
    close_ec_interface
  end

  def open_battery_interface
    @background.visible = false
    @enchant_grid_list.visible = true
    #@enchant_battery_help.visible = true
    @enchant_grid_list.refresh(@equip_window.equip, @socket_window.index)
    @enchant_grid_list.index = 0
    @enchant_grid_list.active = true
    @enchant_battery.visible = true
    #@enchant_battery.active = true
    @battery_wrapper = Battery_Wrapper.new
    @harmony_checker = Harmony.new(@battery_wrapper)
    @battery_wrapper.refresh(@equip_window.equip, @socket_window.index)
    @enchant_battery.refresh(@equip_window.equip, @socket_window.index, @battery_wrapper)
    @currency_window.visible = true
    @enchant_confirmation.index = 0
    set_currency_costs
  end

  def reopen_battery_interface
    @enchant_grid_list.visible = true
    #@enchant_battery_help.visible = true
    @enchant_battery.refresh(@equip_window.equip, @socket_window.index, @battery_wrapper)
    @enchant_grid_list.refresh(@equip_window.equip, @socket_window.index)
    @enchant_grid_list.index = 0
    @enchant_grid_list.active = true
    @enchant_battery.visible = true
    @currency_window.visible = true
    @enchant_confirmation.index = 0
    set_currency_costs
  end

  def close_battery_interface
    @background.visible = true
    @enchant_grid_list.visible = false
    @enchant_grid_list.active = false
    @enchant_battery.visible = false
    @currency_window.visible = false
  end

  def open_enchant_confirmation
    @enchant_confirmation.visible = true
    @enchant_confirmation.active = true
    @currency_window.refresh(@battery_wrapper)
    @currency_window.visible = true
  end

  def close_enchant_confirmation
    @enchant_confirmation.visible = false
    @enchant_confirmation.active = false
    @currency_window.visible = false
  end

  def update_equip_inputs
    if Input.trigger?(PadConfig.decision)
      Sound.play_equip
      close_equip_interface
      open_enchant_socket_interface
    elsif Input.trigger?(PadConfig.cancel)
      close_equip_interface
      $scene = Scene_Pioneer_Book.new
    end
  end

  def update_disenchant_confirmation_inputs
    if Input.trigger?(PadConfig.decision)
      if @disenchant_confirmation.index == 0
        #if @battery_wrapper.can_pay?
        Sound.play_equip
        p 'disenchant'
        $game_party.reward_currencies(@socket_window.enchantment)
        $game_party.equipment[@equip_window.equip].disenchant(@socket_window.index)
        refresh_socket_safe
        @disenchant_confirmation.active = false
        @disenchant_confirmation.visible = false
        @socket_window.active = true
        @socket_decision.active = true
      else
        Sound.play_cancel
        @disenchant_confirmation.active = false
        @disenchant_confirmation.visible = false
        @socket_window.active = true
        @socket_decision.active = true
      end
    elsif Input.trigger?(PadConfig.cancel)
      Sound.play_cancel
      @disenchant_confirmation.active = false
      @disenchant_confirmation.visible = false
      @socket_window.active = true
      @socket_decision.active = true
    end
  end

  def update_decision_confirmation_inputs
    if Input.trigger?(PadConfig.decision)
      #if @battery_wrapper.can_pay?
        Sound.play_equip
        #charge currencies
        #enchant
        $game_party.charge_currencies(@battery_wrapper.raw_costs)
        $game_party.equipment[@equip_window.equip].enchant(@socket_window.index, @battery_wrapper.enchantment)
        close_ec_interface
        close_battery_interface
        close_enchant_confirmation
        open_enchant_socket_interface
      #else
      #  Sound.play_buzzer
        #cannot pay, cancel last negative enchantment
      #end
    elsif Input.trigger?(PadConfig.cancel)
      Sound.play_cancel
      close_enchant_confirmation
      @battery_wrapper.remove_negative
      reopen_battery_interface
      #returns the
    end
  end

  def update_enchant_decision_inputs
    if Input.trigger?(PadConfig.decision)
        case @socket_decision.index % 3
          when 0 # Enchant
            # Open enchant interface
            if @socket_decision.enchantment_empty?
              close_enchant_socket_interface
              open_battery_interface
              Sound.play_decision
            else
              Sound.play_buzzer
            end
          when 1 # Disenchant
            # Check if socket is enchanted,
            # if enchanted
            # Return a portion of globs if disenchanting
            if !@socket_decision.enchantment_empty?
              Sound.play_equip
              @socket_window.active = false
              @socket_decision.active = false
              @disenchant_confirmation.visible = true
              @disenchant_confirmation.active = true
            else
              Sound.play_buzzer
            end
          when 2 # Upgrade Socket
            # Check if socket can be upgraded based on equip level
            # Spend globs based on level to upgrade socket.
            # if can level socket
            # spend globs to upgrade socket
            # else play sound buzzer
          else
            #Sound.play_cancel
            #$scene = Equipment_Management_Scene.new(@preserved_windows)
        end
    #elsif Input.trigger?(PadConfig.hud)
    #  @currency_window.refresh(rand(4), {:markers => rand(350), :carbon => 18530})
    elsif Input.trigger?(PadConfig.cancel)
      Sound.play_cancel
      close_enchant_socket_interface
      open_equip_interface
      #$scene = Equipment_Management_Scene.new
      #close_ec_interface
      #open_enchant_socket_interface
      #@socket_window.active = true
    end
  end

  def update_enchant_socket_inputs
    if Input.trigger?(PadConfig.decision)
      Sound.play_decision
      @socket_window.active = false
      open_ec_interface
      open_battery_interface
      @enchant_grid_list.active = false
    elsif Input.trigger?(PadConfig.cancel)
      Sound.play_cancel
      close_enchant_socket_interface
      open_equip_interface
      #$scene = Equipment_Management_Scene.new(@preserved_windows)
    end
  end

  def confirmation_window_inputs
    if Input.trigger?(PadConfig.decision)
      Sound.play_decision
      close_enchant_confirmation
    elsif Input.trigger?(PadConfig.cancel)
      Sound.play_cancel
      close_enchant_confirmation
    end
  end

  def update_enchant_grid_inputs
    if Input.trigger?(PadConfig.decision)
      if !@battery_wrapper.can_use_book?(@enchant_grid_list.book_key, @enchant_grid_list.column)
        Sound.play_buzzer
      else
        case @battery_wrapper.positive
          when true
          p 'is positive, adding to positive'
          @battery_wrapper.add_positive( @enchant_grid_list.enchantment)
          set_currency_costs
          if @battery_wrapper.positive_full?
            #todo: set windows to negative
            p 'positive full switching to negative'
            @battery_wrapper.set_negative
          end
          @enchant_battery.refresh(@equip_window.equip, @socket_window.index, @battery_wrapper)
          Sound.play_equip
        else
          #check = @harmony_checker.missing_elements
          #p check.inspect
          #p @harmony_checker.check_element(@enchant_grid_list.enchantment).inspect
          if @harmony_checker.reduced?(@enchant_grid_list.enchantment)
            @battery_wrapper.add_negative(@enchant_grid_list.enchantment)
            set_currency_costs
            @enchant_battery.refresh(@equip_window.equip, @socket_window.index, @battery_wrapper)
            p 'is negative, adding to negative'
            if @harmony_checker.harmony?
              @enchant_grid_list.active = false
              open_enchant_confirmation
            end
            Sound.play_equip
          end
        end
        Sound.play_decision
      end
    elsif Input.trigger?(PadConfig.cancel)
      Sound.play_cancel
      #close_enchant_new_interface
      if @battery_wrapper.has_negative?
        @battery_wrapper.remove_negative
        if !@battery_wrapper.has_negative?
          @battery_wrapper.set_positive
          set_currency_costs
        end
        @enchant_battery.refresh(@equip_window.equip, @socket_window.index, @battery_wrapper)
        Sound.play_equip
      elsif @battery_wrapper.has_positive?
        @battery_wrapper.set_positive
        @battery_wrapper.remove_positive
        @enchant_battery.refresh(@equip_window.equip, @socket_window.index, @battery_wrapper)
        set_currency_costs
        Sound.play_equip
      else
        close_battery_interface
        open_enchant_socket_interface
        Sound.play_buzzer
      end
    end
  end

  def set_currency_costs
    @currency_window.refresh(2, @battery_wrapper.costs_hash)
  end

end
