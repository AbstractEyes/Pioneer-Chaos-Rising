################################################################################
# Scene_Shop                                                                   #
#------------------------------------------------------------------------------#

class Scene_Shop < Scene_Base

  def start
    super
    create_menu_background
    create_command_window
    if $game_temp.shop_purchase_only
      @gold_window = Window_Resource.new(384, 56)
      $data_system.terms.gold = "Collateral"
    else
      @gold_window = Window_Gold.new(384, 56)
      $data_system.terms.gold = "Coins"
    end
    #Resource Sales
    if $game_variables[413] == 0
      $resource_sell = 20
    elsif $game_variables[413] == 1
      $resource_sell = 18
    elsif $game_variables[413] == 2
      $resource_sell = 16
    else
      $resource_sell = 20
    end
    #Coin Sale
    if $game_variables[415] == 0
      $coin_sell = 2
    elsif $game_variables[415] == 1
      $coin_sell = 1.8
    elsif $game_variables[415] == 2
      $coin_sell = 1.6
    else
      $coin_sell = 2
    end
    #Resource Buy
    if $game_variables[412] == 0
      $resource_buy = 10
    elsif $game_variables[412] == 1
      $resource_buy = 12
    elsif $game_variables[412] == 2
      $resource_buy = 14
    else
      $resource_buy = 10
    end
    #Coin Buy
    if $game_variables[414] == 0
      $coin_buy = 1
    elsif $game_variables[414] == 1
      $coin_buy = 0.9
    elsif $game_variables[414] == 2
      $coin_buy = 0.8
    else
      $coin_buy = 1
    end
    @gold_window.refresh
    @help_window = Window_Help.new
    @dummy_window = Window_Base.new(0, 112, $screen_width, 304)
    @buy_window = Window_ShopBuy.new(0, 112)
    @buy_window.active = false
    @buy_window.visible = false
    @buy_window.help_window = @help_window
    @sell_window = Window_ShopSell.new(0, 112, $screen_width, 304)
    @sell_window.active = false
    @sell_window.visible = false
    @sell_window.help_window = @help_window
    @number_window = Window_ShopNumber.new(0, 112)
    @number_window.active = false
    @number_window.visible = false
    @status_window = Window_ShopStatus.new(304, 112)
    @status_window.visible = false
  end
  
  def create_command_window
    s1 = "Bag Buy"
    s2 = "Box Buy"
    s3 = "Bag Sell"
    s4 = "Box Sell"
    s5 = Vocab::ShopCancel
    @command_window = Window_Command.new(384, [s1, s2, s3, s4, s5], 5)
    @command_window.y = 56
  end
  
  def update_command_selection
    if Input.trigger?(PadConfig.cancel)
      Sound.play_cancel
      $data_system.terms.gold = "Markers"
      $box_sell = false
      $box_buy = false
      $scene = Scene_Map.new
    elsif Input.trigger?(PadConfig.decision)
      case @command_window.index
      when 0  # buy
        Sound.play_decision
        $box_buy = false
        $box_sell = false
        @command_window.active = false
        @dummy_window.visible = false
        @buy_window.visible = true
        @buy_window.active = true
        @buy_window.index = 0
        @buy_window.refresh
        @status_window.refresh
        @status_window.visible = true
      when 1  # box buy
        Sound.play_decision
        $box_buy = true
        $box_sell = false
        @command_window.active = false
        @dummy_window.visible = false
        @buy_window.visible = true
        @buy_window.active = true
        @buy_window.index = 0
        @buy_window.refresh
        @status_window.refresh
        @status_window.visible = true
      when 2  # sell
        Sound.play_decision
        $box_sell = false
        $box_buy = false
        @command_window.active = false
        @dummy_window.visible = false
        @sell_window.visible = true
        @sell_window.active = true
        @sell_window.index = 0
        @sell_window.refresh
      when 3  # box sell
        Sound.play_decision
        $box_buy = false
        $box_sell = true
        @command_window.active = false
        @dummy_window.visible = false
        @sell_window.visible = true
        @sell_window.active = true
        @sell_window.index = 0
        @sell_window.refresh
      when 4  # Quit
        Sound.play_decision
        $data_system.terms.gold = "Markers"
        $box_sell = false
        $box_buy = false
        $scene = Scene_Map.new
      end
    end
  end


  def update_buy_selection #for buy
    @status_window.item = @buy_window.item
    if Input.trigger?(PadConfig.cancel)
      Sound.play_cancel
      @command_window.active = true
      @dummy_window.visible = true
      $box_buy = false
      @buy_window.active = false
      @buy_window.visible = false
      @status_window.refresh
      @status_window.visible = false
      @status_window.item = nil
      @help_window.set_text("")
      return
    end
    if Input.trigger?(PadConfig.decision)
      @status_window.refresh
      if $game_temp.shop_purchase_only
        @item = @buy_window.item
        if $box_buy == true
          number = $game_party.stored_item_number(@item)
        else
          number = $game_party.item_number(@item)
        end
        if @item == nil or
          if (@item.price / $resource_buy) > $game_variables[6]
            Sound.play_buzzer
          elsif $box_buy == true
            Sound.play_decision
            max = @item.price < 1 ? 9999 : $game_variables[6] / (@item.price / $resource_buy)
            max = [max, 9999 - number].min
            @buy_window.active = false
            @buy_window.visible = false
            @number_window.set(@item, max, (@item.price / $resource_buy))
            @number_window.active = true
            @number_window.visible = true
          elsif $box_buy == false
            if $game_party.overall_checker(@item, 1)
              Sound.play_decision
              max = @item.price < 1 ? $game_party.full_stack_shop(@item) : $game_variables[6] / (@item.price / $resource_buy)
              max = [max, $game_party.full_stack_shop(@item) - number].min
              @buy_window.active = false
              @buy_window.visible = false
              @number_window.set(@item, max, (@item.price / $resource_buy))
              @number_window.active = true
              @number_window.visible = true
            else
              Sound.play_buzzer
            end
          else
            Sound.play_buzzer
          end
        else
          Sound.play_buzzer
        end
      else
        @item = @buy_window.item
        if $box_buy == true
          number = $game_party.stored_item_number(@item)
        else
          number = $game_party.item_number(@item)
        end
        if @item == nil or
          if (@item.price * $coin_buy) > $game_party.gold
            Sound.play_buzzer
          elsif $box_buy == true
            Sound.play_decision
            max = @item.price < 1 ? 9999 : $game_party.gold / (@item.price * $coin_buy)
            max = [max, 9999 - number].min
            @buy_window.active = false
            @buy_window.visible = false
            @number_window.set(@item, max, (@item.price * $coin_buy))
            @number_window.active = true
            @number_window.visible = true
          elsif $box_buy == false
            if $game_party.overall_checker(@item, 1)
              Sound.play_decision
              max = @item.price <= 1 ? $game_party.full_stack_shop(@item) : $game_party.gold / (@item.price * $coin_buy)
              max = [max, $game_party.full_stack_shop(@item) - number].min
              @buy_window.active = false
              @buy_window.visible = false
              @number_window.set(@item, max, (@item.price * $coin_buy))
              @number_window.active = true
              @number_window.visible = true
            end
          else
            Sound.play_buzzer
          end
        else
          Sound.play_buzzer
        end
      end
    end
  end
  
  def update_sell_selection #sale
    if Input.trigger?(PadConfig.cancel)
      Sound.play_cancel
      @command_window.active = true
      @dummy_window.visible = true
      @sell_window.active = false
      @sell_window.visible = false
      $box_sell = false
      @status_window.item = nil
      @help_window.set_text("")
    elsif Input.trigger?(PadConfig.decision)
      if $game_temp.shop_purchase_only
        if $box_sell == true
          @item = @sell_window.item
          @status_window.item = @item
          if @item == nil or (@item.price / $resource_sell) < 1 or @item.no_sell or $game_party.lose_check(@item, 1) 
            Sound.play_buzzer
          elsif @item.resource_item
            Sound.play_decision
            max = $game_party.stored_item_number(@item)
            loop do
              if $game_party.lose_check(@item, max)
                max -= 1
              else
                break
              end
            end
            @sell_window.active = false
            @sell_window.visible = false
            @number_window.set(@item, max, (@item.price / $resource_sell))
            @number_window.active = true
            @number_window.visible = true
            @status_window.visible = true
          else
            Sound.play_buzzer
          end
        elsif $box_sell == false
          @item = @sell_window.item
          @status_window.item = @item
          if @item == nil or (@item.price / $resource_sell) < 1 or @item.no_sell or $game_party.lose_check(@item, 1)
            Sound.play_buzzer
          elsif @item.resource_item
            Sound.play_decision
            max = $game_party.item_number(@item)
            loop do
              if $game_party.lose_check(@item, max)
                max -= 1
              else
                break
              end
            end
            @sell_window.active = false
            @sell_window.visible = false
            @number_window.set(@item, max, (@item.price / $resource_sell))
            @number_window.active = true
            @number_window.visible = true
            @status_window.visible = true
          else
            Sound.play_buzzer
          end
        end
      else
        if $box_sell == true
          @item = @sell_window.item
          @status_window.item = @item
          if @item == nil or (@item.price / $coin_sell) < 1 or @item.no_sell or $game_party.lose_check(@item, 1)
            Sound.play_buzzer
          else
            Sound.play_decision
            max = $game_party.stored_item_number(@item)
            loop do
              if $game_party.lose_check(@item, max)
                max -= 1
              else
                break
              end
            end
            @sell_window.active = false
            @sell_window.visible = false
            @number_window.set(@item, max, (@item.price / $coin_sell))
            @number_window.active = true
            @number_window.visible = true
            @status_window.visible = true
          end
        elsif $box_sell == false
          @item = @sell_window.item
          @status_window.item = @item
          if @item == nil or (@item.price / $coin_sell) < 1 or @item.no_sell or $game_party.lose_check(@item, 1)
            Sound.play_buzzer
          else
            Sound.play_decision
            max = $game_party.item_number(@item)
            loop do
              if $game_party.lose_check(@item, max)
                max -= 1
              else
                break
              end
            end
            @sell_window.active = false
            @sell_window.visible = false
            @number_window.set(@item, max, (@item.price / $coin_sell))
            @number_window.active = true
            @number_window.visible = true
            @status_window.visible = true
          end
        end
      end
    end
  end
  
  
  #--------------------------------------------------------------------------
  # * Cancel Number Input
  #--------------------------------------------------------------------------
  def cancel_number_input
    Sound.play_cancel
    @number_window.active = false
    @number_window.visible = false
    case @command_window.index
    when 0  # Buy
      @buy_window.active = true
      @buy_window.visible = true
    when 1  # box Buy
      @buy_window.active = true
      @buy_window.visible = true
    when 2  # Sell
      @sell_window.active = true
      @sell_window.visible = true
      @status_window.visible = false
    when 3  # box Sell
      @sell_window.active = true
      @sell_window.visible = true
      @status_window.visible = false

    end
  end
  #--------------------------------------------------------------------------
  # * Confirm Number Input
  #--------------------------------------------------------------------------
  def decide_number_input
    Sound.play_shop
    @number_window.active = false
    @number_window.visible = false
    case @command_window.index
    when 0  # Buy
      if $game_temp.shop_purchase_only
        $game_variables[6] -= (@number_window.number * (@item.price / $resource_buy))
      else
        $game_party.lose_gold(@number_window.number * (@item.price * $coin_buy))
      end
      $game_party.gain_item(@item, @number_window.number)
      @gold_window.refresh
      @buy_window.refresh
      @status_window.refresh
      @buy_window.active = true
      @buy_window.visible = true
    when 1  # Box Buy
      if $game_temp.shop_purchase_only
        $game_variables[6] -= (@number_window.number * (@item.price / $resource_buy))
      else
        $game_party.lose_gold(@number_window.number * (@item.price * $coin_buy))
      end
      $game_party.store_item(@item, @number_window.number)
      @gold_window.refresh
      @buy_window.refresh
      @status_window.refresh
      @buy_window.active = true
      @buy_window.visible = true
    when 2  # sell
      if $game_temp.shop_purchase_only
        $game_variables[6] += (@number_window.number * (@item.price / $resource_sell))
      else
        $game_party.gain_gold(@number_window.number * (@item.price / $coin_sell))
      end
      $game_party.lose_item(@item, @number_window.number)
      @gold_window.refresh
      @sell_window.refresh
      @status_window.refresh
      @sell_window.active = true
      @sell_window.visible = true
      @status_window.visible = false
    when 3  # box sell
      if $game_temp.shop_purchase_only
        $game_variables[6] += (@number_window.number * (@item.price / $resource_sell))
      else
        $game_party.gain_gold(@number_window.number * (@item.price / $coin_sell))
      end
      $game_party.unstore_item(@item, @number_window.number)
      @gold_window.refresh
      @sell_window.refresh
      @status_window.refresh
      @sell_window.active = true
      @sell_window.visible = true
      @status_window.visible = false

    end
  end
  
end