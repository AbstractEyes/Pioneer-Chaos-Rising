=begin
#===============================================================================
# 
# Yanfly Engine Zealous - Equipment Overhaul
# Last Date Updated: 2010.08.23
# Level: Normal, Hard, Lunatic
# 
# This script essentially redefines the way the equipment system works while
# keeping the (0)core without rewriting too much. It will also recalculate the
# stats applied through equipment by the order of operations properly so that
# the numbers aren't a jumbled up uncontrollable mess. In addition to fixing
# the calculation regarding the order of operations, this script also changes
# the equipment scene with a different layout and more efficient methods.
# 
# Equipment can also require certain conditions to be met first before being
# able to be equipped. These conditions include reaching a certain level, having
# more or less than a certain number for their stat, or even having a switch to
# be enabled. These requirements can be done through simple tags.
# 
# An aptitude system is also included in the script, where certain (0)classes can
# receive more or less bonus from certain stat increases from equipment. For
# example, a warrior will receive less INT than a mage would from a piece of
# equipment. Aptitude is also flexible and can be adjusted through items, too.
# 
#===============================================================================
# Updates
# -----------------------------------------------------------------------------
# o 2010.08.23 - Bugfix regarding optimization.
# o 2010.08.16 - Bugfix regarding unequipping items with MaxHP and MaxMP.
# o 2010.06.24 - Unequip bug has been fixed.
# o 2010.06.03 - Efficiency update.
# o 2010.05.24 - Converted to Yanfly Engine Melody.
#===============================================================================
# Instructions
# -----------------------------------------------------------------------------
# To install this script, open up your script editor and copy/paste this script
# to an open slot below ▼ Materials but above ▼ Main. Remember to save.
# 
# -----------------------------------------------------------------------------
# Item Tags - Insert the following tags into usable Item noteboxes.
# -----------------------------------------------------------------------------
# <stat aptitude: +x%>  or  <stat aptitude: -x%>
# This will raise or lower the stat's aptitude by x%. Replace stat with one of
# the following: MaxHP, MaxMP, ATK, DEF, SPI, RES, DEX, or AGI
# 
# -----------------------------------------------------------------------------
# Equip Tags - Insert the following tags into Weapon and Armour noteboxes.
# -----------------------------------------------------------------------------
# <stat: +x>   or  <stat: -x>
# <stat: +x%>  or  <stat: -x%>
# This will allow the piece of equipment to raise or lower the stat by x in
# either a set amount or percentile amount. Note that percents are calculated
# before set values. Percents are also ignored from equip optimization. This
# tag will allow you to go past the 500 maximum value that the editor has.
# Replace stat with one of the following: 
#      MaxHP, MaxMP, ATK, DEF, SPI, AGI, HIT, EVA, CRI, ODDS
# 
# <trait: phrase>
# This will give your piece of equipment some unique traits. Just replace the
# word phrase inside the tag with one of the following:
#   super guard      - Guarding reduces damage by 4x instead of 2x.
#   pharmacology     - Items used will have double effect.
#   fast attack      - Early turn initiative.
#   dual attack      - Normal attacks hit twice.
#   prevent critical - Criticals cannot occur on battler.
#   half mp cost     - MP skills cost only half.
#   double exp gain  - Inflicted actor gains double exp.
#   auto hp recover  - Inflicted actor gains HP each turn and step.
# 
# <auto state: x> or <auto states: x,x>
# This will cause the piece of equipment to have states x automatically on the
# actor so long as the actor has the item equipped. Once unequipped, the state
# will no longer be applied to the actor.
# 
# <require above: stat x> or <require under: stat x>
# This will make your piece of equipment require certain stat conditions to be
# met. If above, it is greater than or equal to. If under, it is less than or
# equal to. Replace stat with one of the following: 
#    Level, MaxHP, MaxMP, ATK, DEF, SPI, RES, DEX, AGI, HIT, EVA, CRI, ODDS
# 
# <require switch: x> or <require switches: x,x>
# This will require the switch x to be on before the piece of equipment can be
# worn by the actor. If it isn't on, it'll be greyed out until available.
# 
# <require variable x: above y> or <require variable x: under y>
# This will require the variable x to be above/under y in order for the item
# to become equippable by the actor.
# 
# -----------------------------------------------------------------------------
# Weapon Tags - Insert the following tags into Weapon noteboxes.
# -----------------------------------------------------------------------------
# <2 hand text: phrase>
# This will replace the default two-handed text with whatever you've inserted
# for phrase. Case sensitive.
# 
# -----------------------------------------------------------------------------
# Armour Tags - Insert the following tags into Armour noteboxes.
# -----------------------------------------------------------------------------
# <equip type: phrase>
# This changes the equip type of the item to whatever the phrase is. This tag
# exists for using more than the 4 types of armour equips available to (0X)RPG.rb
# Maker. To understand how this works better, read the Equip Settings part of
# the module and adjust the settings there accordingly.
# 
# -----------------------------------------------------------------------------
# Script Calls
# -----------------------------------------------------------------------------
# item = $data_armors[item_id]
# $game_actors[x].change_equip(slot_id, item)
# This allows you to equip armours to the newly made slots. Make sure you find
# the appropriate item_id for the armour.
# 
# $game_actors[x].lock_equip(slot_id)
# This locks that actor's equipment slot from being changable. Does not give
# overrides to fixed equipment trait.
# 
# $game_actors[x].unlock_equip(slot_id)
# This unlocks that actor's equipment slot to being changable. Does not give
# overrides to fixed equipment trait.
# 
# array = [:other, :other, :other]
# $game_actors[x].equip_type = array
# This changes the actors equip types to set array. Any unequippable items will
# be purged and thrown back into the inventory. This does not include weapon
# and weapon will be automatically excluded to maintain compatibility.
# 
# $game_actors[x].add_equip_type(type)
# This adds an equip type onto the pre-existing equip types. It opens up an
# extra expanded slot at the very end of the list. This does not include
# weapon and weapon will be automatically excluded to maintain comptability.
# 
# $game_actors[x].delete_last_equip_type
# This removes the last type in the current equip types. The item in the
# previous types are dropped. This will not delete weapon types to maintain
# compatibility.
# 
# -----------------------------------------------------------------------------
# Debug Shortcuts - Only during $TEST and $BTEST mode
# -----------------------------------------------------------------------------
# During testplay mode, pressing F5 inside of the equip screen will allow you
# to force equip an item that isn't normally equippable. Pressing F7 and F8
# decreases and increases the number of an item. Inside aptitude, F5 will force
# use an aptitude item even if it's been consumed. F6 will reset aptitudes. F7
# and F8 will increase and decrease aptitude items.
#===============================================================================

$imported = {} if $imported == nil
$imported["EquipmentOverhaul"] = true

module YEM
  module EQUIP
    
    #===========================================================================
    # Section I. Basic Settings
    # --------------------------------------------------------------------------
    # The following below will adjust the basic settings and vocabulary that
    # will display throughout the script. Change them as you see fit.
    #===========================================================================
    
    # This adjusts the commands used within the equip scene. The command window
    # is the window that lets you switch between various equip scene (0)options.
    COMMANDS =[
      :manual,      # Manually equips weapons and armours.
      :optimize,    # Optimize equipping automatically.
#~       :aptitude,    # Enter aptitude attuning menu.
    ] # Do not remove this.
    
    # The following determines the vocabulary used for the remade equip scene.
    # Adjust it accordingly to set the way text is displayed.
    VOCAB ={
      :manual   => "Manual",
      :optimize => "Optimize",
      :aptitude => "Aptitude",
      :mastery  => "Weaponry",
      :twohand  => "2-Hand",
      :arrow    => "=>",
      :noequip  => "<No Equipment>",
      :unequip  => "Unequip",
      :amount   => ":%2d",
      :apt_rate => "%s Rate",
    } # Do not remove this.
    
    # Some of the more unusual stats do not have defined vocabulary to go
    # along with it. Adjust the following hash to give them names.
    STAT_VOCAB ={
      :hit  => "HIT", # Stat that modifies hit rate.
      :eva  => "EVA", # Stat that modifies evasion rate.
      :cri  => "CRI", # Stat that modifies critical rate.
      :odds => "AGR", # Stat that modifies aggro rate.
    } # Do not remove this.
    
    # These are the stats shown inside of the equip scene menu and they order
    # they'll appear in. If a stat applied by a script doesn't exist, it'll be
    # ignored and the next command will be shifted up by one.
    #   Legal Stats:
    #   :hp, :mp, :atk, :def, :spi, :res, :dex, :agi, :hit, :eva, :cri, :odds
    SHOWN_STATS = [:maxhp, :maxmp, :atk, :def, :spi, :res, :dex, :agi]
    
    # This is the icon used for unequipping items.
    UNEQUIP_ICON = 98
    
    # This adjusts the font size used for the equip type categories.
    CATEGORY_FONT_SIZE = 16
    
    # This adjusts the font size used for the stat types.
    STAT_FONT_SIZE = 16
    
    #===========================================================================
    # Section II. Equip Settings
    # --------------------------------------------------------------------------
    # The following allows you to adjust the rules and such governing equipping
    # and unequipping items. Here, you can add additional item slots, remove
    # them, and even change the rules for some. To label certain armours as
    # different equip types, use the <equip type: phrase> and replace it with
    # the named category item within the TYPE_RULES hash.
    #===========================================================================
    
    # This determines the order of equipment inside the equipment scene. Note
    # that this does not include weapons as they're automatically the first
    # piece of equipment by default.
    TYPE_LIST =[
      :shield,   # Shield slot for equippable shield type armours.
      :helmet,   # Helmet slot for equippable headgear type armours.
      :armour,   # Armour slot for equippable bodygear type armours.
      :cloak,    # Cloak slot for equippable mantle type armours.
#~       :other,    # 1st Accessory slot for misc armours.
#~       :other,    # 2nd Accessory slot for misc armours.
#~       :other,    # 3rd Accessory slot for misc armours.
    ] # Do not remove this
    
    # Adjust the following below to determine the ruleset adjusted for equip
    # equip type following the pre-made template. Here's what each does:
    #     Name - The name of the equip type. When using tag, refer to this.
    #     Kind - The kind number associated with the equip type.
    #   Empty? - Whether or not the equipment slot can be empty.
    # Optimize - When optimizing, include this equipment type or not.
    TYPE_RULES ={
    # Type     => [     Name, Kind, Empty?, Optimize],
      :weapon  => [ "Weapon",  nil,   true,     true],
      :shield  => [ "Shield",    0,   true,     true],
      :helmet  => [ "Helmet",    1,   true,     true],
      :armour  => [ "Armour",    2,   true,     true],
#~       :other   => [  "Other",    3,   true,    false],
      :cloak   => [  "Accessory",    3,   true,     true],
    } # Do not remove this.
    
    # This will determine the stat order at which items are optimized for each
    # equipment type. If type is unlisted, it will pull from the :unlisted
    # category which can also be defined here.
    OPTIMIZE_SETTINGS ={ # Do not delete :unlisted from the keys.
      :unlisted => [:def, :res, :maxhp, :spi, :maxmp, :agi, :atk],
      :weapon   => [:atk, :spi, :maxmp, :agi, :maxhp, :def, :res],
    } # Do not remove this.
    
    #===========================================================================
    # Section III. Base Stat Settings
    # --------------------------------------------------------------------------
    # For those who would love to redefine the way their game calculates their
    # base stats, edit the following (0)options below and use a formula you prefer.
    # Otherwise, leave this alone as they are the default settings. The settings
    # below are only the MaxHP, MaxMP, ADSA, and HECO stats available. This will
    # allow you to modify them without needing to alter the base scripts.
    #===========================================================================
    
    # The following hash contains the basic stat retrieval formula. Modify it
    # if you wish, but make sure they remain in quote format to work.
    BASE_STAT ={
      :maxhp => "actor.parameters[0, @level]",
      :maxmp => "actor.parameters[1, @level]",
      :atk   => "actor.parameters[2, @level]",
      :def   => "actor.parameters[3, @level]",
      :spi   => "actor.parameters[4, @level]",
      :agi   => "actor.parameters[5, @level]",
      :hit   => "95",
      :eva   => "5",
      :cri   => "4 + ((actor.critical_bonus) ? 4 : 0)",
      :odds  => "4 - self.class.position",
    } # Do not remove this.
    
    #===========================================================================
    # Section IV. Aptitude Settings
    # --------------------------------------------------------------------------
    # The following allows you to adjust how much benefit and gain each class
    # gains for each stat when equipping weapons and armours. For instance, a
    # warrior will only benefit from 80% of an SPI boost compared to a mage.
    #===========================================================================
    
    # Set this to true if you wish to use the aptitude system for your game.
    USE_APTITUDE_SYSTEM = false
    
    # This hash adjusts the starting aptitude rates for each class. These
    # rates determine how much of a stat bonus is applied to each individual
    # stat for each piece of equipment.
    APTITUDE ={ # Class 0 is the common class. Do not delete it.
    # ClassID => [MaxHP, MaxMP,   ATK,   DEF,   SPI,   RES,   DEX,   AGI]
            0 => [  100,   100,   100,   100,   100,   100,   100,   100],
#~             1 => [  110,   100,   110,   100,    90,    90,   100,   110],
#~             2 => [  120,    90,   120,   100,    80,   100,   110,   100],
#~             3 => [   90,   110,    80,   100,   110,   120,    90,   100],
#~             4 => [   80,   120,    80,   100,   120,   110,    90,   100],
#~             5 => [  105,    95,   105,   100,   105,   110,    90,    90],
#~             6 => [   95,   105,   105,   100,   110,   105,    90,    90],
#~             7 => [  120,    80,   120,    90,    90,    80,   120,   100],
#~             8 => [   90,   110,    90,    80,   110,    80,   120,   120],
    } # Do not remove this.
    
    # This determines the maximum and minimum aptitudes possible. Anything
    # more or anything less will be treated as the minimum or maximum.
    MINIMUM_APTITUDE = 10
    MAXIMUM_APTITUDE = 255
    
    # This will reveal all aptitude boost items for your game if your game
    # has any. Set this to false and it will only reveal aptitude boosts that
    # the player has.
    SHOW_APT_BOOSTS = true
    
  end # EQUIP  
end # YEM

#===============================================================================
# Editting anything past this point may potentially result in causing computer
# damage, incontinence, explosion of user's head, coma, death, and/or halitosis.
# Therefore, edit at your own risk.
#===============================================================================

module YEM
  module REGEXP
    module BASEITEM
      
      STAT_SET = /<(.*):[ ]*([\+\-]\d+)>/i
      STAT_PER = /<(.*):[ ]*([\+\-]\d+)([%％])>/i
      TRAITS   = /<(?:TRAITS|trait):[ ](.*)>/i
      REQ_SWITCH = /<(?:REQUIRE SWITCH||require switches):[ ]*(\d+(?:\s*,\s*\d+)*)>/i
      REQ_STRING = /<(?:REQUIRE|req)[ ](.*):[ ](\d+)[ ](.*)[ ](\d+)>/i
      REQUIRE    = /<(?:REQUIRE|req)[ ](.*):[ ](.*)[ ](\d+)>/i
      AUTOSTATES = /<(?:AUTO_STATE|auto state|auto states):[ ]*(\d+(?:\s*,\s*\d+)*)>/i
      APT_GROWTH = /<(.*)[ ](?:APTITUDE|apt):[ ]([\+\-]\d+)([%％])>/i
      
      TWO_HAND = /<(?:2_HAND_TEXT|2 hand text):[ ](.*)>/i
      EQUIP_TYPE = /<(?:EQUIP_TYPE|equip type):[ ](.*)>/i
      
    end # BASEITEM
    module STATE
      
      EQUIP_CANCEL = /<(?:EQUIP_CANCEL|equip cancel):[ ](.*)>/i
      
    end # STATE
  end # REGEXP
  module EQUIP
    
    # Compare Parameters Processing
    COMP_PARAM_PROC = {
      :maxhp => Proc.new { |a, b| b.maxhp - a.maxhp },
      :maxmp => Proc.new { |a, b| b.maxmp - a.maxmp },
      :atk => Proc.new { |a, b| b.atk - a.atk },
      :def => Proc.new { |a, b| b.def - a.def },
      :spi => Proc.new { |a, b| b.spi - a.spi },
      :res => Proc.new { |a, b| b.res - a.res },
      :dex => Proc.new { |a, b| b.dex - a.dex },
      :agi => Proc.new { |a, b| b.agi - a.agi }, }
    # Obtain Parameters Processing
    GET_PARAM_PROC = {
      :maxhp => Proc.new { |n| n.maxhp },
      :maxmp => Proc.new { |n| n.maxmp },
      :atk => Proc.new { |n| n.atk },
      :def => Proc.new { |n| n.def },
      :spi => Proc.new { |n| n.spi },
      :res => Proc.new { |n| n.res },
      :dex => Proc.new { |n| n.dex },
      :agi => Proc.new { |n| n.agi }, }
    
  end # EQUIP
end # YEM

#===============================================================================
# (0X)RPG.rb::BaseItem
#===============================================================================

class (0X)RPG.rb::BaseItem
  
  #--------------------------------------------------------------------------
  # public instance variables
  #--------------------------------------------------------------------------
  attr_accessor :maxhp
  attr_accessor :maxmp
  attr_accessor :atk
  attr_accessor :def
  attr_accessor :spi
  attr_accessor :agi
  attr_accessor :hit
  attr_accessor :eva
  attr_accessor :cri
  attr_accessor :odds
  attr_accessor :stat_per
  attr_accessor :traits
  attr_accessor :autostates
  attr_accessor :apt_growth
  attr_accessor :requirements
  attr_accessor :required_switches
  attr_accessor :req_variables_above
  attr_accessor :req_variables_under
  attr_accessor :req_weaponlvl_above
  attr_accessor :req_weaponlvl_under
  
  #--------------------------------------------------------------------------
  # common cache: yem_cache_baseitem_eo
  #--------------------------------------------------------------------------
  def yem_cache_baseitem_eo
    return if @cached_baseitem_eo; @cached_baseitem_eo = true
    @maxhp = 0; @maxmp = 0; @cri = 0; @odds = 0
    @hit = 0 if @hit == nil; @eva = 0 if @eva == nil
    @stat_per ={ :hp => 0, :mp => 0, :atk => 0, :def => 0, :spi => 0,
      :agi => 0, :hit => 0, :eva => 0, :cri => 0, :odds => 0}
    @autostates = []; @apt_growth = {}; @traits = []
    @requirements = {}; @required_switches = []
    @req_variables_above = {}; @req_variables_under = {}
    @req_weaponlvl_above = {}; @req_weaponlvl_under = {}
    
    self.note.split(/[\r\n]+/).each { |line|
      case line
      #---
      when YEM::REGEXP::BASEITEM::TRAITS
        case $1.upcase
        when "SUPER GUARD", "SUPER_GUARD", "SUPERGUARD"
          @traits.push(:super_guard)
        when "PHARMACOLOGY", "PHARMA", "ITEM BOOST", "ITEM_BOOST"
          @traits.push(:pharmacology)
        when "FAST ATTACK", "FAST_ATTACK", "FASTATTACK"
          @traits.push(:fast_attack)
        when "DUAL ATTACK", "DUALATTACK", "DUAL_ATTACK"
          @traits.push(:dual_attack)
        when "PREVENT_CRITICAL", "PREVENT CRITICAL", "PREVENT CRI"
          @traits.push(:prevent_critical)
        when "HALF MP COST", "HALF_MP_COST", "HALF MP", "HALF_MP", "HALFMP"
          @traits.push(:half_mp_cost)
        when "DOUBLE EXP GAIN", "DOUBLE_EXP_GAIN", "DOUBLE EXP", "DOUBLE_EXP"
          @traits.push(:double_exp_gain)
        when "AUTO_HP_RECOVER", "AUTO HP RECOVER", "AUTO HP", "AUTO_HP"
          @traits.push(:auto_hp_recover)
        when "ANTI HP REGEN", "ANTI_HP_REGEN"
          @traits.push(:anti_hp_regen)
        when "ANTI HP DEGEN", "ANTI_HP_DEGEN"
          @traits.push(:anti_hp_degen)
        when "ANTI MP REGEN", "ANTI_MP_REGEN"
          @traits.push(:anti_mp_regen)
        when "ANTI MP DEGEN", "ANTI_MP_DEGEN"
          @traits.push(:anti_mp_degen)
        else; next
        end
      #---
      when YEM::REGEXP::BASEITEM::APT_GROWTH
        case $1.upcase
        when "HP","MAXHP"; @apt_growth[:hp] = $2.to_i
        when "MP","MAXMP"; @apt_growth[:mp] = $2.to_i
        when "ATK"; @apt_growth[:atk] = $2.to_i
        when "DEF"; @apt_growth[:def] = $2.to_i
        when "SPI"; @apt_growth[:spi] = $2.to_i
        when "RES"; @apt_growth[:res] = $2.to_i
        when "DEX"; @apt_growth[:dex] = $2.to_i
        when "AGI"; @apt_growth[:agi] = $2.to_i
        end
      #---
      when YEM::REGEXP::BASEITEM::AUTOSTATES
        $1.scan(/\d+/).each { |num| 
        @autostates.push(num.to_i) if num.to_i > 0 }
      #---
      when YEM::REGEXP::BASEITEM::REQ_SWITCH
        $1.scan(/\d+/).each { |num| 
        @required_switches.push(num.to_i) if num.to_i > 0 }
        @requirements["SWITCH"] = true
      #---
      when YEM::REGEXP::BASEITEM::REQ_STRING
        case $1.upcase
        when "VARIABLE", "VAR"
          text = "VARIABLE"
          case $3.upcase
          when "ABOVE", "AT LEAST" "OVER", "GREATER THAN"
            text += " ABOVE"
            @req_variables_above[$2.to_i] = $4.to_i
          when "UNDER", "BELOW", "AT MOST", "LESS THAN"
            text += " UNDER"
            @req_variables_under[$2.to_i] = $4.to_i
          else; next
          end
        when "WEAPON LEVEL", "MASTERY", "WEAPON LVL", "WLVL"
          text = "WEAPON LEVEL"
          case $3.upcase
          when "ABOVE", "AT LEAST" "OVER", "GREATER THAN"
            text += " ABOVE"
            @req_weaponlvl_above[$2.to_i] = $4.to_i
          when "UNDER", "BELOW", "AT MOST", "LESS THAN"
            text += " UNDER"
            @req_weaponlvl_under[$2.to_i] = $4.to_i
          else; next
          end
        else; next
        end
        @requirements[text] = true
      #---
      when YEM::REGEXP::BASEITEM::REQUIRE
        case $2.upcase
        when "ABOVE", "AT LEAST" "OVER", "GREATER THAN"
          text = "ABOVE"
        when "UNDER", "BELOW", "AT MOST", "LESS THAN"
          text = "UNDER"
        else; next
        end
        text += " "
        case $1.upcase
        when "LEVEL", "LV", "LVL"
          text += "LEVEL"
        when "HP", "MAXHP"
          text += "MAXHP"
        when "MP", "MAXMP", "SP", "MAXSP"
          text += "MAXMP"
        when "INT", "MAG"
          text += "INT"
        when "AGG", "AGGRO"
          text += "ODDS"
        when "ATK", "DEF", "SPI", "INT", "RES", "DEX", "AGI"
          next if $1.upcase == "DEX" and !$imported["DEX Stat"]
          next if $1.upcase == "RES" and !$imported["RES Stat"]
          text += $1.upcase
        when "HIT", "EVA", "CRI", "ODDS"
          text += $1.upcase
        else; next
        end
        @requirements[text] = $3.to_i
      #---
      when YEM::REGEXP::BASEITEM::STAT_SET
        case $1.upcase
        when "HP","MAXHP"; @maxhp = $2.to_i
        when "MP","MAXMP"; @maxmp = $2.to_i
        when "ATK"; @atk = $2.to_i
        when "DEF"; @def = $2.to_i
        when "SPI"; @spi = $2.to_i
        when "AGI"; @agi = $2.to_i
        when "HIT"; @hit = $2.to_i
        when "EVA"; @eva = $2.to_i
        when "CRI"; @cri = $2.to_i
        when "ODDS"; @odds = $2.to_i
        end
      #---
      when YEM::REGEXP::BASEITEM::STAT_PER
        case $1.upcase
        when "HP","MAXHP"; @stat_per[:hp] = $2.to_i
        when "MP","MAXMP"; @stat_per[:mp] = $2.to_i
        when "ATK"; @stat_per[:atk] = $2.to_i
        when "DEF"; @stat_per[:def] = $2.to_i
        when "SPI"; @stat_per[:spi] = $2.to_i
        when "AGI"; @stat_per[:agi] = $2.to_i
        when "HIT"; @stat_per[:hit] = $2.to_i
        when "EVA"; @stat_per[:eva] = $2.to_i
        when "CRI"; @stat_per[:cri] = $2.to_i
        when "ODDS"; @stat_per[:odds] = $2.to_i
        end
      #---
      end
    } # end self.note.split
    @requirements["NONE"] = 0 if @requirements == {}
  end # yem_cache_baseitem_eo
  
  #--------------------------------------------------------------------------
  # anti-crash methods
  #--------------------------------------------------------------------------
  unless $imported["DEX Stat"]; def dex; return 0; end; end
  unless $imported["RES Stat"]; def res; return 0; end; end
  
end # (0X)RPG.rb::BaseItem

#===============================================================================
# (0X)RPG.rb::Weapon
#===============================================================================

class (0X)RPG.rb::Weapon < (0X)RPG.rb::BaseItem
  
  #--------------------------------------------------------------------------
  # public instance variable
  #--------------------------------------------------------------------------
  attr_accessor :two_hand_text
  
  #--------------------------------------------------------------------------
  # common cache: yem_cache_weapon_eo
  #--------------------------------------------------------------------------
  def yem_cache_weapon_eo
    return if @cached_weapon_eo; @cached_weapon_eo = true
    @two_hand_text = YEM::EQUIP::VOCAB[:twohand]
    
    self.note.split(/[\r\n]+/).each { |line|
      case line
      when YEM::REGEXP::BASEITEM::TWO_HAND
        @two_hand_text = $1.to_s
      end
    } # end self.note.split
  end # yem_cache_weapon_eo
  
end # (0X)RPG.rb::Weapon

#===============================================================================
# (0X)RPG.rb::Armor
#===============================================================================

class (0X)RPG.rb::Armor < (0X)RPG.rb::BaseItem
  
  #--------------------------------------------------------------------------
  # public instance variables
  #--------------------------------------------------------------------------
  attr_accessor :kind
  attr_accessor :equip_type
  
  #--------------------------------------------------------------------------
  # common cache: yem_cache_armour_eo
  #--------------------------------------------------------------------------
  def yem_cache_armour_eo
    @equip_type = @kind
    for key in YEM::EQUIP::TYPE_RULES
      next if key[1][1] != @kind
      @equip_type = key[1][0].upcase
    end
    
    self.note.split(/[\r\n]+/).each { |line|
      case line
      when YEM::REGEXP::BASEITEM::EQUIP_TYPE
        for key in YEM::EQUIP::TYPE_RULES
          next if key[1][0].upcase != $1.upcase
          @kind = key[1][1]; break
          @equip_type = $1.upcase
        end
      end
    } # end self.note.split
  end # yem_cache_armour_eo
  
end # (0X)RPG.rb::Armor
  
#===============================================================================
# (0X)RPG.rb::State
#===============================================================================

class (0X)RPG.rb::State
  
  #--------------------------------------------------------------------------
  # common cache: yem_cache_state_eo
  #--------------------------------------------------------------------------
  def yem_cache_state_eo
    @equip_cancel = []
    
    self.note.split(/[\r\n]+/).each { |line|
      case line
      when YEM::REGEXP::STATE::EQUIP_CANCEL
        text = $1.to_s
        @equip_cancel.push(text.upcase)
      end
    } # # end self.note.split
  end # yem_cache_state_eo
  
  #--------------------------------------------------------------------------
  # new method: equip_cancel
  #--------------------------------------------------------------------------
  def equip_cancel
    yem_cache_state_eo if @equip_cancel == nil
    return @equip_cancel
  end
  
end # (0X)RPG.rb::State

#===============================================================================
# Vocab
#===============================================================================

module Vocab
  
  #--------------------------------------------------------------------------
  # self.hit
  #--------------------------------------------------------------------------
  def self.hit; return YEM::EQUIP::STAT_VOCAB[:hit]; end
  
  #--------------------------------------------------------------------------
  # self.eva
  #--------------------------------------------------------------------------
  def self.eva; return YEM::EQUIP::STAT_VOCAB[:eva]; end
  
  #--------------------------------------------------------------------------
  # self.cri
  #--------------------------------------------------------------------------
  def self.cri; return YEM::EQUIP::STAT_VOCAB[:cri]; end
    
  #--------------------------------------------------------------------------
  # self.odds
  #--------------------------------------------------------------------------
  def self.odds; return YEM::EQUIP::STAT_VOCAB[:odds]; end
  
end # Vocab

#===============================================================================
# module Icon
#===============================================================================
if !$imported["BattleEngineMelody"] and !$imported["IconModuleLibrary"]
module Icon
  
  #--------------------------------------------------------------------------
  # self.stat
  #--------------------------------------------------------------------------
  def self.stat(actor, item); return 0; end
  
end # Icon
end # !$imported["BattleEngineMelody"] and !$imported["IconModuleLibrary"]

#===============================================================================
# Scene_Title
#===============================================================================

class Scene_Title < Scene_Base
  
  #--------------------------------------------------------------------------
  # alias method: load_bt_database
  #--------------------------------------------------------------------------
  alias load_bt_database_eo load_bt_database unless $@
  def load_bt_database
    load_bt_database_eo
    load_eo_cache
  end
  
  #--------------------------------------------------------------------------
  # alias method: load_database
  #--------------------------------------------------------------------------
  alias load_database_eo load_database unless $@
  def load_database
    load_database_eo
    load_eo_cache
  end
  
  #--------------------------------------------------------------------------
  # new method: load_eo_cache
  #--------------------------------------------------------------------------
  def load_eo_cache
    groups = [$data_items, $data_weapons, $data_armors]
    for group in groups
      for obj in group
        next if obj == nil
        obj.yem_cache_baseitem_eo if obj.is_a?((0X)RPG.rb::BaseItem)
        obj.yem_cache_weapon_eo if obj.is_a?((0X)RPG.rb::Weapon)
        obj.yem_cache_armour_eo if obj.is_a?((0X)RPG.rb::Armor)
      end
    end
  end
  
end # Scene_Title

#===============================================================================
# Game_Temp
#===============================================================================

class Game_Temp
  
  #--------------------------------------------------------------------------
  # public instance variables
  #--------------------------------------------------------------------------
  attr_accessor :equip_last
  
  #--------------------------------------------------------------------------
  # new method: aptitude_items
  #--------------------------------------------------------------------------
  def aptitude_items
    return @aptitude_items if @aptitude_items != nil
    @aptitude_items = []
    for item in $data_items
      next if item == nil
      next if item.apt_growth == {}
      @aptitude_items.push(item)
    end
    return @aptitude_items
  end
  
end # Game_Temp
  
#===============================================================================
# Game_Battler
#===============================================================================

class Game_Battler
  
  #--------------------------------------------------------------------------
  # alias method: states
  #--------------------------------------------------------------------------
  alias states_eo states unless $@
  def states
    list = states_eo
    list += equip_autostates if actor?
    list.uniq.sort! { |state_a,state_b|
      if state_a.priority != state_b.priority
        state_b.priority <=> state_a.priority
      else
        state_a.id <=> state_b.id
      end }
    return list.uniq
  end
  
  #--------------------------------------------------------------------------
  # alias method: item_test
  #--------------------------------------------------------------------------
  alias item_test_eo item_test unless $@
  def item_test(user, item)
    return true if item.apt_growth != {}
    return item_test_eo(user, item)
  end
  
  #--------------------------------------------------------------------------
  # alias method: item_growth_effect
  #--------------------------------------------------------------------------
  alias item_growth_effect_eo item_growth_effect unless $@
  def item_growth_effect(user, item)
    if item.apt_growth != {} and actor?
      create_aptitude_bonus
      for key in item.apt_growth
        type = key[0]; value = key[1]
        case type
        when :hp, :mp, :atk, :def, :spi, :res, :dex, :agi
          @bonus_apt[type] += value
        else; next
        end
      end
      purge_unequippable
    end
    item_growth_effect_eo(user, item)
  end
  
  #--------------------------------------------------------------------------
  # new method: traits
  #--------------------------------------------------------------------------
  unless # $imported["BattleEngineMelody"]
  def traits
    return @cache_traits if @cache_traits != nil
    @cache_traits = []
    for state in states; @cache_traits |= state.traits; end
    if actor?
      for equip in equips.compact; @cache_traits |= equip.traits; end
    end
    return @cache_traits
  end
  end # $imported["BattleEngineMelody"]
  
end # Game_Battler

#===============================================================================
# Game_Actor
#===============================================================================

class Game_Actor < Game_Battler
  
  #--------------------------------------------------------------------------
  # alias method: setup
  #--------------------------------------------------------------------------
  alias setup_eo setup unless $@
  def setup(actor_id)
    setup_eo(actor_id)
    @extra_armor_id = []
    @locked_equips = []
    @equip_type = nil
    @bonus_apt = nil
    create_aptitude_bonus
    purge_unequippable
  end

  #--------------------------------------------------------------------------
  # overwrite method: base_maxhp
  #--------------------------------------------------------------------------
  def base_maxhp
    n = eval(YEM::EQUIP::BASE_STAT[:maxhp])
    percent = 100
    for item in equips.compact
      percent += aptitude(item.stat_per[:hp], :hp)
    end
    n *= percent / 100.0
    for item in equips.compact
      n += aptitude(item.maxhp, :hp)
    end
    return Integer(n)
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: base_maxmp
  #--------------------------------------------------------------------------
  def base_maxmp
    n = eval(YEM::EQUIP::BASE_STAT[:maxmp])
    percent = 100
    for item in equips.compact
      percent += aptitude(item.stat_per[:mp], :mp)
    end
    n *= percent / 100.0
    for item in equips.compact
      n += aptitude(item.maxmp, :mp)
    end
    return Integer(n)
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: base_atk
  #--------------------------------------------------------------------------
  def base_atk
    n = eval(YEM::EQUIP::BASE_STAT[:atk])
    percent = 100
    for item in equips.compact
      percent += aptitude(item.stat_per[:atk], :atk)
    end
    n *= percent / 100.0
    for item in equips.compact
      n += aptitude(item.atk, :atk)
    end
    return Integer(n)
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: base_def
  #--------------------------------------------------------------------------
  def base_def
    n = eval(YEM::EQUIP::BASE_STAT[:def])
    percent = 100
    for item in equips.compact
      percent += aptitude(item.stat_per[:def], :def)
    end
    n *= percent / 100.0
    for item in equips.compact
      n += aptitude(item.def, :def)
    end
    return Integer(n)
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: base_spi
  #--------------------------------------------------------------------------
  def base_spi
    n = eval(YEM::EQUIP::BASE_STAT[:spi])
    percent = 100
    for item in equips.compact
      percent += aptitude(item.stat_per[:spi], :spi)
    end
    n *= percent / 100.0
    for item in equips.compact
      n += aptitude(item.spi, :spi)
    end
    return Integer(n)
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: base_agi
  #--------------------------------------------------------------------------
  def base_agi
    n = eval(YEM::EQUIP::BASE_STAT[:agi])
    percent = 100
    for item in equips.compact
      percent += aptitude(item.stat_per[:agi], :agi)
    end
    n *= percent / 100.0
    for item in equips.compact
      n += aptitude(item.agi, :agi)
    end
    return Integer(n)
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: hit
  #--------------------------------------------------------------------------
  def hit
    n = eval(YEM::EQUIP::BASE_STAT[:hit])
    if two_swords_style
      n1 = weapons[0] == nil ? n : weapons[0].hit
      n2 = weapons[1] == nil ? n : weapons[1].hit
      n = [n1, n2].min
    else
      n = weapons[0] == nil ? n : weapons[0].hit
    end
    percent = 100
    for item in equips.compact
      percent += item.stat_per[:hit]
    end
    n *= percent / 100.0
    for item in armors.compact
      n += item.hit
    end
    return Integer(n)
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: eva
  #--------------------------------------------------------------------------
  def eva
    n = eval(YEM::EQUIP::BASE_STAT[:eva])
    for item in equips.compact
      n += item.eva
    end
    percent = 100
    for item in equips.compact
      percent += item.stat_per[:eva]
    end
    n *= percent / 100.0
    return Integer(n)
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: cri
  #--------------------------------------------------------------------------
  def cri
    n = eval(YEM::EQUIP::BASE_STAT[:cri])
    for weapon in weapons.compact
      n += 4 if weapon.critical_bonus
    end
    percent = 100
    for item in equips.compact
      percent += item.stat_per[:cri]
    end
    n *= percent / 100.0
    for item in equips.compact
      n += item.cri
    end
    return Integer(n)
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: odds
  #--------------------------------------------------------------------------
  def odds
    n = $imported["AggroAI"] ? base_aggro : eval(YEM::EQUIP::BASE_STAT[:odds])
    for item in equips.compact
      n += item.odds
    end
    percent = 100
    for item in equips.compact
      percent += item.stat_per[:odds]
    end
    n *= percent / 100.0
    return [Integer(n), 1].max
  end
  
  #--------------------------------------------------------------------------
  # new method: aptitude
  #--------------------------------------------------------------------------
  def aptitude(n, type)
    return n unless YEM::EQUIP::USE_APTITUDE_SYSTEM
    multiplier = aptitude_rate(type)
    n = n * multiplier / 100
    return n
  end
  
  #--------------------------------------------------------------------------
  # new method: aptitude_rate
  #--------------------------------------------------------------------------
  def aptitude_rate(type)
    if YEM::EQUIP::APTITUDE.include?(@class_id)
      array = YEM::EQUIP::APTITUDE[@class_id]
    else
      array = YEM::EQUIP::APTITUDE[0]
    end
    type = :hp if type == :maxhp
    type = :mp if type == :maxmp
    create_aptitude_bonus
    multiplier = 0
    case type
    when :hp;  multiplier = array[0]
    when :mp;  multiplier = array[1]
    when :atk; multiplier = array[2]
    when :def; multiplier = array[3]
    when :spi; multiplier = array[4]
    when :res; multiplier = array[5]
    when :dex; multiplier = array[6]
    when :agi; multiplier = array[7]
    end
    multiplier += @bonus_apt[type]
    multiplier = [multiplier, YEM::EQUIP::MINIMUM_APTITUDE].max
    multiplier = [multiplier, YEM::EQUIP::MAXIMUM_APTITUDE].min
    return multiplier
  end
  
  #--------------------------------------------------------------------------
  # new method: reset_aptitudes
  #--------------------------------------------------------------------------
  def reset_aptitudes
    @bonus_apt = nil
    create_aptitude_bonus
  end
  
  #--------------------------------------------------------------------------
  # new method: create_aptitude_bonus
  #--------------------------------------------------------------------------
  def create_aptitude_bonus
    @bonus_apt = {} if @bonus_apt == nil
    @bonus_apt[:hp]  = 0 if @bonus_apt[:hp] == nil
    @bonus_apt[:mp]  = 0 if @bonus_apt[:mp] == nil
    @bonus_apt[:atk] = 0 if @bonus_apt[:atk] == nil
    @bonus_apt[:def] = 0 if @bonus_apt[:def] == nil
    @bonus_apt[:spi] = 0 if @bonus_apt[:spi] == nil
    @bonus_apt[:res] = 0 if @bonus_apt[:res] == nil
    @bonus_apt[:dex] = 0 if @bonus_apt[:dex] == nil
    @bonus_apt[:agi] = 0 if @bonus_apt[:agi] == nil
  end
  
  #--------------------------------------------------------------------------
  # new method: equip_type
  #--------------------------------------------------------------------------
  def equip_type
    if @equip_type.is_a?(Array)
      return @equip_type
    else
      return YEM::EQUIP::TYPE_LIST
    end
  end
  
  #--------------------------------------------------------------------------
  # new method: equip_type=
  #--------------------------------------------------------------------------
  def equip_type=(array)
    if array == nil
      @equip_type = nil
      purge_unequippable
      return
    end
    return unless array.is_a?(Array)
    array.delete(:weapon)
    @equip_type = YEM::EQUIP::TYPE_LIST if @equip_type == nil
    if @equip_type.size > array.size
      for i in array.size..@equip_type.size; change_equip(i, nil); end
    end
    @equip_type = array
    purge_unequippable
  end
  
  #--------------------------------------------------------------------------
  # new method: add_equip_type
  #--------------------------------------------------------------------------
  def add_equip_type(type)
    return unless YEM::EQUIP::TYPE_RULES.include?(type)
    return if type == :weapon
    @equip_type = YEM::EQUIP::TYPE_LIST if @equip_type == nil
    @equip_type.push(type)
    purge_unequippable
  end
  
  #--------------------------------------------------------------------------
  # new method: delete_last_equip_type
  #--------------------------------------------------------------------------
  def delete_last_equip_type
    @equip_type = YEM::EQUIP::TYPE_LIST if @equip_type == nil
    return if @equip_type.size <= 0
    change_equip(@equip_type.size, nil)
    @equip_type.pop
  end
  
  #--------------------------------------------------------------------------
  # new method: armor_number
  #--------------------------------------------------------------------------
  def armor_number
    return equip_type.size
  end
  
  #--------------------------------------------------------------------------
  # new method: extra_armor_number
  #--------------------------------------------------------------------------
  def extra_armor_number
    return [armor_number - 4, 0].max
  end
  
  #--------------------------------------------------------------------------
  # new method: extra_armor_id
  #--------------------------------------------------------------------------
  def extra_armor_id
    @extra_armor_id = [] if @extra_armor_id == nil
    return @extra_armor_id
  end
  
  #--------------------------------------------------------------------------
  # alias method: armors
  #--------------------------------------------------------------------------
  alias armors_eo armors unless $@
  def armors
    result = armors_eo
    extra_armor_number.times { |i|
      armor_id = extra_armor_id[i]
      result.push(armor_id == nil ? nil : $data_armors[armor_id]) }
    return result
  end
  
  #--------------------------------------------------------------------------
  # alias method: change_equip
  #--------------------------------------------------------------------------
  alias change_equip_eo change_equip unless $@
  def change_equip(equip_type, item, test = false)
    change_equip_eo(equip_type, item, test)
    if extra_armor_number > 0
      item_id = item == nil ? 0 : item.id
      case equip_type
      when 5..armor_number
        @extra_armor_id = [] if @extra_armor_id == nil
        @extra_armor_id[equip_type - 5] = item_id
      end
    end
    purge_unequippable(test) unless @purge_on
  end
  
  #--------------------------------------------------------------------------
  # alias method: equippable?
  #--------------------------------------------------------------------------
  alias equippable_eo equippable? unless $@
  def equippable?(item)
    return false unless equippable_eo(item)
    for key in item.requirements
      requirement = key[0]; value = key[1]
      case requirement
      when "NONE"; break
      #---
      when "ABOVE LEVEL"; return false unless self.level >= value
      when "ABOVE MAXHP"; return false unless self.maxhp >= value
      when "ABOVE MAXMP"; return false unless self.maxmp >= value
      when "ABOVE ATK";   return false unless self.atk >= value
      when "ABOVE DEF";   return false unless self.def >= value
      when "ABOVE SPI";   return false unless self.spi >= value
      when "ABOVE RES";   return false unless self.res >= value
      when "ABOVE DEX";   return false unless self.dex >= value
      when "ABOVE AGI";   return false unless self.agi >= value
      when "ABOVE HIT";   return false unless self.hit >= value
      when "ABOVE EVA";   return false unless self.eva >= value
      when "ABOVE DUR";   return false unless self.max_dur >= value
      when "ABOVE LUK";   return false unless self.luk >= value
      when "ABOVE CRI";   return false unless self.cri >= value
      when "ABOVE ODDS";  return false unless self.odds >= value
      #---
      when "UNDER LEVEL"; return false unless self.level <= value
      when "UNDER MAXHP"; return false unless self.maxhp <= value
      when "UNDER MAXMP"; return false unless self.maxmp <= value
      when "UNDER ATK";   return false unless self.atk <= value
      when "UNDER DEF";   return false unless self.def <= value
      when "UNDER SPI";   return false unless self.spi <= value
      when "UNDER RES";   return false unless self.res <= value
      when "UNDER DEX";   return false unless self.dex <= value
      when "UNDER AGI";   return false unless self.agi <= value
      when "UNDER HIT";   return false unless self.hit <= value
      when "UNDER EVA";   return false unless self.eva <= value
      when "UNDER DUR";   return false unless self.max_dur <= value
      when "UNDER LUK";   return false unless self.luk <= value
      when "UNDER CRI";   return false unless self.cri <= value
      when "UNDER ODDS";  return false unless self.odds <= value
      #---
      when "SWITCH"
        for switch_id in item.required_switches
          return false unless $game_switches[switch_id]
        end
      #---
      when "VARIABLE ABOVE"
        for key in item.req_variables_above
          variable = key[0]; variable_value = key[1]
          return false unless $game_variables[variable] >= variable_value
        end
      when "VARIABLE UNDER"
        for key in item.req_variables_under
          variable = key[0]; variable_value = key[1]
          return false unless $game_variables[variable] <= variable_value
        end
      #---
      end
    end
    return true
  end
  
  #--------------------------------------------------------------------------
  # new method: purge_unequippable
  #--------------------------------------------------------------------------
  def purge_unequippable(test = false)
    return if $game_temp.in_battle
    @purge_on = true
    for i in 0..4
      change_equip(i, nil, test) unless equippable?(equips[i])
      if equips[i].is_a?((0X)RPG.rb::Armor)
        type = equip_type[i-1]
        if equips[i].kind != YEM::EQUIP::TYPE_RULES[type][1]
          change_equip(i, nil, test)
        end
      end
    end
    if extra_armor_number != 0
      for i in 5..armor_number
        change_equip(i, nil, test) unless equippable?(equips[i])
        if equips[i].is_a?((0X)RPG.rb::Armor)
          type = equip_type[i-1]
          if equips[i].kind != YEM::EQUIP::TYPE_RULES[type][1]
            change_equip(i, nil, test)
          end
        end
      end
    end
    @purge_on = false
  end
  
  #--------------------------------------------------------------------------
  # alias method: discard_equip
  #--------------------------------------------------------------------------
  alias discard_equip_eo discard_equip unless $@
  def discard_equip(item)
    last_armours = [@armor1_id, @armor2_id, @armor3_id, @armor4_id]
    discard_equip_eo(item)
    current_armours = [@armor1_id, @armor2_id, @armor3_id, @armor4_id]
    return unless item.is_a?((0X)RPG.rb::Armor)
    return if last_armours != current_armours
    extra_armor_number.times { |i|
      if extra_armor_id[i] == item.id
        @extra_armor_id[i] = 0
        break
      end }
  end
  
  #--------------------------------------------------------------------------
  # alias method: class_id=
  #--------------------------------------------------------------------------
  alias class_id_eo class_id= unless $@
  def class_id=(class_id)
    class_id_eo(class_id)
    return if extra_armor_number == 0
    for i in 5..armor_number
      change_equip(i, nil) unless equippable?(equips[i])
    end
  end
  
  #--------------------------------------------------------------------------
  # new method: restore_equip
  #--------------------------------------------------------------------------
  def restore_equip
    return if @last_equip_type == equip_type
    last_equips = equips
    last_hp = self.hp
    last_mp = self.mp
    last_equips.each_index { |i| change_equip(i, nil) }
    last_equips.compact.each { |item| equip_legal_slot(item) }
    self.hp = last_hp
    self.mp = last_mp
    @last_equip_type = equip_type.clone
    Graphics.frame_reset
  end
  
  #--------------------------------------------------------------------------
  # new method: equip_legal_slot
  #--------------------------------------------------------------------------
  def equip_legal_slot(item)
    if item.is_a?((0X)RPG.rb::Weapon)
      if @weapon_id == 0
        change_equip(0, item)
      elsif two_swords_style and @armor1_id == 0
        change_equip(1, item)
      end
    elsif item.is_a?((0X)RPG.rb::Armor)
      type = YEM::EQUIP::TYPE_RULES[equip_type[0]][1]
      if !two_swords_style and item.kind == type and @armor1_id == 0
        change_equip(1, item)
      else
        list = [-1, @armor2_id, @armor3_id, @armor4_id]
        list += extra_armor_id
        equip_type.each_with_index { |kind, i|
          if kind == item.kind and list[i] == 0
            change_equip(i + 1, item)
            break
          end }
      end
    end
  end
  
  #--------------------------------------------------------------------------
  # alias method: super_guard
  #--------------------------------------------------------------------------
  alias super_guard_eo super_guard unless $@
  def super_guard
    return true if traits.include?(:super_guard)
    return super_guard_eo
  end
  
  #--------------------------------------------------------------------------
  # alias method: pharmacology
  #--------------------------------------------------------------------------
  alias pharmacology_eo pharmacology unless $@
  def pharmacology
    return true if traits.include?(:pharmacology)
    return pharmacology_eo
  end
  
  #--------------------------------------------------------------------------
  # alias method: fast_attack
  #--------------------------------------------------------------------------
  alias fast_attack_eo fast_attack unless $@
  def fast_attack
    return true if traits.include?(:fast_attack)
    return fast_attack_eo
  end
  
  #--------------------------------------------------------------------------
  # alias method: dual_attack
  #--------------------------------------------------------------------------
  alias dual_attack_eo dual_attack unless $@
  def dual_attack
    return true if traits.include?(:dual_attack)
    return dual_attack_eo
  end
  
  #--------------------------------------------------------------------------
  # alias method: prevent_critical
  #--------------------------------------------------------------------------
  alias prevent_critical_eo prevent_critical unless $@
  def prevent_critical
    return true if traits.include?(:prevent_critical)
    return prevent_critical_eo
  end
  
  #--------------------------------------------------------------------------
  # alias method: half_mp_cost
  #--------------------------------------------------------------------------
  alias half_mp_cost_eo half_mp_cost unless $@
  def half_mp_cost
    return true if traits.include?(:half_mp_cost)
    return half_mp_cost_eo
  end
  
  #--------------------------------------------------------------------------
  # alias method: double_exp_gain
  #--------------------------------------------------------------------------
  alias double_exp_gain_eo double_exp_gain unless $@
  def double_exp_gain
    return true if traits.include?(:double_exp_gain)
    return double_exp_gain_eo
  end
  
  #--------------------------------------------------------------------------
  # alias method: auto_hp_recover
  #--------------------------------------------------------------------------
  alias auto_hp_recover_eo auto_hp_recover unless $@
  def auto_hp_recover
    return true if traits.include?(:auto_hp_recover)
    return auto_hp_recover_eo
  end
  
  #--------------------------------------------------------------------------
  # new method: equip_autostates
  #--------------------------------------------------------------------------
  def equip_autostates
    result = []
    for equip in equips.compact
      for state_id in equip.autostates
        state = $data_states[state_id]
        next if state == nil
        result.push(state)
      end
    end
    return result
  end
  
  #--------------------------------------------------------------------------
  # new method: locked_equips
  #--------------------------------------------------------------------------
  def locked_equips
    @locked_equips = [] if @locked_equips == nil
    return @locked_equips
  end
  
  #--------------------------------------------------------------------------
  # new method: lock_equip
  #--------------------------------------------------------------------------
  def lock_equip(slot)
    @locked_equips = [] if @locked_equips == nil
    @locked_equips += [slot]
  end
  
  #--------------------------------------------------------------------------
  # new method: unlock_equip
  #--------------------------------------------------------------------------
  def unlock_equip(slot)
    @locked_equips = [] if @locked_equips == nil
    @locked_equips -= [slot]
  end
  
end # Game_Actor

#===============================================================================
# Game_Party
#===============================================================================

class Game_Party < Game_Unit
  
  #--------------------------------------------------------------------------
  # new method: items_only
  #--------------------------------------------------------------------------
  def items_only
    result = []
    for i in @items.keys.sort
      result.push($data_items[i]) if @items[i] > 0 #and overall_checker($data_items[i],1)
    end
    return result
  end
  
  #--------------------------------------------------------------------------
  # new method: equip_weapons
  #--------------------------------------------------------------------------
  def equip_weapons
    result = []
    for i in @weapons.keys.sort
      result.push($data_weapons[i]) if @weapons[i] > 0 #and overall_checker($data_weapons[i],1)
    end
    return result
  end
  
  #--------------------------------------------------------------------------
  # new method: equip_armours
  #--------------------------------------------------------------------------
  def equip_armours(type = nil)
    result = []
    for i in @armors.keys.sort
      armour = $data_armors[i]
      result.push(armour) if @armors[i] > 0# and overall_checker($data_armors[i],1)
    end
    return result
  end
  
end # Game_Party

#===============================================================================
# Window_Command_Centered
#===============================================================================

class Window_Command_Centered < Window_Command
  
  #--------------------------------------------------------------------------
  # draw_item
  #--------------------------------------------------------------------------
  def draw_item(index, enabled = true)
    rect = item_rect(index)
    rect.x += 4
    rect.width -= 8
    self.contents.clear_rect(rect)
    self.contents.font.color = normal_color
    self.contents.font.color.alpha = enabled ? 255 : 128
    self.contents.draw_text(rect, @commands[index], 1)
  end
  
end # Window_Command_Centered

#===============================================================================
# Window_ShopStatus
#===============================================================================

class Window_ShopStatus < Window_Base
  
  #--------------------------------------------------------------------------
  # draw_actor_parameter_change
  #--------------------------------------------------------------------------
  def draw_actor_parameter_change(actor, x, y)
    return if @item.is_a?((0X)RPG.rb::Item)
    enabled = actor.equippable?(@item)
    self.contents.font.color = normal_color
    self.contents.font.color.alpha = enabled ? 255 : 128
    self.contents.draw_text(x, y, 200, WLH, actor.name)
    if @item.is_a?((0X)RPG.rb::Weapon)
      item1 = weaker_weapon(actor)
    elsif actor.two_swords_style and @item.kind == 0
      item1 = nil
    else
      item1 = actor.equips[1 + @item.kind]
    end
    if enabled
      if @item.is_a?((0X)RPG.rb::Weapon)
        atk1 = item1 == nil ? 0 : actor.aptitude(item1.atk, :atk)
        atk2 = @item == nil ? 0 : actor.aptitude(@item.atk, :atk)
        change = atk2 - atk1
      else
        def1 = item1 == nil ? 0 : actor.aptitude(item1.def, :def)
        def2 = @item == nil ? 0 : actor.aptitude(@item.def, :def)
        change = def2 - def1
      end
      self.contents.draw_text(x, y, 200, WLH, sprintf("%+d", change), 2)
    end
    draw_item_name(item1, x, y + WLH, enabled)
  end
  
end # Window_ShopStatus

#===============================================================================
# Window_Equip_Actor
#===============================================================================

class Window_Equip_Actor < Window_Base
  
  #--------------------------------------------------------------------------
  # initialize
  #--------------------------------------------------------------------------
  def initialize(actor)
    super(160, 0, Graphics.width - 160, 128)
    @actor = actor
    refresh(0)
  end
  
  #--------------------------------------------------------------------------
  # actor=
  #--------------------------------------------------------------------------
  def actor=(new_actor)
    @actor = new_actor
    refresh($scene.equip_window.index)
  end
  
  #--------------------------------------------------------------------------
  # refresh
  #--------------------------------------------------------------------------
  def refresh(type = nil)
    self.contents.clear
    @type = type
    draw_actor_face(@actor, 0, 0, size = 96)
    x = 104
    y = 0
    self.contents.font.color = normal_color
    draw_actor_name(@actor, x, y)
    draw_actor_class(@actor, x + 120, y)
    draw_actor_level(@actor, x, y + WLH)
    draw_actor_autostate(@actor, x + 120, y + WLH)
    return if @type == nil
    self.contents.font.color = system_color
    if @type == 0 and @actor.weapons[0] != nil and @actor.weapons[0].two_handed
      text = @actor.weapons[0].two_hand_text
    elsif @type == 0
      text = YEM::EQUIP::TYPE_RULES[:weapon][0]
    elsif @type == 1 and @actor.two_swords_style
      text = YEM::EQUIP::TYPE_RULES[:weapon][0]
    else
      type = @actor.equip_type[@type-1]
      return if YEM::EQUIP::TYPE_RULES[type] == nil
      text = YEM::EQUIP::TYPE_RULES[type][0]
    end
    self.contents.draw_text(x, y + WLH*2, 76, WLH, text, 0)
    self.contents.draw_text(x, y + WLH*3, 20, WLH, ">", 1)
    self.contents.font.color = normal_color
    item = @actor.equips[@type]
    if item == nil
      text = YEM::EQUIP::VOCAB[:noequip]
      self.contents.font.color.alpha = 128
      self.contents.draw_text(x+20, y + WLH*3, 196, WLH, text)
    else
      draw_item_name(item, x+20, y + WLH*3)
    end
  end
  
  #--------------------------------------------------------------------------
  # new method: draw_actor_autostate
  #--------------------------------------------------------------------------
  def draw_actor_autostate(actor, x, y, width = 96)
    count = 0
    for state in actor.equip_autostates
      next if state.icon_index == 0
      next if $imported["CoreFixesUpgradesMelody"] and state.hide_state
      draw_icon(state.icon_index, x + 24 * count, y)
      count += 1
      break if (24 * count > width - 24)
    end
  end
  
end # Window_Equip_Actor

#===============================================================================
# Window_Equip
#===============================================================================

class Window_Equip < Window_Selectable
  
  #--------------------------------------------------------------------------
  # overwrite method: initialize
  #--------------------------------------------------------------------------
  def initialize(x, y, actor)
    super(x, y, Graphics.width - 240, Graphics.height - y)
    self.active = false
    self.index = 0
    @actor = actor
    refresh
  end
  
  #--------------------------------------------------------------------------
  # actor=
  #--------------------------------------------------------------------------
  def actor=(new_actor)
    @actor = new_actor
    refresh
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: refresh
  #--------------------------------------------------------------------------
  def refresh
    @data = @actor.equips.clone
    @item_max = (@actor.equip_type.size+1)
    self.index = [@item_max-1, self.index].min
    create_contents
    self.contents.font.color = system_color
    draw_equipment_category
    draw_equipment_items
  end
  
  #--------------------------------------------------------------------------
  # new method: draw_equipment_category
  #--------------------------------------------------------------------------
  def draw_equipment_category
    self.contents.font.size = YEM::EQUIP::CATEGORY_FONT_SIZE
    dy = 0
    for i in 0..(@actor.equip_type.size)
      self.contents.font.color = system_color
      if i == 0 and @actor.weapons[0] != nil and @actor.weapons[0].two_handed
        text = @actor.weapons[0].two_hand_text
      elsif i == 0
        text = YEM::EQUIP::TYPE_RULES[:weapon][0]
      elsif i == 1 and @actor.two_swords_style
        text = YEM::EQUIP::TYPE_RULES[:weapon][0]
      else
        type = @actor.equip_type[i-1]
        text = YEM::EQUIP::TYPE_RULES[type][0]
      end
      self.contents.draw_text(4, dy, 76, WLH, text, 1)
      dy += WLH
    end
  end
  
  #--------------------------------------------------------------------------
  # new method: draw_equipment_items
  #--------------------------------------------------------------------------
  def draw_equipment_items
    self.contents.font.size = Font.default_size
    self.contents.font.color = normal_color; dy = 0; dx = 76
    for i in 0..(@actor.equip_type.size)
      self.contents.font.color = normal_color
      item = @data[i]
      if item == nil
        text = YEM::EQUIP::VOCAB[:noequip]
        self.contents.font.color.alpha = 128
        self.contents.draw_text(dx, dy, 196, WLH, text)
      else
        draw_item_name(item, dx, dy)
      end
      dy += WLH
    end
  end
  
  #--------------------------------------------------------------------------
  # new method: equip_changable?
  #--------------------------------------------------------------------------
  def equip_changable?(index)
    if index == 0 or (index == 1 and @actor.two_swords_style)
      type = :weapon
    else
      type = @actor.equip_type[index-1]
    end
    return true
  end
  
  #--------------------------------------------------------------------------
  # new method: equip_type
  #--------------------------------------------------------------------------
  def equip_type
    if self.index == 0 or (self.index == 1 and @actor.two_swords_style)
      return :weapon
    else
      return @actor.equip_type[self.index-1]
    end
  end
  
end # Window_Equip

#===============================================================================
# Window_Equip_Item
#===============================================================================

class Window_Equip_Item < Window_Selectable
  
  #--------------------------------------------------------------------------
  # initialize
  #--------------------------------------------------------------------------
  def initialize(window, actor)
    super(window.x, window.y, window.width, window.height)
    self.active = false
    self.index = 0
    @actor = actor
    refresh(:weapon)
  end
  
  #--------------------------------------------------------------------------
  # actor=
  #--------------------------------------------------------------------------
  def actor=(new_actor)
    @actor = new_actor
  end
  
  #--------------------------------------------------------------------------
  # item
  #--------------------------------------------------------------------------
  def item; return @data[self.index]; end
  
  #--------------------------------------------------------------------------
  # refresh
  #--------------------------------------------------------------------------
  def refresh(type, debug = false)
    debug = false unless $TEST
    @data = []; @type = type
    if @type == :weapon
      equips = $game_party.equip_weapons
      equips = $data_weapons if debug
    else
      equips = $game_party.equip_armours(@type)
      equips = $data_armors if debug
    end
    @data += [nil] if YEM::EQUIP::TYPE_RULES[@type][2]
    for item in equips
      @data.push(item) if include?(item)
    end
    @data += [nil] if YEM::EQUIP::TYPE_RULES[@type][2] and @data.size > 8
    @item_max = @data.size
    create_contents
    for i in 0..(@item_max-1); draw_item(i); end
  end
  
  #--------------------------------------------------------------------------
  # include?
  #--------------------------------------------------------------------------
  def include?(item)
    return false if item == nil
    case @type
    when :weapon
      return false unless item.is_a?((0X)RPG.rb::Weapon)
    else
      kind = YEM::EQUIP::TYPE_RULES[@type][1]
      return false unless item.kind == kind
    end
    return class_equippable?(item)
  end
  
  #--------------------------------------------------------------------------
  # class_equippable?
  #--------------------------------------------------------------------------
  def class_equippable?(item)
    if item.is_a?((0X)RPG.rb::Weapon)
      class_set = @actor.class.weapon_set
    else
      class_set = @actor.class.armor_set
    end
    return class_set.include?(item.id)
  end
  
  #--------------------------------------------------------------------------
  # enable?
  #--------------------------------------------------------------------------
  def enable?(item)
    return true if item == nil and YEM::EQUIP::TYPE_RULES[@type][2]
    return false if $game_party.item_number(item) <= 0
    @equippables = {} if @equippables == nil
    @equippables[item] = @actor.equippable?(item) if @equippables[item] == nil
    return @equippables[item]
  end
  
  #--------------------------------------------------------------------------
  # draw_item
  #--------------------------------------------------------------------------
  def draw_item(index)
    rect = item_rect(index)
    self.contents.clear_rect(rect)
    self.contents.font.size = Font.default_size
    self.contents.font.color = normal_color
    item = @data[index]
    if item == nil
      draw_icon(YEM::EQUIP::UNEQUIP_ICON, rect.x, rect.y)
      text = YEM::EQUIP::VOCAB[:unequip]
      self.contents.draw_text(rect.x + 24, rect.y, 172, WLH, text)
      return
    end
    number = $game_party.item_number(item)
    enabled = enable?(item)
    rect.width -= 4
    draw_item_name(item, rect.x, rect.y, enabled)
    if $imported["BattleEngineMelody"]
      self.contents.font.size = YEM::BATTLE_ENGINE::ITEM_SETTINGS[:size]
      colour = YEM::BATTLE_ENGINE::ITEM_SETTINGS[:colour]
      self.contents.font.color = text_color(colour)
      sprint = YEM::BATTLE_ENGINE::ITEM_SETTINGS[:text]
    else
      sprint = YEM::EQUIP::VOCAB[:amount]
    end
    self.contents.draw_text(rect, sprintf(sprint, number),2)
  end
  
  #--------------------------------------------------------------------------
  # update_help
  #--------------------------------------------------------------------------
  def update_help
    @help_window.set_text(item == nil ? "" : item.description)
  end
  
end # Window_Equip_Item

#===============================================================================
# Window_EquipStat
#===============================================================================

class Window_EquipStat < Window_Base
  
  #--------------------------------------------------------------------------
  # initialize
  #--------------------------------------------------------------------------
  def initialize(window, actor)
    dx = window.x + window.width
    dy = window.y
    super(dx, dy, Graphics.width - dx, Graphics.height - dy)
    @actor = actor
    refresh
  end
  
  #--------------------------------------------------------------------------
  # actor=
  #--------------------------------------------------------------------------
  def actor=(new_actor)
    @actor = new_actor
    refresh
  end
  
  #--------------------------------------------------------------------------
  # refresh
  #--------------------------------------------------------------------------
  def refresh(equip = nil, equip_index = nil)
    self.contents.clear
    @equip = equip; @equip_index = equip_index
    draw_actor_stats
    return if @equip_index == nil or (@equip != nil and 
      !@actor.equippable?(@equip))
    @clone = Marshal.load(Marshal.dump(@actor))
    @clone.change_equip(@equip_index, @equip, true)
    draw_clone_stats
  end
  
  #--------------------------------------------------------------------------
  # draw_actor_stats
  #--------------------------------------------------------------------------
  def draw_actor_stats
    dx = 0; dy = 0
    arrow = YEM::EQUIP::VOCAB[:arrow]
    for stat in YEM::EQUIP::SHOWN_STATS
      icon = Icon.stat(@actor, stat)
      case stat
      when :maxhp
        text = Vocab.hp
        value = @actor.maxhp
      when :maxmp
        text = Vocab.mp
        value = @actor.maxmp
      when :atk
        text = Vocab.atk
        value = @actor.atk
      when :def
        text = Vocab.def
        value = @actor.def
      when :spi
        text = Vocab.spi
        value = @actor.spi
      when :agi
        text = Vocab.agi
        value = @actor.agi
      when :dex
        next unless $imported["DEX Stat"]
        text = Vocab.dex
        value = @actor.dex
      when :res
        next unless $imported["RES Stat"]
        text = Vocab.res
        value = @actor.res
      when :hit
        text = Vocab.hit
        value = [@actor.hit, 100].min
        value = sprintf("%d%%", value)
      when :eva
        text = Vocab.eva
        value = [@actor.eva, 100].min
        value = sprintf("%d%%", value)
      when :cri
        text = Vocab.cri
        value = [@actor.cri, 100].min
        value = sprintf("%d%%", value)
      when :odds
        text = Vocab.odds
        value = @actor.odds
      else; next
      end
      draw_icon(icon, dx, dy); dx += 24
      self.contents.font.size = YEM::EQUIP::STAT_FONT_SIZE
      self.contents.font.color = system_color
      self.contents.draw_text(dx, dy, 60, WLH, text, 0); dx += 60
      self.contents.font.color = normal_color
      self.contents.draw_text(dx, dy, 45, WLH, value, 2); dx += 45
      self.contents.font.color = system_color
      self.contents.font.size = Font.default_size
      self.contents.draw_text(dx, dy, 30, WLH, arrow, 1); dx += 30
      if @equip_index == nil or (@equip != nil and !@actor.equippable?(@equip))
        self.contents.font.size = YEM::EQUIP::STAT_FONT_SIZE
        self.contents.font.color = normal_color
        self.contents.draw_text(dx, dy, 45, WLH, value, 2)
      end
      dx = 0; dy += WLH
    end
  end
  
  #--------------------------------------------------------------------------
  # draw_clone_stats
  #--------------------------------------------------------------------------
  def draw_clone_stats
    dx = 0; dy = 0
    last_hp = @actor.hp
    last_mp = @actor.mp
    for stat in YEM::EQUIP::SHOWN_STATS
      case stat
      when :maxhp
        value2 = @actor.maxhp
        value1 = @clone.maxhp
      when :maxmp
        value2 = @actor.maxmp
        value1 = @clone.maxmp
      when :atk
        value2 = @actor.atk
        value1 = @clone.atk
      when :def
        value2 = @actor.def
        value1 = @clone.def
      when :spi
        value2 = @actor.spi
        value1 = @clone.spi
      when :agi
        value2 = @actor.agi
        value1 = @clone.agi
      when :dex
        next unless $imported["DEX Stat"]
        value2 = @actor.dex
        value1 = @clone.dex
      when :res
        next unless $imported["RES Stat"]
        value2 = @actor.res
        value1 = @clone.res
      else; next
      end
      if value1 > value2
        self.contents.font.color = power_up_color
      elsif value1 < value2
        self.contents.font.color = power_down_color
      else
        self.contents.font.color = normal_color
      end
      self.contents.font.size = YEM::EQUIP::STAT_FONT_SIZE
      self.contents.draw_text(dx+159, dy, 45, WLH, value1, 2)
      dx = 0; dy += WLH
    end
    @actor.hp = last_hp
    @actor.mp = last_mp
  end
  
end # Window_EquipStat

#===============================================================================
# Window_EquipApt
#===============================================================================

class Window_EquipApt < Window_Base
  
  #--------------------------------------------------------------------------
  # initialize
  #--------------------------------------------------------------------------
  def initialize(aptitude_window, actor)
    @aptitude_window = aptitude_window
    dx = @aptitude_window.x + @aptitude_window.width
    dy = @aptitude_window.y
    super(dx, dy, Graphics.width - dx, Graphics.height - dy)
    @actor = actor
    refresh
  end
  
  #--------------------------------------------------------------------------
  # actor=
  #--------------------------------------------------------------------------
  def actor=(new_actor)
    @actor = new_actor
    refresh
  end
  
  #--------------------------------------------------------------------------
  # refresh
  #--------------------------------------------------------------------------
  def refresh
    self.contents.clear
    @item = @aptitude_window.item
    @item = nil if @item != nil and $game_party.item_number(@item) <= 0
    draw_actor_stats
  end
  
  #--------------------------------------------------------------------------
  # draw_actor_stats
  #--------------------------------------------------------------------------
  def draw_actor_stats
    dx = 0; dy = 0
    @actor.create_aptitude_bonus
    arrow = YEM::EQUIP::VOCAB[:arrow]
    for stat in YEM::EQUIP::SHOWN_STATS
      icon = Icon.stat(@actor, stat)
      case stat
      when :maxhp
        text = Vocab.hp
      when :maxmp
        text = Vocab.mp
      when :atk
        text = Vocab.atk
      when :def
        text = Vocab.def
      when :spi
        text = Vocab.spi
      when :agi
        text = Vocab.agi
      when :dex
        next unless $imported["DEX Stat"]
        text = Vocab.dex
      when :res
        next unless $imported["RES Stat"]
        text = Vocab.res
      else; next
      end
      value = @actor.aptitude_rate(stat)
      if @item != nil
        stat = :hp if stat == :maxhp
        stat = :mp if stat == :maxmp
        value += @item.apt_growth[stat] if @item.apt_growth[stat] != nil
        value = [value, YEM::EQUIP::MINIMUM_APTITUDE].max
        value = [value, YEM::EQUIP::MAXIMUM_APTITUDE].min
      end
      draw_icon(icon, dx, dy); dx += 24
      text1 = sprintf(YEM::EQUIP::VOCAB[:apt_rate], text)
      text2 = sprintf("%d%%", value)
      self.contents.font.size = YEM::EQUIP::STAT_FONT_SIZE
      self.contents.font.color = system_color
      self.contents.draw_text(dx, dy, 80, WLH, text1, 0); dx += 60
      self.contents.font.color = normal_color
      actor_stat = sprintf("%d%%", @actor.aptitude_rate(stat))
      self.contents.draw_text(dx, dy, 45, WLH, actor_stat, 2); dx += 45
      self.contents.font.size = Font.default_size
      self.contents.font.color = system_color
      self.contents.draw_text(dx, dy, 30, WLH, arrow, 1); dx += 30
      if value > @actor.aptitude_rate(stat)
        self.contents.font.color = power_up_color
      elsif value < @actor.aptitude_rate(stat)
        self.contents.font.color = power_down_color
      else
        self.contents.font.color = normal_color
      end
      self.contents.font.size = YEM::EQUIP::STAT_FONT_SIZE
      self.contents.draw_text(dx, dy, 45, WLH, text2, 2)
      dy += WLH
      dx = 0
    end
  end
  
end # Window_EquipApt

#===============================================================================
# Window_Aptitude
#===============================================================================

class Window_Aptitude < Window_Selectable
  
  #--------------------------------------------------------------------------
  # initialize
  #--------------------------------------------------------------------------
  def initialize(help_window, actor)
    @help_window = help_window
    dy = @help_window.y + @help_window.height
    super(0, dy, Graphics.width - 240, Graphics.height - dy)
    self.active = false
    self.index = 0
    @actor = actor
    refresh
  end
  
  #--------------------------------------------------------------------------
  # actor=
  #--------------------------------------------------------------------------
  def actor=(new_actor)
    @actor = new_actor
    refresh
  end
  
  #--------------------------------------------------------------------------
  # item
  #--------------------------------------------------------------------------
  def item; return @data[self.index]; end
  
  #--------------------------------------------------------------------------
  # refresh
  #--------------------------------------------------------------------------
  def refresh
    @data = []
    if YEM::EQUIP::SHOW_APT_BOOSTS
      @data = $game_temp.aptitude_items.clone
    else
      for item in $game_temp.aptitude_items
        next if item == nil
        next unless $game_party.item_number(item) > 0
        @data.push(item)
      end
    end
    @item_max = @data.size
    create_contents
    for i in 0..(@item_max-1); draw_item(i); end
  end
  
  #--------------------------------------------------------------------------
  # include?
  #--------------------------------------------------------------------------
  def include?(item)
    return false if item.apt_growth == {}
    return true
  end
  
  #--------------------------------------------------------------------------
  # enable?
  #--------------------------------------------------------------------------
  def enable?(item)
    return false if $game_party.item_number(item) <= 0
    changes = false
    max_apt = YEM::EQUIP::MAXIMUM_APTITUDE
    min_apt = YEM::EQUIP::MINIMUM_APTITUDE
    for key in item.apt_growth
      stat = key[0]; value = key[1]
      if value > 0 and @actor.aptitude_rate(stat) != max_apt
        changes = true
        break
      elsif value < 0 and @actor.aptitude_rate(stat) != min_apt
        changes = true
        break
      end
    end
    return changes
  end
  
  #--------------------------------------------------------------------------
  # draw_item
  #--------------------------------------------------------------------------
  def draw_item(index)
    rect = item_rect(index)
    self.contents.clear_rect(rect)
    item = @data[index]
    return if item == nil
    enabled = enable?(item)
    draw_obj_name(item, rect.clone, enabled)
    draw_obj_charges(item, rect.clone, enabled)
    draw_obj_total(item, rect.clone, enabled)
  end
  
  #--------------------------------------------------------------------------
  # new method: draw_obj_name
  #--------------------------------------------------------------------------
  def draw_obj_name(obj, rect, enabled)
    draw_icon(obj.icon_index, rect.x, rect.y, enabled)
    self.contents.font.size = Font.default_size
    self.contents.font.color = normal_color
    self.contents.font.color.alpha = enabled ? 255 : 128
    rect.width -= 48
    self.contents.draw_text(rect.x+24, rect.y, rect.width-24, WLH, obj.name)
  end
  
  #--------------------------------------------------------------------------
  # new method: draw_obj_charges
  #--------------------------------------------------------------------------
  def draw_obj_charges(obj, rect, enabled)
    return unless $imported["BattleEngineMelody"]
    return unless obj.is_a?((0X)RPG.rb::Item)
    return unless obj.consumable
    return if obj.charges <= 1
    $game_party.item_charges = {} if $game_party.item_charges == nil
    $game_party.item_charges[obj.id] = obj.charges if
      $game_party.item_charges[obj.id] == nil
    charges = $game_party.item_charges[obj.id]
    dx = rect.x; dy = rect.y + WLH/3
    self.contents.font.size = YEM::BATTLE_ENGINE::ITEM_SETTINGS[:charge]
    self.contents.font.color = normal_color
    self.contents.font.color.alpha = enabled ? 255 : 128
    self.contents.draw_text(dx, dy, 24, WLH * 2/3, charges, 2)
    self.contents.font.size = Font.default_size
  end
  
  #--------------------------------------------------------------------------
  # new method: draw_obj_total
  #--------------------------------------------------------------------------
  def draw_obj_total(obj, rect, enabled)
    if $imported["BattleEngineMelody"]
      hash = YEM::BATTLE_ENGINE::ITEM_SETTINGS
    else
      hash ={ :text => ":%d", :size => Font.default_size, :colour => 0 }
    end
    number = $game_party.item_number(obj)
    dx = rect.x + rect.width - 36; dy = rect.y; dw = 32
    text = sprintf(hash[:text], number)
    self.contents.font.size = hash[:size]
    self.contents.font.color = text_color(hash[:colour])
    self.contents.font.color.alpha = enabled ? 255 : 128
    self.contents.draw_text(dx, dy, dw, WLH, text, 2)
  end
  
  #--------------------------------------------------------------------------
  # update_help
  #--------------------------------------------------------------------------
  def update_help
    @help_window.set_text(item == nil ? "" : item.description)
  end
  
end # Window_Aptitude

#===============================================================================
# Scene_Equip
#===============================================================================

class Scene_Equip < Scene_Base
  
  #--------------------------------------------------------------------------
  # public instance variables
  #--------------------------------------------------------------------------
  attr_accessor :equip_window
  
  #--------------------------------------------------------------------------
  # overwrite method: start
  #--------------------------------------------------------------------------
  def start
    super
    create_menu_background
    @actor = $game_party.members[@actor_index]
    $game_party.last_actor_index = @actor_index
    $game_temp.equip_last = 0 if $game_temp.equip_last == nil
    @help_window = Window_Help.new
    @help_window.y = 128
    @windows = []
    create_command_window
    @status_window = Window_Equip_Actor.new(@actor)
    @equip_window = Window_Equip.new(0, 184, @actor)
    @equip_window.help_window = @help_window
    @windows.push(@equip_window)
    @stat_window = Window_EquipStat.new(@equip_window, @actor)
    @windows.push(@stat_window)
    @item_window = Window_Equip_Item.new(@equip_window, @actor)
    @item_window.help_window = @help_window
    @item_window.y = 416*3
    @windows.push(@item_window)
    update_windows
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: terminate
  #--------------------------------------------------------------------------
  def terminate
    super
    dispose_menu_background
    @command_window.dispose if @command_window != nil
    @status_window.dispose if @status_window != nil
    @help_window.dispose if @help_window != nil
    @equip_window.dispose if @equip_window != nil
    @stat_window.dispose if @stat_window != nil
    @item_window.dispose if @item_window != nil
    @aptitude_window.dispose if @aptitude_window != nil
    @apt_stat.dispose if @apt_stat != nil
  end
  
  #--------------------------------------------------------------------------
  # alias method: return_scene
  #--------------------------------------------------------------------------
  alias return_scene_eo return_scene unless $@
  def return_scene
    return_scene_eo
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: next_actor
  #--------------------------------------------------------------------------
  def next_actor
    @actor_index += 1
    @actor_index %= $game_party.members.size
    set_new_actor
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: prev_actor
  #--------------------------------------------------------------------------
  def prev_actor
    @actor_index += $game_party.members.size - 1
    @actor_index %= $game_party.members.size
    set_new_actor
  end
  
  #--------------------------------------------------------------------------
  # new method: set_new_actor
  #--------------------------------------------------------------------------
  def set_new_actor
    $game_party.last_actor_index = @actor_index
    @actor = $game_party.members[@actor_index]
    @status_window.actor = @actor
    for window in @windows; window.actor = @actor; end
    update_windows
  end
  
  #--------------------------------------------------------------------------
  # new method: create_command_window
  #--------------------------------------------------------------------------
  def create_command_window
    commands = []; @data = []
    for command in YEM::EQUIP::COMMANDS
      case command
      when :manual, :optimize
      when :aptitude
        next unless YEM::EQUIP::USE_APTITUDE_SYSTEM
        @aptitude_window = Window_Aptitude.new(@help_window, @actor)
        @aptitude_window.help_window = @help_window
        @windows.push(@aptitude_window)
        @apt_stat = Window_EquipApt.new(@aptitude_window, @actor)
        @windows.push(@apt_stat)
      else; next
      end
      @data.push(command)
      commands.push(YEM::EQUIP::VOCAB[command])
    end
    @command_window = Window_Command_Centered.new(160, commands)
    @command_window.height = 128
    @command_window.index = $game_temp.equip_last
    @command_window.active = true
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: update
  #--------------------------------------------------------------------------
  def update
    super
    update_menu_background
    if @command_window.active
      update_command_selection
    elsif @equip_window.active
      update_equip_selection
    elsif @item_window.active
      update_item_selection
    elsif @aptitude_window.active
      update_aptitude_selection
    end
  end
  
  #--------------------------------------------------------------------------
  # new method: update_windows
  #--------------------------------------------------------------------------
  def update_windows
    @aptitude_window.y = Graphics.height*8 if @aptitude_window != nil
    @apt_stat.y = Graphics.height*8 if @apt_stat != nil
    @help_window.y = Graphics.height*8
    @equip_window.y = Graphics.height*8
    @stat_window.y = @equip_window.y
    case @data[@command_window.index]
    when :aptitude
      @help_window.y = @status_window.height
      @aptitude_window.y = @help_window.y + @help_window.height
      @apt_stat.y = @aptitude_window.y
      @aptitude_window.update_help
    else
      @help_window.y = @status_window.height
      @equip_window.y = @help_window.y + @help_window.height
      @stat_window.y = @equip_window.y
      @equip_window.update_help
    end
  end
  
  #--------------------------------------------------------------------------
  # new method: update_command_selection
  #--------------------------------------------------------------------------
  def update_command_selection
    @command_window.update
    if $game_temp.equip_last != @command_window.index
      $game_temp.equip_last = @command_window.index
      update_windows
    end
    if Input.trigger?(PadConfig.cancel)
      Sound.play_cancel
      return_scene
      $game_temp.equip_last = nil
    elsif Input.repeat?(PadConfig.right)
      return if $game_temp.in_battle
      Sound.play_cursor
      next_actor
    elsif Input.repeat?(PadConfig.left)
      return if $game_temp.in_battle
      Sound.play_cursor
      prev_actor
    elsif Input.trigger?(PadConfig.decision)
      Sound.play_decision
      case @data[@command_window.index]
      when :manual
        @command_window.active = false
        @equip_window.active = true
      when :optimize
        perform_optimize
      when :aptitude
        @command_window.active = false
        @aptitude_window.active = true
      when :mastery
        $scene = Scene_Mastery.new(@actor_index, @command_window.index)
      end
    end
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: update_equip_selection
  #--------------------------------------------------------------------------
  def update_equip_selection
    @equip_window.update
    if @last_equip_index != @equip_window.index
      @last_equip_index = @equip_window.index
      @status_window.refresh(@equip_window.index)
    end
    if Input.trigger?(PadConfig.cancel)
      Sound.play_cancel
      @command_window.active = true
      @equip_window.active = false
    elsif Input.repeat?(PadConfig.right)
      return if $game_temp.in_battle
      Sound.play_cursor
      next_actor
    elsif Input.repeat?(PadConfig.left)
      return if $game_temp.in_battle
      Sound.play_cursor
      prev_actor
    elsif Input.trigger?(PadConfig.hud)
      if !YEM::EQUIP::TYPE_RULES[@equip_window.equip_type][2]
        Sound.play_buzzer
        return
      end
      return if @equip_window.item == nil
      Sound.play_equip
      last_hp_per = @actor.hp * 100.0 / [@actor.maxhp, 1].max
      last_mp_per = @actor.mp * 100.0 / [@actor.maxmp, 1].max
      @actor.change_equip(@equip_window.index, nil)
      @status_window.refresh(@equip_window.index)
      @equip_window.refresh
      @stat_window.refresh
      @actor.hp = Integer(@actor.maxhp * last_hp_per / 100.0)
      @actor.mp = Integer(@actor.maxmp * last_mp_per / 100.0)
    elsif $TEST and Input.trigger?(Input.F5) # Debug Force Equip
      Sound.play_decision
      start_item_selection(true)
    elsif Input.trigger?(PadConfig.decision)
      if @actor.locked_equips.include?(@equip_window.index) or
      @actor.fix_equipment
        Sound.play_buzzer
        return
      end
      Sound.play_decision
      start_item_selection
    end
  end
  
  #--------------------------------------------------------------------------
  # new method: start_item_selection
  #--------------------------------------------------------------------------
  def start_item_selection(debug = false)
    @equip_window.active = false
    @item_window.active = true
    @item_window.refresh(@equip_window.equip_type, debug)
    @item_window_oy = {} if @item_window_oy == nil
    @item_window_oy[@equip_window.equip_type] = 0 if
      @item_window_oy[@equip_window.equip_type] == nil
    @item_window.oy = @item_window_oy[@equip_window.equip_type]
    @item_window_index = {} if @item_window_index == nil
    @item_window_index[@equip_window.equip_type] = 0 if
      @item_window_index[@equip_window.equip_type] == nil
    @item_window.index = [[@item_window_index[@equip_window.equip_type],
      @item_window.item_max - 1].min, 0].max
    @item_window.y = @equip_window.y
    @equip_window.y = 416*3
    @item_window.update_help
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: update_item_selection
  #--------------------------------------------------------------------------
  def update_item_selection
    @item_window.update
    if @last_item_index != @item_window.index
      @last_item_index = @item_window.index
      @stat_window.refresh(@item_window.item, @equip_window.index)
    end
    if Input.trigger?(PadConfig.cancel) or ($TEST and Input.trigger?(Input.F6))
      Sound.play_cancel
      end_item_selection
    elsif $TEST and Input.repeat?(Input.F8) # Debug Increase Equip
      item = @item_window.item
      return if item == nil
      Sound.play_use_item
      $game_party.gain_item(item, 1)
      @item_window.draw_item(@item_window.index)
    elsif $TEST and Input.repeat?(Input.F7) # Debug Decrease Equip
      item = @item_window.item
      return if item == nil
      return if $game_party.item_number(item) <= 0
      Sound.play_use_item
      $game_party.lose_item(item, 1)
      @item_window.draw_item(@item_window.index)
    elsif Input.trigger?(PadConfig.hud)
      if !YEM::EQUIP::TYPE_RULES[@equip_window.equip_type][1]
        Sound.play_buzzer
        return
      end
      Sound.play_equip
      last_hp_per = @actor.hp * 100.0 / [@actor.maxhp, 1].max
      last_mp_per = @actor.mp * 100.0 / [@actor.maxmp, 1].max
      @actor.change_equip(@equip_window.index, nil)
      @status_window.refresh(@equip_window.index)
      end_item_selection
      @actor.hp = Integer(@actor.maxhp * last_hp_per / 100.0)
      @actor.mp = Integer(@actor.maxmp * last_mp_per / 100.0)
    elsif $TEST and Input.trigger?(Input.F5) # Debug Force Equip
      Sound.play_equip
      $game_temp.in_battle = true
      @actor.change_equip(@equip_window.index, @item_window.item)
      $game_temp.in_battle = false
      @status_window.refresh(@equip_window.index)
      end_item_selection
    elsif Input.trigger?(PadConfig.decision)
      if !@item_window.enable?(@item_window.item) or trade_out_item?(@actor.equips[@equip_window.index], @item_window.item) == false
        Sound.play_buzzer
        return
      end
      Sound.play_equip
      last_hp_per = @actor.hp * 100.0 / [@actor.maxhp, 1].max
      last_mp_per = @actor.mp * 100.0 / [@actor.maxmp, 1].max
      @actor.change_equip(@equip_window.index, @item_window.item)
      @status_window.refresh(@equip_window.index)
      end_item_selection
      @actor.hp = Integer(@actor.maxhp * last_hp_per / 100.0)
      @actor.mp = Integer(@actor.maxmp * last_mp_per / 100.0)
    end
  end
  
  #--------------------------------------------------------------------------
  # new method: end_item_selection
  #--------------------------------------------------------------------------
  def end_item_selection
    @item_window_oy[@equip_window.equip_type] = @item_window.oy
    @item_window_index[@equip_window.equip_type] = @last_item_index
    @item_window.active = false
    @equip_window.active = true
    @last_item_index = nil
    @equip_window.refresh
    @equip_window.y = @item_window.y
    @item_window.y = 416*3
    @equip_window.update_help
    @stat_window.refresh
  end
  
  #--------------------------------------------------------------------------
  # new method: perform_optimize
  #--------------------------------------------------------------------------
  def perform_optimize
    Sound.play_equip
    last_hp_per = @actor.hp * 100.0 / [@actor.maxhp, 1].max
    last_mp_per = @actor.mp * 100.0 / [@actor.maxmp, 1].max
    types = [:weapon] + @actor.equip_type
    slot = -1
    for type in types
      slot += 1
      type = :weapon if slot == 1 and @actor.two_swords_style
      next unless YEM::EQUIP::TYPE_RULES[type][3]
      item = optimal_equip(slot, type)
      next if item == nil
      @actor.change_equip(slot, item)
    end
    @status_window.refresh(@equip_window.index)
    @equip_window.refresh
    @stat_window.refresh
    @actor.hp = Integer(@actor.maxhp * last_hp_per / 100.0)
    @actor.mp = Integer(@actor.maxmp * last_mp_per / 100.0)
  end
  
  #--------------------------------------------------------------------------
  # new method: optimal_equip
  #--------------------------------------------------------------------------
  def optimal_equip(slot, type)
    return nil if slot == 1 and @actor.weapons[0] != nil and 
      @actor.weapons[0].two_handed
    equips = []; valid = []
    if type == :weapon
      for item in $game_party.equip_weapons
        next if item == nil 
        next unless @actor.equippable?(item)
        next unless @actor.weapons[0] != item
        equips.push(item) if trade_out_item?(@actor.weapons[slot],item)
      end
    else
      for item in $game_party.equip_armours
        next if item == nil
        next unless item.kind == YEM::EQUIP::TYPE_RULES[type][1]
        next unless @actor.equippable?(item)
        next unless @actor.armors[slot-1].id != item.id
        equips.push(item) if trade_out_item?(@actor.armors[slot-1],item)
      end
    end
    order_type = YEM::EQUIP::OPTIMIZE_SETTINGS.include?(type) ? type : :unlisted
    order = YEM::EQUIP::OPTIMIZE_SETTINGS[order_type]
    return nil if equips == []
    result = []
    for param in order
      comp_proc = YEM::EQUIP::COMP_PARAM_PROC[param]
      get_proc = YEM::EQUIP::GET_PARAM_PROC[param]
      equips.sort! { |a, b| comp_proc.call(a, b) }
      highest = equips[0]
      result = equips.find_all { |item|
        get_proc.call(highest) == get_proc.call(item)
      }
      break if result.size == 1
      equips = result.clone
    end
    return nil if result == []
    for i in 0...result.size
      print result[i].name
    end
    result.sort! { |a, b| b.id - a.id }
    return result[0]
  end
  
  #--------------------------------------------------------------------------
  # new method: update_aptitude_selection
  #--------------------------------------------------------------------------
  def update_aptitude_selection
    @aptitude_window.update
    if @last_aptitude != @aptitude_window.index
      @last_aptitude = @aptitude_window.index
      item = @aptitude_window.item
      @apt_stat.refresh
    end
    if Input.trigger?(PadConfig.cancel)
      Sound.play_cancel
      @aptitude_window.active = false
      @command_window.active = true
      @equip_window.refresh
      @stat_window.refresh
      @apt_stat.refresh
      @last_aptitude = nil
    elsif Input.repeat?(PadConfig.right)
      return if $game_temp.in_battle
      Sound.play_cursor
      next_actor
    elsif Input.repeat?(PadConfig.left)
      return if $game_temp.in_battle
      Sound.play_cursor
      prev_actor
    #--- Debug Commands ---
    elsif $TEST and Input.repeat?(Input.F8)
      Sound.play_equip
      for item in $game_temp.aptitude_items
        next if item == nil
        amount = Input.press?(Input.SHIFT) ? 10 : 1 + rand(3)
        $game_party.gain_item(item, amount)
      end
      @aptitude_window.refresh
    elsif $TEST and Input.repeat?(Input.F7)
      Sound.play_equip
      for item in $game_temp.aptitude_items
        next if item == nil
        amount = Input.press?(Input.SHIFT) ? 10 : 1 + rand(3)
        $game_party.lose_item(item, amount)
      end
      @aptitude_window.refresh
    elsif $TEST and Input.repeat?(Input.F6)
      item = @aptitude_window.item
      return if item == nil
      Sound.play_equip
      amount = Input.press?(Input.SHIFT) ? 10 : 1 + rand(3)
      $game_party.gain_item(item, amount)
      @aptitude_window.draw_item(@aptitude_window.index)
    elsif $TEST and Input.repeat?(Input.F5)
      item = @aptitude_window.item
      return if item == nil
      Sound.play_equip
      amount = Input.press?(Input.SHIFT) ? 10 : 1 + rand(3)
      $game_party.lose_item(item, amount)
      @aptitude_window.draw_item(@aptitude_window.index)
    #--- Debug Commands ---
    elsif Input.repeat?(PadConfig.decision)
      item = @aptitude_window.item
      if @aptitude_window.enable?(item)
        Sound.play_use_item
        last_hp_per = @actor.hp * 100.0 / [@actor.maxhp, 1].max
        last_mp_per = @actor.mp * 100.0 / [@actor.maxmp, 1].max
        @actor.item_growth_effect(@actor, item)
        @actor.hp = Integer(@actor.maxhp * last_hp_per / 100.0)
        @actor.mp = Integer(@actor.maxmp * last_mp_per / 100.0)
        $game_party.consume_item(item) unless @actor.skipped
        @aptitude_window.draw_item(@aptitude_window.index)
        @apt_stat.refresh
        @status_window.refresh(@equip_window.index)
      elsif Input.trigger?(PadConfig.decision)
        Sound.play_buzzer
      end
    end
  end
  
end # Scene_Equip

#===============================================================================
# 
# END OF FILE
# 
#===============================================================================
=end