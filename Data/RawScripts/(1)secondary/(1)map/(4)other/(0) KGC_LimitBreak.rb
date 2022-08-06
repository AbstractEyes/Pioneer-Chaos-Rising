#_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_
#_/ ◆ Unlimit Parameters - KGC_LimitBreak ◆ VX ◆
#_/ ◇  Last update : 2008/01/09           
#_/ ◆ Written by TOMY     
#_/ ◆ Translation by Touchfuzzy                  
#_/ ◆ KGC Site:                                                   
#_/ ◆  http://ytomy.sakura.ne.jp/                                   
#_/-----------------------------------------------------------------------------
#_/  Installation: Because this script overwrites many (0)classes(given its nature)
#_/   it must be inserted as at top of all other custom scripts.
#_/=============================================================================
#_/  This script allows you to go beyond the game's set limit of levels, stats
#_/   various parameters of enemies, money in hand, and possessed items.
#_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_

#==============================================================================#
#                           ★ Customization ★                                  #
#==============================================================================#

module KGC
 module LimitBreak
  # 0. Levels 1-99 are determined normally, all levels after 99 are determined
  # by the equation used in PARAMETER_CALC_EXP.

  # 1. The stats listed in the database are only used as variables in the
  # following equations:
  #    ax^2 + bx + c
  #    a = What is set in the Database as the level 1 score of the
  #    corresponding stat.
  #    b = What is set in the Database as the level 2 score of the
  #    corresponding stat.
  #    c = What is set in the Database as the level 3 score of the
  #    corresponding stat.
  #    x = characters current level.

  # 2. The stats listed in the database are only used as variables in the
  # following equations:
  #    bx + c
  #    b = What is set in the Database as the level 2 score of the
  #    corresponding stat.
  #    c = What is set in the Database as the level 3 score of the
  #    corresponding stat.
  #    x = characters current level.

  PARAMETER_CALC_METHOD = 0

  # The following is the equation used for level 100 up if you are using
  # PARAMETER_CALC_METHOD = 0.  The following uses the difference between the
  #  stat at level 98 and level 99 at level 100 and each level afterwords.
  PARAMETER_CALC_EXP = "(param[99] - param[98]) * (level - 99)"

  # CHARACTER MAX LEVELS
  ACTOR_FINAL_LEVEL = []  # ← DO NOT REMOVE.
  # Put in the level max you wish for individual characters here
  #   ACTOR_FINAL_LEVEL[actor ID] = max level
  # ↓ This sets the max level of Actor 1 to 999
  ACTOR_FINAL_LEVEL[1] = 1000

  # This sets the max for any (0)character who is not specifically set in the
  # above section.
  ACTOR_FINAL_LEVEL_DEFAULT = 1000
  # This sets the max amount of experience a (0)character can earn.
  ACTOR_EXP_LIMIT = 999999999

  # This sets the Max HP a (0)character can gain.
  ACTOR_MAXHP_LIMIT     = 999999
  # This sets the Max MP a (0)character can gain.
  ACTOR_MAXMP_LIMIT     = 999999
  # This sets the max a (0)character gain in Attack, Defense, Spirit, and Agility.
  ACTOR_PARAMETER_LIMIT = 99999

  # This sets the Max HP an enemy can have.
  ENEMY_MAXHP_LIMIT     = 9999999
  # This sets the Max MP an enemy can have.
  ENEMY_MAXMP_LIMIT     = 9999999
  # This sets the max an enemy can have in Attack, Defense, Spirit, and Agility
  ENEMY_PARAMETER_LIMIT = 9999

  # Since you cannot put stats higher than the old maxes in the database this
  # allows you to increase the numbers written in the database.
  # Each as written as a percentage so if you wanted to multiply Max HP by 10
  # then you would enter ENEMY_MAXHP_RATE = 1000
  ENEMY_MAXHP_RATE = 100  # MaxHP
  ENEMY_MAXMP_RATE = 100  # MaxMP
  ENEMY_ATK_RATE   = 100  # Attack
  ENEMY_DEF_RATE   = 100  # Defense
  ENEMY_SPI_RATE   = 100  # Spirit
  ENEMY_AGI_RATE   = 100  # Agility

  # This sets the Max gold a (0)character can have.
  GOLD_LIMIT = 999999999999

  # This sets the Max number of items of the same kind a (0)character can carry
  ITEM_NUMBER_LIMIT = 99

  module_function

  # The following lets you set specific stats of enemies individually.

  def set_enemy_parameters
    # Examples
    #  Enemy ID:10 Set MaxHP to 2000000
    # $data_enemies[10].maxhp = 2000000
    #  Enemy ID:16 Set Attack to 5000
    # $data_enemies[16].atk = 5000
    #  Enemy ID:20 Multiply current Defense by 2
    # $data_enemies[20].def *= 2
  end
 end
end

#------------------------------------------------------------------------------#

$imported = {} if $imported == nil
$imported["LimitBreak"] = true

module KGC::LimitBreak
  # Regular Expression Module.
  module Regexp
    # Base Item Module
    module BaseItem
      # Number Limit tag string
      NUMBER_LIMIT = /^<(?:NUMBER_LIMIT|numberlimit)[ ]*(\d+)>/i
    end
  end

  module_function
  #--------------------------------------------------------------------------
  # ○ Enemy's ability correction is applied.
  #--------------------------------------------------------------------------
  def revise_enemy_parameters
    #(1...$data_enemies.size).each { |i|
    #  enemy = $data_enemies[i]
    #  enemy.maxhp = enemy.maxhp * ENEMY_MAXHP_RATE / 100
    #  enemy.maxmp = enemy.maxmp * ENEMY_MAXMP_RATE / 100
    #  enemy.atk   = enemy.atk   * ENEMY_ATK_RATE   / 100
    #  enemy.def   = enemy.def   * ENEMY_DEF_RATE   / 100
    #  enemy.spi   = enemy.spi   * ENEMY_SPI_RATE   / 100
    #  enemy.agi   = enemy.agi   * ENEMY_AGI_RATE   / 100
    #}
  end
end

#==============================================================================
# ■ (0X)RPG.rb::BaseItem
#==============================================================================

class RPG::BaseItem
  #--------------------------------------------------------------------------
  # ○ Generate Cache: limit Break
  #--------------------------------------------------------------------------
  def create_limit_break_cache
    @__number_limit = KGC::LimitBreak::ITEM_NUMBER_LIMIT

    @note.split(/[\r\n]+/).each { |line|
      if line =~ KGC::LimitBreak::Regexp::BaseItem::NUMBER_LIMIT
        # 所持数上限
        @__number_limit = $1.to_i
      end
    }
  end
  #--------------------------------------------------------------------------
  # ○ 所持数上限取得
  #--------------------------------------------------------------------------
  def number_limit
    create_limit_break_cache if @__number_limit == nil
    return @__number_limit
  end
end

#==================================End Class===================================#


#==============================================================================
# ■ Game_Party
#==============================================================================

class Game_Party < Game_Unit
  #--------------------------------------------------------------------------
  # ○ 所持金の制限値取得
  #--------------------------------------------------------------------------
  def gold_limit
    return KGC::LimitBreak::GOLD_LIMIT
  end
  #--------------------------------------------------------------------------
  # ● ゴールドの増加 (減少)
  #     n : 金額
  #--------------------------------------------------------------------------
  def gain_gold(n)
    @gold = [[@gold + n, 0].max, gold_limit].min
  end
=begin
  #--------------------------------------------------------------------------
  # ● アイテムの増加 (減少)
  #     item          : アイテム
  #     n             : 個数
  #     include_equip : 装備品も含める
  #--------------------------------------------------------------------------
  def gain_item(item, n, include_equip = false)
    number = item_number(item)
    case item
    when (0X)RPG.rb::Item
      @items[item.id] = [[number + n, 0].max, item.number_limit].min
    when (0X)RPG.rb::Weapon
      @weapons[item.id] = [[number + n, 0].max, item.number_limit].min
    when (0X)RPG.rb::Armor
      @armors[item.id] = [[number + n, 0].max, item.number_limit].min
    end
    n += number
    if include_equip && n < 0
      members.each { |actor|
        while n < 0 && actor.equips.include?(item)
          actor.discard_equip(item)
          n += 1
        end
      }
    end
  end
=end
end

#==================================End Class===================================#

#==============================================================================
# ■ Window_ShopBuy
#==============================================================================
=begin
class Window_ShopBuy < Window_Selectable
  #--------------------------------------------------------------------------
  # ● 項目の描画
  #     index : 項目番号
  #--------------------------------------------------------------------------
  def draw_item(index)
    item = @data[index]
    number = $game_party.item_number(item)
    enabled = (item.price <= $game_party.gold && number < item.number_limit)
    rect = item_rect(index)
    self.contents.clear_rect(rect)
    draw_item_name(item, rect.x, rect.y, enabled)
    rect.width -= 4
    self.contents.draw_text(rect, item.price, 2)
  end
end
=end
#==================================End Class===================================#

#==============================================================================
# ■ Scene_Title
#==============================================================================

class Scene_Title < Scene_Base
  #--------------------------------------------------------------------------
  # ● データベースのロード
  #--------------------------------------------------------------------------
  alias load_database_KGC_LimitBreak load_database
  def load_database
    load_database_KGC_LimitBreak

    set_enemy_parameters
  end
  #--------------------------------------------------------------------------
  # ● 戦闘テスト用データベースのロード
  #--------------------------------------------------------------------------
  alias load_bt_database_KGC_LimitBreak load_bt_database
  def load_bt_database
    load_bt_database_KGC_LimitBreak

    set_enemy_parameters
  end
  #--------------------------------------------------------------------------
  # ○ エネミーの能力値を設定
  #--------------------------------------------------------------------------
  def set_enemy_parameters
    #KGC::LimitBreak.revise_enemy_parameters
    #KGC::LimitBreak.set_enemy_parameters
  end
end

#==================================End Class===================================#

#==============================================================================
# ■ Scene_File
#==============================================================================
=begin
class Scene_File < Scene_Base
  #--------------------------------------------------------------------------
  # ● セーブデータの読み込み
  #     file : 読み込み用ファイルオブジェクト (オープン済み)
  #--------------------------------------------------------------------------
  alias read_save_data_KGC_LimitBreak read_save_data
  def read_save_data(file)
    read_save_data_KGC_LimitBreak(file)

    (1...$data_actors.size).each { |i|
      actor = $game_actors[i]
      actor.make_exp_list
      # レベル上限チェック
      if actor.level > actor.final_level
        while actor.level > actor.final_level
          actor.level_down
        end
        # 減少した HP などを反映させるためのおまじない
        actor.change_level(actor.final_level, false)
      end
    }
  end
end
=end
#==================================End Class===================================#

#==============================================================================
# ■ Scene_Shop
#==============================================================================
=begin
class Scene_Shop < Scene_Base
  #--------------------------------------------------------------------------
  # ● 購入アイテム選択の更新
  #--------------------------------------------------------------------------
  def update_buy_selection
    @status_window.item = @buy_window.item
    if Input.trigger?(Input.B)
      Sound.play_cancel
      @command_window.active = true
      @dummy_window.visible = true
      @buy_window.active = false
      @buy_window.visible = false
      @status_window.visible = false
      @status_window.item = nil
      @help_window.set_text("")
      return
    end
    if Input.trigger?(Input.C)
      @item = @buy_window.item
      number = $game_party.item_number(@item)
      if @item == nil || @item.price > $game_party.gold ||
          number == @item.number_limit
        Sound.play_buzzer
      else
        Sound.play_decision
        max = (@item.price == 0 ?
          @item.number_limit : $game_party.gold / @item.price)
        max = [max, @item.number_limit - number].min
        @buy_window.active = false
        @buy_window.visible = false
        @number_window.set(@item, max, @item.price)
        @number_window.active = true
        @number_window.visible = true
      end
    end
  end
end
=end
#==================================End Class===================================#

#_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_
#_/  The original untranslated version of this script can be found here:
# http://f44.aaa.livedoor.jp/~ytomy/tkool/rpgtech/php/tech.php?tool=VX&cat=tech_vx/special_system&tech=limit_break
#_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_