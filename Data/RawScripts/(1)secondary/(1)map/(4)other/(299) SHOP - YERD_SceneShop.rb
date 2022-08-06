#===============================================================================
#
# Yanfly Engine RD - Scene Shop ReDux
# Last Date Updated: 2009.06.08
# Level: Normal
# 
# The shop scene was more or less fine by itself aside from a few efficiency
# issues. This script patches up those efficiency problems in and displays more
# data given for buyable items. Before, we received nothing but a blank number
# input window only to show us how much of the item is being bought. The script
# makes use of that empty space to give a little more detail on what is being
# purchased. The status window also more or less compares only one stat. This
# script will increase that to the four ADSA stats. For games with more than 4
# party members, you may have experienced that the status window didn't have
# enough room to show. Imported from KGC is the ability to scroll that window
# to allow for a more comfortable and informative shop scene.
#
#===============================================================================
# Updates:
# ----------------------------------------------------------------------------
# o 2009.06.08 - Finished script.
# o 2009.06.07 - Started script.
#===============================================================================
# Instructions
#===============================================================================
#
# For the most part, this script is plug and play. Scroll down and change the
# various settings under the module.
#
#===============================================================================
#
# Compatibility
# - Works With: KGC's Equip Extension
# - Works With: Yanfly's Extra Equipment Options
# - Overwrites: Scene_Shop: update
# - Overwrites: Window_ShopNumber: refresh
# - Overwrites: Window_ShopStatus: refresh
#
#===============================================================================
# Credits:
# KGC for shop status scrolling method.
#===============================================================================

$imported = {} if $imported == nil
$imported["SceneShopReDux"] = true

module YE
  module REDUX
    module SHOP
      
      #------------------------------------------------------------------------
      # STATUS WINDOW OPTIONS
      #------------------------------------------------------------------------
      
      # This adjusts the text for the status window over on the right.
      POSSESSION = "Possession"       # How many items in possession of party.
      EQUIPPED   = "Equipped"         # Appears if actor has item equipped.
      
      # This button is used to scroll the status window if it is too short.
      # This has been made mostly for games with more than 4 party members.
      SCROLL_KEY = Input::Y
      
      # The following adjusts the icons used for stat increases and decreases.
      # Just refer them to ATK, DEF, SPI, and AGI in that order.
      STAT_INCREASE = [1916, 1917, 1918, 1919]
      STAT_DECREASE = [1932, 1933, 1934, 1935]
      
      #------------------------------------------------------------------------
      # PURCHASE WINDOW OPTIONS
      #------------------------------------------------------------------------
      
      # The following determines the text displayed at the amount selection
      # screen. Change the information here accordingly.
      PURCHASE = "Purchase"           # Title of purchasing information.
      COST_ICN = 205                  # Icon of total cost.
      COST_TXT = "Total Cost"         # Text for total cost.
      ITEMSTAT = "Item Info"          # Text for item data.
      WPN_STAT = "Weapon Info"        # Text for weapon data.
      ARM_STAT = "Armour Info"        # Text for armour data.
      NOEFFECT = "----------"         # Text if no data is revealed.
      FONTSIZE = 16                   # Font size used for data text.
      
      # The following adjusts extra increment increases for pressing L or R
      # while the number window is open.
      LR_INCREMENT = 100
      
      # This part defines the data used for item/equipment properties.
      HP_HEAL_TEXT = "HP Effect"      # Text used for HP recovery.
      HP_HEAL_ICON = 1896              # Icon used for HP recovery.
      MP_HEAL_TEXT = "MP Effect"      # Text used for MP recovery.
      MP_HEAL_ICON = 1896              # Icon used for MP recovery.
      ERASE_STATE  = "Removes Status" # Text used for removing states.
      APPLY_STATE  = "Applies Status" # Text used for applying states.
      PARAM_BOOST  = "Raises %s"      # Text used for parameter raising.
      SPELL_EFFECT = "Spell Effect"   # Text used for spell effect items.
      SPELL_DAMAGE = "%d Base Dmg"    # Text used for spell damage.
      SPELL_HEAL   = "%d Base Heal"   # Text used for spell healing.
      NO_EQ_STAT   = "---"            # Text used when no equip
      EQ_ELEMENT_W = "Apply Element"  # Text used to represent equip elements.
      EQ_ELEMENT_A = "Guard Element"  # Text used to represent equip elements.
      EQ_STATUS_W  = "Apply Status"   # Text used to represent equip states.
      EQ_STATUS_A  = "Guard Status"   # Text used to represent equip states.
      
      # These are the general icons and text used for various aspects of new
      # shop windows. Used for items and equips alike.
      ICON_HP  = 1745            # Icon for MAXHP
      TEXT_HP  = "MaxHP"       # Text for MAXHP
      ICON_MP  = 1749           # Icon for MAXMP
      TEXT_MP  = "MaxMP"       # Text for MAXMP
      ICON_ATK = 1572             # Icon for ATK
      TEXT_ATK = "ATK"         # Text for ATK
      ICON_DEF = 1575            # Icon for DEF
      TEXT_DEF = "DEF"         # Text for DEF
      ICON_SPI = 1573            # Icon for SPI
      TEXT_SPI = "SPI"         # Text for SPI
      ICON_AGI = 1576            # Icon for AGI
      TEXT_AGI = "AGI"         # Text for AGI
      ICON_HIT  = 1897          # Icon for HIT
      TEXT_HIT  = "HIT"        # Text for HIT
      ICON_EVA  = 1903          # Icon for EVA
      TEXT_EVA  = "EVA"        # Text for EVA
      ICON_CRI  = 1898          # Icon for CRI
      TEXT_CRI  = "CRI"        # Text for CRI
      SHOW_CRI  = true         # Display CRI?
      ICON_ODDS = 137          # Icon for ODDS
      TEXT_ODDS = "LUK"        # Text for ODDS
      SHOW_ODDS = false         # Display ODDS?
      ICON_BASEDMG  = 119      # Used for base damage.
      ICON_BASEHEAL = 128      # Used for base healing.
      
      # The following determines which elements can be shown in the elements
      # list. If an element is not included here, it is ignored.
      SHOWN_ELEMENTS ={
      # ElID => IconID
           1 => 418,
           2 => 3,
           3 => 129,
           4 => 209,
           5 => 338,
           6 => 146,
           7 => 1884,
           8 => 1914,
           9 => 1864,
          10 => 1865,
          11 => 1866,
          12 => 1867,
          13 => 1868,
          14 => 1869,
          15 => 1870,
          16 => 1871,
      } # Do not remove this.
      
    end # SHOP
  end # REDUX
end # YE

#===============================================================================
# Editting anything past this point may potentially result in causing computer
# damage, incontinence, explosion of user's head, coma, death, and/or halitosis.
# Therefore, edit at your own risk.
#===============================================================================

#===============================================================================
# Scene_Shop
#===============================================================================

class Scene_Shop < Scene_Base
  
  #--------------------------------------------------------------------------
  # overwrite update
  #--------------------------------------------------------------------------
  def update
    super
    update_menu_background
    if @command_window.active
      @command_window.update
      @dummy_window.update
      update_command_selection
    elsif @status_window.visible and Input.press?(PadConfig.hud)
      update_scroll_status
    elsif @buy_window.active
      @gold_window.update
      @help_window.update
      @buy_window.update
      @status_window.cursor_rect.empty
      @status_window.update
      update_buy_selection
    elsif @sell_window.active
      @gold_window.update
      @help_window.update
      @sell_window.update
      update_sell_selection
    elsif @number_window.active
      @number_window.update
      @status_window.cursor_rect.empty
      @status_window.update
      update_number_input
    end
  end
  
  #--------------------------------------------------------------------------
  # update_scroll_status
  #--------------------------------------------------------------------------
  def update_scroll_status
    @status_window.cursor_rect.width = @status_window.contents.width
    @status_window.cursor_rect.height = @status_window.height - 32
    @status_window.update
    if Input.press?(PadConfig.up)
      @status_window.oy = [@status_window.oy - 4, 0].max
    elsif Input.press?(PadConfig.down)
      max_pos = [@status_window.contents.height -
        (@status_window.height - 32), 0].max
      @status_window.oy = [@status_window.oy + 4, max_pos].min
    end
  end
  
end # Scene_Shop

#===============================================================================
# Window_ShopNumber
#===============================================================================

class Window_ShopNumber < Window_Base

  #--------------------------------------------------------------------------
  # overwrite refresh
  #--------------------------------------------------------------------------
  def refresh
    dy = 0
    sw = self.width - 32
    self.contents.clear
    self.contents.font.color = system_color
    self.contents.font.size = Font.default_size
    self.contents.draw_text(0, dy, sw, WLH, YE::REDUX::SHOP::PURCHASE, 1)
    dy += WLH
    self.contents.font.color = normal_color
    draw_item_name(@item, 0, dy)
    self.contents.draw_text(212, dy, 20, WLH, "×")
    self.contents.draw_text(218, dy, 50, WLH, @number, 2)
    self.cursor_rect.set(207, dy, 64, WLH)
    dy += WLH
    draw_icon(YE::REDUX::SHOP::COST_ICN, 0, dy)
    self.contents.draw_text(24, dy, sw-24, WLH, YE::REDUX::SHOP::COST_TXT)
    draw_currency_value(Integer(@price * @number), 4, dy, 264)
    dy += WLH
    if @item.is_a?(RPG::Item)
      draw_item_stats(dy, sw)
    else
      draw_equip_stats(dy, sw)
    end
  end
  
  #--------------------------------------------------------------------------
  # overwrite update
  #--------------------------------------------------------------------------
  def update
    super
    if self.active
      last_number = @number
      if Input.repeat?(PadConfig.right) and @number < @max
        @number += 1
      end
      if Input.repeat?(PadConfig.left) and @number > 1
        @number -= 1
      end
      if Input.repeat?(PadConfig.up) and @number < @max
        @number = [@number + 10, @max].min
      end
      if Input.repeat?(PadConfig.down) and @number > 1
        @number = [@number - 10, 1].max
      end
      if Input.repeat?(PadConfig.page_up) and @number > 1
        @number = [@number - YE::REDUX::SHOP::LR_INCREMENT, 1].max
      end
      if Input.repeat?(PadConfig.page_down) and @number < @max
        @number = [@number + YE::REDUX::SHOP::LR_INCREMENT, @max].min
      end
      if @number != last_number
        Sound.play_cursor
        refresh
      end
    end
  end
  
  #--------------------------------------------------------------------------
  # draw_item_stats
  #--------------------------------------------------------------------------
  def draw_item_stats(dy, sw)
    start_dy = dy
    self.contents.font.color = system_color
    self.contents.draw_text(0, dy, sw, WLH, YE::REDUX::SHOP::ITEMSTAT, 1)
    self.contents.font.size = YE::REDUX::SHOP::FONTSIZE
    #-----
    if @item.base_damage != 0
      dy += WLH
      if @item.base_damage > 0
        icon = YE::REDUX::SHOP::ICON_BASEDMG
        result = sprintf(YE::REDUX::SHOP::SPELL_DAMAGE, @item.base_damage)
      else
        icon = YE::REDUX::SHOP::ICON_BASEHEAL
        result = sprintf(YE::REDUX::SHOP::SPELL_HEAL, -@item.base_damage)
      end
      if @item.element_set != []
        for ele_id in @item.element_set
          next unless YE::REDUX::SHOP::SHOWN_ELEMENTS.include?(ele_id)
          icon = YE::REDUX::SHOP::SHOWN_ELEMENTS[ele_id]
          break
        end
      end
      text = YE::REDUX::SHOP::SPELL_EFFECT
      draw_icon(icon, 0, dy)
      self.contents.draw_text(24, dy, sw/2-24, WLH, text, 0)
      self.contents.font.color = normal_color
      self.contents.draw_text(sw/2, dy, sw/2, WLH, result, 2)
    end
    #-----
    if @item.hp_recovery != 0 or @item.hp_recovery_rate != 0
      self.contents.font.color = system_color
      dy += WLH
      draw_icon(YE::REDUX::SHOP::HP_HEAL_ICON, 0, dy)
      text = YE::REDUX::SHOP::HP_HEAL_TEXT
      self.contents.draw_text(24, dy, sw/2-24, WLH, text, 0)
      self.contents.font.color = normal_color
      if @item.hp_recovery_rate != 0 and @item.hp_recovery != 0
        text = sprintf("%+d%% %s", @item.hp_recovery_rate, Vocab::hp)
        self.contents.draw_text(sw/2, dy, sw/4, WLH, text, 2)
        text = sprintf("%+d %s", @item.hp_recovery, Vocab::hp)
        self.contents.draw_text(sw*3/4, dy, sw/4, WLH, text, 2)
      elsif @item.hp_recovery_rate != 0
        text = sprintf("%+d%% %s", @item.hp_recovery_rate, Vocab::hp)
        self.contents.draw_text(sw*3/4, dy, sw/4, WLH, text, 2)
      else
        text = sprintf("%+d %s", @item.hp_recovery, Vocab::hp)
        self.contents.draw_text(sw*3/4, dy, sw/4, WLH, text, 2)
      end
    end
    #-----
    if @item.mp_recovery != 0 or @item.mp_recovery_rate != 0
      self.contents.font.color = system_color
      dy += WLH
      draw_icon(YE::REDUX::SHOP::MP_HEAL_ICON, 0, dy)
      text = YE::REDUX::SHOP::MP_HEAL_TEXT
      self.contents.draw_text(24, dy, sw/2-24, WLH, text, 0)
      self.contents.font.color = normal_color
      if @item.mp_recovery_rate != 0 and @item.mp_recovery != 0
        text = sprintf("%+d%% %s", @item.mp_recovery_rate, Vocab::mp)
        self.contents.draw_text(sw/2, dy, sw/4, WLH, text, 2)
        text = sprintf("%+d %s", @item.mp_recovery, Vocab::mp)
        self.contents.draw_text(sw*3/4, dy, sw/4, WLH, text, 2)
      elsif @item.mp_recovery_rate != 0
        text = sprintf("%+d%% %s", @item.mp_recovery_rate, Vocab::mp)
        self.contents.draw_text(sw*3/4, dy, sw/4, WLH, text, 2)
      else
        text = sprintf("%+d %s", @item.mp_recovery, Vocab::mp)
        self.contents.draw_text(sw*3/4, dy, sw/4, WLH, text, 2)
      end
    end
    #-----
    if @item.plus_state_set != []
      self.contents.font.color = system_color
      dy += WLH
      self.contents.draw_text(0, dy, sw, WLH, YE::REDUX::SHOP::APPLY_STATE, 1)
      dx = (sw - (@item.plus_state_set.size * 24)) / 2
      dy += WLH
      for state_id in @item.plus_state_set
        state = $data_states[state_id]
        next if state == nil
        next if state.icon_index == 0
        draw_icon(state.icon_index, dx, dy)
        dx += 24
      end
    end
    if @item.minus_state_set != []
      self.contents.font.color = system_color
      dy += WLH
      self.contents.draw_text(0, dy, sw, WLH, YE::REDUX::SHOP::ERASE_STATE, 1)
      dx = (sw - (@item.minus_state_set.size * 24)) / 2
      dy += WLH
      for state_id in @item.minus_state_set
        state = $data_states[state_id]
        next if state == nil
        next if state.icon_index == 0
        draw_icon(state.icon_index, dx, dy)
        dx += 24
      end
    end
    #-----
    if @item.parameter_type != 0
      self.contents.font.color = system_color
      dy += WLH
      case @item.parameter_type
      when 1
        icon = YE::REDUX::SHOP::ICON_HP
        text = YE::REDUX::SHOP::TEXT_HP
      when 2
        icon = YE::REDUX::SHOP::ICON_MP
        text = YE::REDUX::SHOP::TEXT_MP
      when 3
        icon = YE::REDUX::SHOP::ICON_ATK
        text = YE::REDUX::SHOP::TEXT_ATK
      when 4
        icon = YE::REDUX::SHOP::ICON_DEF
        text = YE::REDUX::SHOP::TEXT_DEF
      when 5
        icon = YE::REDUX::SHOP::ICON_SPI
        text = YE::REDUX::SHOP::TEXT_SPI
      when 6
        icon = YE::REDUX::SHOP::ICON_AGI
        text = YE::REDUX::SHOP::TEXT_AGI
      end
      draw_icon(icon, 0, dy)
      boost = sprintf(YE::REDUX::SHOP::PARAM_BOOST, text)
      self.contents.draw_text(24, dy, sw/2-24, WLH, boost, 0)
      self.contents.font.color = normal_color
      param = sprintf("%+d %s", @item.parameter_points, text)
      self.contents.draw_text(sw/2, dy, sw/2, WLH, param, 2)
    end
    #-----
    if start_dy == dy
      dy += WLH
      self.contents.font.color = normal_color
      self.contents.draw_text(0, dy, sw, WLH, YE::REDUX::SHOP::NOEFFECT, 1)
    end
  end
  
  #--------------------------------------------------------------------------
  # draw_equip_stats
  #--------------------------------------------------------------------------
  def draw_equip_stats(dy, sw)
    self.contents.font.color = system_color
    if @item.is_a?(RPG::Weapon)
      self.contents.draw_text(0, dy, sw, WLH, YE::REDUX::SHOP::WPN_STAT, 1)
    else
      self.contents.draw_text(0, dy, sw, WLH, YE::REDUX::SHOP::ARM_STAT, 1)
    end
    self.contents.font.size = YE::REDUX::SHOP::FONTSIZE
    dy += 24
    if $imported["ExtraEquipmentOptions"]
      #---MaxHP---
      if @item.bonus_paramp[:maxhp] != 100
        text = sprintf("%+d%%", @item.bonus_paramp[:maxhp] - 100)
        enabled = true
      elsif @item.bonus_param[:maxhp] != 0
        text = sprintf("%+d", @item.bonus_param[:maxhp])
        enabled = true
      else
        text = YE::REDUX::SHOP::NO_EQ_STAT
        enabled = false
      end
      self.contents.font.color = system_color
      self.contents.font.color.alpha = enabled ? 255 : 128
      self.contents.draw_text(24, dy, sw/2-24, WLH, YE::REDUX::SHOP::TEXT_HP)
      self.contents.font.color = normal_color
      self.contents.font.color.alpha = enabled ? 255 : 128
      draw_icon(YE::REDUX::SHOP::ICON_HP, 0, dy, enabled)
      self.contents.draw_text(sw*1/4, dy, sw/5, WLH, text, 2)
      #---MaxMP---
      if @item.bonus_paramp[:maxmp] != 100
        text = sprintf("%+d%%", @item.bonus_paramp[:maxmp] - 100)
        enabled = true
      elsif @item.bonus_param[:maxmp] != 0
        text = sprintf("%+d", @item.bonus_param[:maxmp])
        enabled = true
      else
        text = YE::REDUX::SHOP::NO_EQ_STAT
        enabled = false
      end
      self.contents.font.color = system_color
      self.contents.font.color.alpha = enabled ? 255 : 128
      self.contents.draw_text(sw/2+24, dy, sw/2-24, WLH, YE::REDUX::SHOP::TEXT_MP)
      self.contents.font.color = normal_color
      self.contents.font.color.alpha = enabled ? 255 : 128
      draw_icon(YE::REDUX::SHOP::ICON_MP, sw/2, dy, enabled)
      self.contents.draw_text(sw*3/4, dy, sw/5, WLH, text, 2)
      #------
      dy += 24
      #------
    end
    #---ATK---
    if $imported["ExtraEquipmentOptions"] and @item.bonus_paramp[:atk] != 100
      text = sprintf("%+d%%", @item.bonus_paramp[:atk] - 100)
      enabled = true
    elsif $imported["ExtraEquipmentOptions"] and @item.bonus_param[:atk] != 0
      text = sprintf("%+d", @item.bonus_param[:atk] + @item.atk)
      enabled = true
    elsif @item.atk != 0
      text = sprintf("%+d", @item.atk)
      enabled = true
    else
      text = YE::REDUX::SHOP::NO_EQ_STAT
      enabled = false
    end
    self.contents.font.color = system_color
    self.contents.font.color.alpha = enabled ? 255 : 128
    self.contents.draw_text(24, dy, sw/2-24, WLH, YE::REDUX::SHOP::TEXT_ATK)
    self.contents.font.color = normal_color
    self.contents.font.color.alpha = enabled ? 255 : 128
    draw_icon(YE::REDUX::SHOP::ICON_ATK, 0, dy, enabled)
    self.contents.draw_text(sw*1/4, dy, sw/5, WLH, text, 2)
    #---DEF---
    if $imported["ExtraEquipmentOptions"] and @item.bonus_paramp[:def] != 100
      text = sprintf("%+d%%", @item.bonus_paramp[:def] - 100)
      enabled = true
    elsif $imported["ExtraEquipmentOptions"] and @item.bonus_param[:def] != 0
      text = sprintf("%+d", @item.bonus_param[:def] + @item.def)
      enabled = true
    elsif @item.def != 0
      text = sprintf("%+d", @item.def)
      enabled = true
    else
      text = YE::REDUX::SHOP::NO_EQ_STAT
      enabled = false
    end
    self.contents.font.color = system_color
    self.contents.font.color.alpha = enabled ? 255 : 128
    self.contents.draw_text(sw/2+24, dy, sw/2-24, WLH, YE::REDUX::SHOP::TEXT_DEF)
    self.contents.font.color = normal_color
    self.contents.font.color.alpha = enabled ? 255 : 128
    draw_icon(YE::REDUX::SHOP::ICON_DEF, sw/2, dy, enabled)
    self.contents.draw_text(sw*3/4, dy, sw/5, WLH, text, 2)
    #------
    dy += 24
    #---SPI---
    if $imported["ExtraEquipmentOptions"] and @item.bonus_paramp[:spi] != 100
      text = sprintf("%+d%%", @item.bonus_paramp[:spi] - 100)
      enabled = true
    elsif $imported["ExtraEquipmentOptions"] and @item.bonus_param[:spi] != 0
      text = sprintf("%+d", @item.bonus_param[:spi] + @item.spi)
      enabled = true
    elsif @item.spi != 0
      text = sprintf("%+d", @item.spi)
      enabled = true
    else
      text = YE::REDUX::SHOP::NO_EQ_STAT
      enabled = false
    end
    self.contents.font.color = system_color
    self.contents.font.color.alpha = enabled ? 255 : 128
    self.contents.draw_text(24, dy, sw/2-24, WLH, YE::REDUX::SHOP::TEXT_SPI)
    self.contents.font.color = normal_color
    self.contents.font.color.alpha = enabled ? 255 : 128
    draw_icon(YE::REDUX::SHOP::ICON_SPI, 0, dy, enabled)
    self.contents.draw_text(sw*1/4, dy, sw/5, WLH, text, 2)
    #---AGI---
    if $imported["ExtraEquipmentOptions"] and @item.bonus_paramp[:agi] != 100
      text = sprintf("%+d%%", @item.bonus_paramp[:agi] - 100)
      enabled = true
    elsif $imported["ExtraEquipmentOptions"] and @item.bonus_param[:agi] != 0
      text = sprintf("%+d", @item.bonus_param[:agi] + @item.agi)
      enabled = true
    elsif @item.agi != 0
      text = sprintf("%+d", @item.agi)
      enabled = true
    else
      text = YE::REDUX::SHOP::NO_EQ_STAT
      enabled = false
    end
    self.contents.font.color = system_color
    self.contents.font.color.alpha = enabled ? 255 : 128
    self.contents.draw_text(sw/2+24, dy, sw/2-24, WLH, YE::REDUX::SHOP::TEXT_AGI)
    self.contents.font.color = normal_color
    self.contents.font.color.alpha = enabled ? 255 : 128
    draw_icon(YE::REDUX::SHOP::ICON_AGI, sw/2, dy, enabled)
    self.contents.draw_text(sw*3/4, dy, sw/5, WLH, text, 2)
    #------
    dy += 24
    #---HIT---
    if $imported["ExtraEquipmentOptions"] and @item.bonus_paramp[:hit] != 100
      text = sprintf("%+d%%", @item.bonus_paramp[:hit] - 100)
      enabled = true
    elsif $imported["ExtraEquipmentOptions"] and @item.bonus_param[:hit] != 0
      value = @item.bonus_param[:hit]
      value += @item.hit if @item.is_a?(RPG::Weapon)
      text = sprintf("%+d%%", value)
      enabled = true
    elsif @item.is_a?(RPG::Weapon) and @item.hit != 0
      text = sprintf("%+d%%", @item.hit)
      enabled = true
    else
      text = YE::REDUX::SHOP::NO_EQ_STAT
      enabled = false
    end
    self.contents.font.color = system_color
    self.contents.font.color.alpha = enabled ? 255 : 128
    self.contents.draw_text(24, dy, sw/2-24, WLH, YE::REDUX::SHOP::TEXT_HIT)
    self.contents.font.color = normal_color
    self.contents.font.color.alpha = enabled ? 255 : 128
    draw_icon(YE::REDUX::SHOP::ICON_HIT, 0, dy, enabled)
    self.contents.draw_text(sw*1/4, dy, sw/5, WLH, text, 2)
    #---EVA---
    if $imported["ExtraEquipmentOptions"] and @item.bonus_paramp[:eva] != 100
      text = sprintf("%+d%%", @item.bonus_paramp[:eva] - 100)
      enabled = true
    elsif $imported["ExtraEquipmentOptions"] and @item.bonus_param[:eva] != 0
      text = sprintf("%+d%%", @item.bonus_param[:eva] + @item.eva)
      enabled = true
    elsif @item.is_a?(RPG::Armor) and @item.eva != 0
      text = sprintf("%+d%%", @item.eva)
      enabled = true
    else
      text = YE::REDUX::SHOP::NO_EQ_STAT
      enabled = false
    end
    self.contents.font.color = system_color
    self.contents.font.color.alpha = enabled ? 255 : 128
    self.contents.draw_text(sw/2+24, dy, sw/2-24, WLH, YE::REDUX::SHOP::TEXT_EVA)
    self.contents.font.color = normal_color
    self.contents.font.color.alpha = enabled ? 255 : 128
    draw_icon(YE::REDUX::SHOP::ICON_EVA, sw/2, dy, enabled)
    self.contents.draw_text(sw*3/4, dy, sw/5, WLH, text, 2)
    #------
    dy += 24
    #------
    if $imported["ExtraEquipmentOptions"] and YE::REDUX::SHOP::SHOW_CRI
      #---CRI---
      if @item.bonus_paramp[:cri] != 100
        text = sprintf("%+d%%", @item.bonus_paramp[:cri] - 100)
        enabled = true
      elsif @item.bonus_param[:cri] != 0
        text = sprintf("%+d%%", @item.bonus_param[:cri])
        enabled = true
      else
        text = YE::REDUX::SHOP::NO_EQ_STAT
        enabled = false
      end
      self.contents.font.color = system_color
      self.contents.font.color.alpha = enabled ? 255 : 128
      self.contents.draw_text(24, dy, sw/2-24, WLH, YE::REDUX::SHOP::TEXT_CRI)
      self.contents.font.color = normal_color
      self.contents.font.color.alpha = enabled ? 255 : 128
      draw_icon(YE::REDUX::SHOP::ICON_CRI, 0, dy, enabled)
      self.contents.draw_text(sw*1/4, dy, sw/5, WLH, text, 2)
    end
    if $imported["ExtraEquipmentOptions"] and YE::REDUX::SHOP::SHOW_ODDS
      #---ODDS---
      if @item.bonus_paramp[:odds] != 100
        text = sprintf("%+d%%", @item.bonus_paramp[:odds] - 100)
        enabled = true
      elsif @item.bonus_param[:odds] != 0
        text = sprintf("%+d", @item.bonus_param[:odds])
        enabled = true
      else
        text = YE::REDUX::SHOP::NO_EQ_STAT
        enabled = false
      end
      self.contents.font.color = system_color
      self.contents.font.color.alpha = enabled ? 255 : 128
      self.contents.draw_text(sw/2+24, dy, sw/2-24, WLH, YE::REDUX::SHOP::TEXT_ODDS)
      self.contents.font.color = normal_color
      self.contents.font.color.alpha = enabled ? 255 : 128
      draw_icon(YE::REDUX::SHOP::ICON_ODDS, sw/2, dy, enabled)
      self.contents.draw_text(sw*3/4, dy, sw/5, WLH, text, 2)
      #------
    end
    return if (dy + 48) >= (self.height - 32)
    #------ELEMENTS------
    drawn_elements = []
    for ele_id in YE::REDUX::SHOP::SHOWN_ELEMENTS
      break if @item.element_set == []
      if @item.element_set.include?(ele_id[0])
        drawn_elements.push(ele_id[0])
      end
    end
    if drawn_elements != [] # Draw Elements
      drawn_elements = drawn_elements.sort!
      dy += WLH
      if @item.is_a?(RPG::Weapon)
        text = YE::REDUX::SHOP::EQ_ELEMENT_W
      else
        text = YE::REDUX::SHOP::EQ_ELEMENT_A
      end
      self.contents.font.color = system_color
      self.contents.draw_text(0, dy, sw/2, WLH, text)
      dx = sw - (drawn_elements.size * 24)
      for ele_id in drawn_elements
        draw_icon(YE::REDUX::SHOP::SHOWN_ELEMENTS[ele_id], dx, dy)
        dx += 24
      end
    end
    return if (dy + 48) >= (self.height - 32)
    #------STATUS EFFECTS------
    drawn_states = []
    for state_id in @item.state_set
      state = $data_states[state_id]
      next if state == nil
      next if state.icon_index == 0
      drawn_states.push(state.icon_index)
    end
    if drawn_states != [] # Draw Elements
      dy += WLH
      if @item.is_a?(RPG::Weapon)
        text = YE::REDUX::SHOP::EQ_STATUS_W
      else
        text = YE::REDUX::SHOP::EQ_STATUS_A
      end
      self.contents.font.color = system_color
      self.contents.draw_text(0, dy, sw/2, WLH, text)
      dx = sw - (drawn_states.size * 24)
      for icon in drawn_states
        draw_icon(icon, dx, dy)
        dx += 24
      end
    end
  end
  
end # Window_ShopNumber

#===============================================================================
# Window_ShopStatus
#===============================================================================

class Window_ShopStatus < Window_Base
  
  #--------------------------------------------------------------------------
  # overwrite refresh
  #--------------------------------------------------------------------------
  
  
  def refresh
    self.contents.clear
    self.contents.font.size = Font.default_size
    return if @item == nil
    self.contents.font.color = system_color
    if $box_sell == true
      number = $game_party.stored_item_number(@item)
      self.contents.draw_text(4, 0, 200, WLH, "Stored")
    elsif $box_buy == true
      number = $game_party.stored_item_number(@item)
      self.contents.draw_text(4, 0, 200, WLH, "Stored")
    elsif $combined_shop == true
      number = $game_party.combined_item_number(@item)
      self.contents.draw_text(4, 0, 200, WLH, "Overall")
    else
      number = $game_party.item_number(@item)
      self.contents.draw_text(4, 0, 200, WLH, YE::REDUX::SHOP::POSSESSION)
    end
    self.contents.font.color = normal_color
    self.contents.draw_text(4, 0, 200, WLH, number, 2)
    return if @item.is_a?(RPG::Item)
    for actor in $game_party.members
      dx = 4
      dy = WLH * (2 + actor.index * 2)
      draw_actor_parameter_change(actor, dx, dy)
#~     end
    end
  end
  #--------------------------------------------------------------------------
  # overwrite draw_actor_parameter_change
  #--------------------------------------------------------------------------
  def draw_actor_parameter_change(actor, x, y)
    enabled = actor.equippable?(@item)
    sw = self.width - 32
    self.contents.font.color = normal_color
    self.contents.font.color.alpha = enabled ? 255 : 128
    self.contents.font.size = YE::REDUX::SHOP::FONTSIZE
    cx = contents.text_size(YE::REDUX::SHOP::EQUIPPED).width
    self.contents.font.size = Font.default_size
    self.contents.draw_text(x, y, sw-cx-4, WLH, actor.name)
    self.contents.font.size = YE::REDUX::SHOP::FONTSIZE
    if @item.is_a?(RPG::Weapon)
      item1 = weaker_weapon(actor)
    elsif actor.two_swords_style and @item.kind == 0
      item1 = nil
    else
      if $imported["EquipExtension"]
        index = actor.equip_type.index(@item.kind)
        item1 = (index != nil ? actor.equips[1 + index] : nil)
      else
        item1 = actor.equips[1 + @item.kind]
      end
    end
    if item1 == @item
      self.contents.draw_text(x, y, sw-4, WLH, YE::REDUX::SHOP::EQUIPPED, 2)
      draw_item_name(item1, x, y + WLH, enabled)
      return
    end
    #-----
    if enabled
      dx = 0
      dy = y + WLH
      for i in 0..3
        case i
        when 0
          atk1 = item1 == nil ? 0 : item1.atk
          atk2 = @item == nil ? 0 : @item.atk
          change = atk2 - atk1
        when 1
          def1 = item1 == nil ? 0 : item1.def
          def2 = @item == nil ? 0 : @item.def
          change = def2 - def1
        when 2
          spi1 = item1 == nil ? 0 : item1.spi
          spi2 = @item == nil ? 0 : @item.spi
          change = spi2 - spi1
        when 3
          agi1 = item1 == nil ? 0 : item1.agi
          agi2 = @item == nil ? 0 : @item.agi
          change = agi2 - agi1
        end
        if change > 0
          draw_icon(YE::REDUX::SHOP::STAT_INCREASE[i], dx, dy)
        elsif change < 0
          draw_icon(YE::REDUX::SHOP::STAT_DECREASE[i], dx, dy)
        end
        if change != 0
          text = sprintf("%+d", change)
          self.contents.draw_text(dx+24, dy, sw/4-24, WLH, text, 0)
        end
        dx += sw/4
      end
    end
    #-----
  end
  
end # Window_ShopStatus

#===============================================================================
#
# END OF FILE
#
#===============================================================================