=begin
#===============================================================================
#
# This is a Yanfly modified KGC Extended Equip Scene.
# Last Date Updated: 2009.06.14
# Level: Easy
#
# Added display functionality for the odds stat, combined the EP window with the
# other windows, and reduced overall lag (even more). Icons shown if added the
# Icon Reference Library. The optimization window is also made fully opaque as
# to not show any windows behind it.
#
#===============================================================================

#_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
#_/   ◆             Expanded Equip Scene - KGC_ExtendedEquipScene        ◆ VX ◆
#_/   ◇                       Last Update: 2008/09/13                         ◇
#_/   ◆                    Translation by Mr. Anonymous                       ◆
#_/   ◆ KGC Site:                                                             ◆
#_/   ◆ http://f44.aaa.livedoor.jp/~ytomy/                                    ◆
#_/   ◆ Translator's Blog:                                                    ◆
#_/   ◆ http://mraprojects.wordpress.com                                      ◆
#_/----------------------------------------------------------------------------
#_/  This script expands the equipment scene by adding a popup menu that allows
#_/ the player to manually equip, automatically equip, or remove all current
#_/ equipment. Also, this script will show more detailed information on what
#_/ stats are increased/decreased when equipping items, such as Accuracy.
#_/============================================================================
#_/  Install: Insert below KCG_HelpExtension and above KCG_EquipExtension
#_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/

#==============================================================================#
#                               ★ Customization ★                              #  
#==============================================================================#
module KGC
  module ExtendedEquipScene
  #                        ◆ Parameter Names ◆
  #  This affects the text displayed on the extended equip screen for these
  #   additional, normally hidden attribute bonuses.
  VOCAB_PARAM = {
    :maxhp => "HP",
    :maxmp => "MP",
    :hit => "HIT",        # Hit Rate
    :eva => "EVA",        # Evade
    :cri => "CRI",        # Critical
    :odds => "LUK",       # Odds/Aggro
  }#<- Do Not Remove!

  #                        ◆ Equip Parameters ◆
  #  This is the default order in which parameters are displayed on the Equip
  #   screen.
  #  :maxhp .. Maximum HP
  #  :maxmp .. Maximum MP
  #  :atk   .. Attack
  #  :def   .. Defense
  #  :spi   .. Spirit (AKA Intelligence)
  #  :agi   .. Agility
  #  :hit   .. Hit Ratio (AKA Accuracy)
  #  :eva   .. Evasion
  #  :cri   .. Critical
  #  :odds  .. Odds
  #  You may alter this order by rearranging the parameters in the brackets [].
  EQUIP_PARAMS = [ :maxhp, :maxmp, :atk, :def, :spi, :agi, :hit, :eva, :cri, :odds]

  #                      ◆ Equipment Command Names ◆ 
  #  This affects the text displayed on the Equip command popup menu.
  COMMANDS = [
    "Change",      # Equip/De-equip an item.
#~ #    "Optimize",    # Optimize equipment configuration.
#~ #    "Remove All",  # Remove all currently equipped items.
  ]# <- Do Not Remove!
  
  #                   ◆ Descriptive "Help" Window Text ◆
  #  This affects the text displayed in the "Help" (Top) Window when the 
  #   cooresponding item from above has been selected.
  COMMAND_HELP = [
    "",      # Equip/De-equip an item.
    "",    # Optimize equipment configuration.
    "",  # Remove all currently equipped items.
  ]# <- Do Not Remove! 

  #                         ◆ Optimize Equipment ◆
  #  Allows you to change what items are not automatically equipped when using
  #   the "Optimize" command. The numbers in the brackets will be excluded from
  #   automatic equipping with the optimize command.
  #  -1.Weapon  0.Shield  1.Headgear  
  #  2.Bodygear  3.Accessory  4 & 5. Equipment Expansions (See EquipExtention)
  IGNORE_STRONGEST_KIND = []

  #                  ◆ Optimize Equipment Prioritization ◆
  #  Allows you the change the order in which equipment bonuses to parameters  
  #   are prioritorized for the "Optimize" command.
  #  Parameters are as follows:
  #  :maxhp .. Maximum HP
  #  :maxmp .. Maximum MP
  #  :atk .. Attack
  #  :def .. Defense
  #  :spi .. Spirit (AKA Intelligence)
  #  :agi .. Agility
  #  :hit   .. Hit Ratio (AKA Accuracy)
  #  :eva   .. Evasion
  #  :cri   .. Critical
  #  This affects the parameter order.
  #  You may alter or add to this order by rearranging the parameters in the 
  #   brackets [].
  STRONGEST_WEAPON_PARAM_ORDER = [ :atk, :spi, :agi, :def ]
  #  This affects the armor (body gear) order.
  STRONGEST_ARMOR_PARAM_ORDER  = [ :def, :spi, :agi, :atk ]
  end
end

#=============================================================================#
#                          ★ End Customization ★                              #
#=============================================================================#

#=================================================#
#                    IMPORT                       #
#=================================================#

$imported = {} if $imported == nil
$imported["ExtendedEquipScene"] = true

#=================================================#

#==============================================================================
# □ KGC::ExtendedEquipScene
#==============================================================================

module KGC::ExtendedEquipScene
  # Compare Parameters Processing
  COMP_PARAM_PROC = {
    :atk => Proc.new { |a, b| b.atk - a.atk },
    :def => Proc.new { |a, b| b.def - a.def },
    :spi => Proc.new { |a, b| b.spi - a.spi },
    :agi => Proc.new { |a, b| b.agi - a.agi },
  }
  # Obtain Parameters Processing
  GET_PARAM_PROC = {
    :atk => Proc.new { |n| n.atk },
    :def => Proc.new { |n| n.def },
    :spi => Proc.new { |n| n.spi },
    :agi => Proc.new { |n| n.agi },
  }
end

#=================================================#

#==============================================================================
# ■ Vocab
#==============================================================================

module Vocab
  # 命中率
  def self.hit
    return KGC::ExtendedEquipScene::VOCAB_PARAM[:hit]
  end

  # 回避率
  def self.eva
    return KGC::ExtendedEquipScene::VOCAB_PARAM[:eva]
  end

  # クリティカル率
  def self.cri
    return KGC::ExtendedEquipScene::VOCAB_PARAM[:cri]
  end
  
  def self.odds
    return KGC::ExtendedEquipScene::VOCAB_PARAM[:odds]
  end
  
end

#★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★

#==============================================================================
# □ Window_ExtendedEquipCommand
#------------------------------------------------------------------------------
#   拡張装備画面で、実行する操作を選択するウィンドウです。
#==============================================================================

class Window_ExtendedEquipCommand < Window_Command
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize
    super(160, KGC::ExtendedEquipScene::COMMANDS)
    self.active = false
    self.z = 1000
    self.back_opacity = 255
  end
  #--------------------------------------------------------------------------
  # ● ヘルプウィンドウの更新
  #--------------------------------------------------------------------------
  def update_help
    @help_window.set_text(KGC::ExtendedEquipScene::COMMAND_HELP[self.index])
  end
end

#~ #★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★

#~ #==============================================================================
#~ # □ Window_EquipBaseInfo
#~ #------------------------------------------------------------------------------
#~ #   装備画面で、アクターの基本情報を表示するウィンドウです。
#~ #==============================================================================

class Window_EquipBaseInfo < Window_Base
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #     x     : ウィンドウの X 座標
  #     y     : ウィンドウの Y 座標
  #     actor : アクター
  #--------------------------------------------------------------------------
  def initialize(x, y, actor)
    super(x, y, Graphics.width / 2, Graphics.height - y)
    @actor = actor
    refresh
  end
  #--------------------------------------------------------------------------
  # ● リフレッシュ
  #--------------------------------------------------------------------------
  def refresh
    self.contents.clear
    draw_actor_name(@actor, 0, 0)
    # EP 制を使用する場合は EP を描画
    if $imported["EquipExtension"] && KGC::EquipExtension::USE_EP_SYSTEM
      draw_actor_ep(@actor, 116, 0, Graphics.width / 2 - 148)
    end
  end
end

#~ #★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★

#~ #==============================================================================
#~ # ■ Window_EquipItem
#~ #==============================================================================

class Window_EquipItem < Window_Item
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #     x          : ウィンドウの X 座標
  #     y          : ウィンドウの Y 座標
  #     width      : ウィンドウの幅
  #     height     : ウィンドウの高さ
  #     actor      : アクター
  #     equip_type : 装備部位
  #--------------------------------------------------------------------------
  alias initialize_KGC_ExtendedEquipScene initialize
  def initialize(x, y, width, height, actor, equip_type)
    width = Graphics.width / 2

    initialize_KGC_ExtendedEquipScene(x, y, width, height, actor, equip_type)

    @column_max = 1
    refresh
  end
  #--------------------------------------------------------------------------
  # ● リフレッシュ
  #--------------------------------------------------------------------------
  alias refresh_KGC_ExtendedEquipScene refresh  unless $@
  def refresh
    return if @column_max == 2  # 無駄な描画はしない

    refresh_KGC_ExtendedEquipScene
  end
end

#~ #★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★

#~ #==============================================================================
#~ # □ Window_ExtendedEquipStatus
#~ #------------------------------------------------------------------------------
#~ #   拡張装備画面で、アクターの能力値変化を表示するウィンドウです。
#~ #==============================================================================

class Window_ExtendedEquipStatus < Window_EquipStatus
  #--------------------------------------------------------------------------
  # ○ 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_writer   :equip_type               # 装備タイプ
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #     x     : ウィンドウの X 座標
  #     y     : ウィンドウの Y 座標
  #     actor : アクター
  #--------------------------------------------------------------------------
  def initialize(x, y, actor)
    @equip_type = -1
    @caption_cache = nil
    super(x, y, actor)
    @new_item = nil
    @new_param = {}
    refresh
  end
  #--------------------------------------------------------------------------
  # ● 解放
  #--------------------------------------------------------------------------
  def dispose
    super
    @caption_cache.dispose if @caption_cache != nil
  end
  #--------------------------------------------------------------------------
  # ● ウィンドウ内容の作成
  #--------------------------------------------------------------------------
  def create_contents
    self.contents.dispose
    self.contents = Bitmap.new(Graphics.width / 2 - 32, height - 32)
  end
  #--------------------------------------------------------------------------
  # ● リフレッシュ
  #--------------------------------------------------------------------------
  def refresh
    return if @equip_type < 0

    if @caption_cache == nil
      create_cache
    else
      self.contents.clear
      self.contents.blt(0, 0, @caption_cache, @caption_cache.rect)
    end
    draw_item_name(@actor.equips[@equip_type], 0, WLH)
    draw_item_name(@new_item, 24, WLH * 2)
    KGC::ExtendedEquipScene::EQUIP_PARAMS.each_with_index { |param, i|
      draw_parameter(0, WLH * (i + 3), param)
    }
  end
  #--------------------------------------------------------------------------
  # ○ キャッシュ生成
  #--------------------------------------------------------------------------
  def create_cache
    create_contents

    self.contents.font.color = system_color
    self.contents.draw_text(0, WLH * 2, 20, WLH, ">")
    # パラメータ描画
    KGC::ExtendedEquipScene::EQUIP_PARAMS.each_with_index { |param, i|
      draw_parameter_name(0, WLH * (i + 3), param)
    }

    @caption_cache = Bitmap.new(self.contents.width, self.contents.height)
    @caption_cache.blt(0, 0, self.contents, self.contents.rect)
  end
  #--------------------------------------------------------------------------
  # ○ 能力値名の描画
  #     x    : 描画先 X 座標
  #     y    : 描画先 Y 座標
  #     type : 能力値の種類
  #--------------------------------------------------------------------------
  def draw_parameter_name(x, y, type)
    case type
    when :maxhp
      name = Vocab.hp
      icon = YE::ICON::MAXHP if $imported["IconReferenceLibrary"]
    when :maxmp
      name = Vocab.mp
      icon = YE::ICON::MAXMP if $imported["IconReferenceLibrary"]
    when :atk
      name = Vocab.atk
      icon = YE::ICON::ATK if $imported["IconReferenceLibrary"]
    when :def
      name = Vocab.def
      icon = YE::ICON::DEF if $imported["IconReferenceLibrary"]
    when :spi
      name = Vocab.spi
      icon = YE::ICON::SPI if $imported["IconReferenceLibrary"]
    when :agi
      name = Vocab.agi
      icon = YE::ICON::AGI if $imported["IconReferenceLibrary"]
    when :hit
      name = Vocab.hit
      icon = YE::ICON::HIT if $imported["IconReferenceLibrary"]
    when :eva
      name = Vocab.eva
      icon = YE::ICON::EVA if $imported["IconReferenceLibrary"]
    when :cri
      name = Vocab.cri
      icon = YE::ICON::CRI if $imported["IconReferenceLibrary"]
    when :odds
      name = Vocab.odds
      icon = YE::ICON::ODDS if $imported["IconReferenceLibrary"]
    end
    self.contents.font.color = system_color
    if $imported["IconReferenceLibrary"]
      draw_icon(icon, x, y)
      self.contents.draw_text(x + 28, y, 72, WLH, name)
    else
      self.contents.draw_text(x + 4, y, 96, WLH, name)
    end
    self.contents.font.color = system_color
    self.contents.draw_text(x + 156, y, 20, WLH, ">", 1)
  end
  #--------------------------------------------------------------------------
  # ● 装備変更後の能力値設定
  #     new_param : 装備変更後のパラメータの配列
  #     new_item  : 変更後の装備
  #--------------------------------------------------------------------------
  def set_new_parameters(new_param, new_item)
    changed = false
    # パラメータ変化判定
    KGC::ExtendedEquipScene::EQUIP_PARAMS.each { |k|
      if @new_param[k] != new_param[k]
        changed = true
        break
      end
    }
    changed |= (@new_item != new_item)

    if changed
      @new_item = new_item
      @new_param = new_param
      refresh
    end
  end
  #--------------------------------------------------------------------------
  # ● 能力値の描画
  #     x    : 描画先 X 座標
  #     y    : 描画先 Y 座標
  #     type : 能力値の種類
  #--------------------------------------------------------------------------
  def draw_parameter(x, y, type)
    case type
    when :maxhp
      value = @actor.maxhp
    when :maxmp
      value = @actor.maxmp
    when :atk
      value = @actor.atk
    when :def
      value = @actor.def
    when :spi
      value = @actor.spi
    when :agi
      value = @actor.agi
    when :hit
      value = @actor.hit
    when :eva
      value = @actor.eva
    when :cri
      value = @actor.cri
    when :odds
      value = @actor.odds
    end
    new_value = @new_param[type]
    self.contents.font.color = normal_color
    self.contents.draw_text(x + 106, y, 48, WLH, value, 2)
    if new_value != nil
      self.contents.font.color = new_parameter_color(value, new_value)
      self.contents.draw_text(x + 176, y, 48, WLH, new_value, 2)
    end
  end
end

#~ #★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★

#~ #==============================================================================
#~ # ■ Scene_Equip
#~ #==============================================================================

class Scene_Equip < Scene_Base
  #--------------------------------------------------------------------------
  # ○ 定数
  #--------------------------------------------------------------------------
  STANDARD_WIDTH  = Graphics.width / 2
  ANIMATION_SPPED = 800
  #--------------------------------------------------------------------------
  # ● 開始処理
  #--------------------------------------------------------------------------
  alias start_KGC_ExtendedEquipScene start
  def start
    start_KGC_ExtendedEquipScene

    # ステータスウィンドウを作り直す
    @status_window.dispose
    @status_window = Window_ExtendedEquipStatus.new(0, 0, @actor)
    @space_gauge_window = Window_SpaceGauge.new(544/2,416-60,544/2,60)
    create_command_window

    @last_item = (0X)RPG.rb::Weapon.new
    @base_info_window = Window_EquipBaseInfo.new(0, @help_window.height, @actor)
    @base_info_window.z = @equip_window.z - 1

    adjust_window_for_extended_equiop_scene
    Graphics.frame_reset
  end
  #--------------------------------------------------------------------------
  # ○ ウィンドウの座標・サイズを拡張装備画面向けに調整
  #--------------------------------------------------------------------------
  def adjust_window_for_extended_equiop_scene
    @base_info_window.width = @equip_window.width

    @equip_window.x = 0
    @equip_window.y = @base_info_window.y + 24
    @equip_window.height = Graphics.height - @equip_window.y
    @equip_window.active = false
    @equip_window.z = 100
    @equip_window.opacity = 0
    
    @space_gauge_window.opacity = 0
    @space_gauge_window.x = 20
    @space_gauge_window.y = 300   
    
    @status_window.x = 0
    @status_window.y = @base_info_window.y
    @status_window.width = STANDARD_WIDTH
    @status_window.height = Graphics.height - @status_window.y
    @status_window.visible = false
    @status_window.z = 100
    @status_window.opacity = 0

    @item_windows.each { |window|
      window.x = @equip_window.width
      window.y = @help_window.height
      window.z = 50
      window.height = Graphics.height - @help_window.height
    }
  end
  
  def fix_space_window
    @space_gauge_window.opacity = 0
    @space_gauge_window.x = 20
    @space_gauge_window.y = 300
  end
  #--------------------------------------------------------------------------
  # ○ コマンドウィンドウの作成
  #--------------------------------------------------------------------------
  def create_command_window
    @command_window = Window_ExtendedEquipCommand.new
    @command_window.help_window = @help_window
    @command_window.active = true
    @command_window.x = (Graphics.width - @command_window.width) / 2
    @command_window.y = (Graphics.height - @command_window.height) / 2
    @command_window.update_help
    @command_window.visible = false

    # 装備固定なら「最強装備」「すべて外す」を無効化
    if @actor.fix_equipment
      @command_window.draw_item(1, false)
      @command_window.draw_item(2, false)
    end
  end
  #--------------------------------------------------------------------------
  # ● 終了処理
  #--------------------------------------------------------------------------
  alias terminate_KGC_ExtendedEquipScene terminate
  def terminate
    terminate_KGC_ExtendedEquipScene
    @space_gauge_window.dispose
    @command_window.dispose
    @base_info_window.dispose
  end
  #--------------------------------------------------------------------------
  # ○ ウィンドウをリフレッシュ
  #--------------------------------------------------------------------------
  def refresh_window
    @base_info_window.refresh
    @equip_window.refresh
    @status_window.refresh
    @item_windows.each { |window| window.refresh }
    @space_gauge_window.update
    Graphics.frame_reset
  end
  #--------------------------------------------------------------------------
  # ● フレーム更新
  #--------------------------------------------------------------------------
  alias update_KGC_ExtendedEquipScene update
  def update
    update_command_window
    if @command_window.active
      update_KGC_ExtendedEquipScene
      update_command_selection
    else
      update_KGC_ExtendedEquipScene
    end
  end
  #--------------------------------------------------------------------------
  # ○ コマンドウィンドウの更新
  #--------------------------------------------------------------------------
  def update_command_window
    @command_window.update
  end
  #--------------------------------------------------------------------------
  # ● ステータスウィンドウの更新
  #--------------------------------------------------------------------------
  def update_status_window
    @base_info_window.update
    @status_window.update

    if @command_window.active || @equip_window.active
      @status_window.set_new_parameters({}, nil)
    elsif @item_window.active
      return if @last_item == @item_window.item

      @last_item = @item_window.item
      temp_actor = Marshal.load(Marshal.dump(@actor))
      temp_actor.change_equip(@equip_window.index, @item_window.item, true)
      param = {
        :maxhp => temp_actor.maxhp,
        :maxmp => temp_actor.maxmp,
        :atk   => temp_actor.atk,
        :def   => temp_actor.def,
        :spi   => temp_actor.spi,
        :agi   => temp_actor.agi,
        :hit   => temp_actor.hit,
        :eva   => temp_actor.eva,
        :cri   => temp_actor.cri,
        :odds  => temp_actor.odds,
      }
      @status_window.equip_type = @equip_window.index
      @status_window.set_new_parameters(param, @last_item)
      Graphics.frame_reset
    end
  end
  #--------------------------------------------------------------------------
  # ○ コマンド選択の更新
  #--------------------------------------------------------------------------
  def update_command_selection
    update_window_position_for_equip_selection
#~     if Input.trigger?(Input.B)
#~       Sound.play_cancel
#~       return_scene
#~     elsif Input.trigger?(Input.R)
#~       Sound.play_cursor
#~       next_actor
#~     elsif Input.trigger?(Input.L)
#~       Sound.play_cursor
#~       prev_actor
#~     elsif Input.trigger?(Input.C)
#~       case @command_window.index
#~       when 0  # 装備変更
#~         Sound.play_decision
#~         # 装備部位ウィンドウに切り替え
#~       when 1  # 最強装備
#~         if @actor.fix_equipment
#~           Sound.play_buzzer
#~           return
#~         end
#~         Sound.play_equip
#~         process_equip_strongest
#~       when 2  # すべて外す
#~         if @actor.fix_equipment
#~           Sound.play_buzzer
#~           return
#~         end
#~         Sound.play_equip
#~         process_remove_all
#~       end
#~     end
    @equip_window.active = true
    @command_window.active = false
    @command_window.close
    @space_gauge_window.dispose
    @space_gauge_window = Window_SpaceGauge.new(544/2,416-60,544/2,60)
    fix_space_window

  end
  #--------------------------------------------------------------------------
  # ● 装備部位選択の更新
  #--------------------------------------------------------------------------

  alias update_equip_selection_KGC_ExtendedEquipScene update_equip_selection
  def update_equip_selection
    update_window_position_for_equip_selection
#~ #    if Input.trigger?(Input.A)
#~ #      if @actor.fix_equipment
#~ #        Sound.play_buzzer
#~ #        return
#~ #      end
#~       # 選択している装備品を外す
#~ #      Sound.play_equip
#~ #      @actor.change_equip(@equip_window.index, nil)
#~ #      refresh_window
    if Input.trigger?(Input.B)
      Sound.play_cancel
      return_scene
      # コマンドウィンドウに切り替え
#~       @equip_window.active = false
#~       @command_window.active = true
#~       @command_window.open
#~       @space_gauge_window = Window_SpaceGauge.new(544/2,416-60,544/2,60)
#~       fix_space_window
      return
    elsif Input.trigger?(Input.R)
      Sound.play_cursor
      next_actor
    elsif Input.trigger?(Input.L)
      Sound.play_cursor
      prev_actor
    elsif Input.trigger?(Input.R) || Input.trigger?(Input.L)
      # アクター切り替えを無効化
      return
    elsif Input.trigger?(Input.C)
      # 前回のアイテムをダミーにする
      @space_gauge_window.dispose
      @space_gauge_window = Window_SpaceGauge.new(544/2,416-60,544/2,60)
      fix_space_window
      @last_item = (0X)RPG.rb::Weapon.new
    end

    update_equip_selection_KGC_ExtendedEquipScene
  end
  #--------------------------------------------------------------------------
  # ● アイテム選択の更新
  #--------------------------------------------------------------------------

  alias update_item_selection_KGC_ExtendedEquipScene update_item_selection
  def update_item_selection
    update_window_position_for_item_selection

    update_item_selection_KGC_ExtendedEquipScene
    if Input.trigger?(Input.C)
      @base_info_window.refresh
    end
  end
  #--------------------------------------------------------------------------
  # ○ ウィンドウ位置の更新 (装備部位選択)
  #--------------------------------------------------------------------------
  def update_window_position_for_equip_selection
    return if @item_window.x == @equip_window.width

    @base_info_window.width = @equip_window.width
    @item_window.x = @equip_window.width
    @space_gauge_window = Window_SpaceGauge.new(544/2,416-60,544/2,60)
    fix_space_window    
    @equip_window.visible = true
    @status_window.visible = false
  end
  #--------------------------------------------------------------------------
  # ○ ウィンドウ位置の更新 (アイテム選択)
  #--------------------------------------------------------------------------
  def update_window_position_for_item_selection
    return if @item_window.x == STANDARD_WIDTH

    @base_info_window.width = STANDARD_WIDTH
    @item_window.x = STANDARD_WIDTH
    @equip_window.visible = false
    @space_gauge_window.dispose
    @status_window.visible = true
  end
  #--------------------------------------------------------------------------
  # ○ 最強装備の処理
  #--------------------------------------------------------------------------
  def process_equip_strongest
    # 以前のパラメータを保存
    last_hp = @actor.hp
    last_mp = @actor.mp
    # 最強装備対象の種別を取得
    type = [-1]
    type += ($imported["EquipExtension"] ? @actor.equip_type : [0, 1, 2, 3])
    type -= KGC::ExtendedEquipScene::IGNORE_STRONGEST_KIND
    weapon_range = (@actor.two_swords_style ? 0..1 : 0)

    # 装備対象の武具をすべて外す
    type.each_index { |i| @actor.change_equip(i, nil) }
    # 最強装備
    type.each_index { |i|
      case i
      when weapon_range  # 武器
        # １本目が両手持ちの場合は２本目を装備しない
        if @actor.two_swords_style
          weapon = @actor.weapons[0]
          next if weapon != nil && weapon.two_handed
        end
        weapon = strongest_item(i, -1)
        next if weapon == nil
        @actor.change_equip(i, weapon)
      else               # 防具
        # 両手持ち武器を持っている場合は盾 (防具1) を装備しない
        if i == 1
          weapon = @actor.weapons[0]
          next if weapon != nil && weapon.two_handed
        end
        armor = strongest_item(i, type[i])
        next if armor == nil
        @actor.change_equip(i, armor)
      end
    }

    # 以前のパラメータを復元
    @actor.hp = last_hp
    @actor.mp = last_mp

    refresh_window
  end
  #--------------------------------------------------------------------------
  # ○ 最も強力なアイテムを取得
  #     equip_type : 装備部位
  #     kind       : 種別 (-1..武器  0～..防具)
  #    該当するアイテムがなければ nil を返す。
  #--------------------------------------------------------------------------
  def strongest_item(equip_type, kind)
    equips = nil
    param_order = nil

    case kind
    when -1  # 武器
      # 装備可能な武器を取得
      equips = $game_party.items.find_all { |item|
        valid = item.is_a?((0X)RPG.rb::Weapon) && @actor.equippable?(item)
        if valid && $imported["EquipExtension"]
          valid = @actor.ep_condition_clear?(equip_type, item)
        end
        valid
      }
      # パラメータ優先度を指定
      param_order = KGC::ExtendedEquipScene::STRONGEST_WEAPON_PARAM_ORDER
    else     # 防具
      # 装備可能な防具を取得
      equips = $game_party.items.find_all { |item|
        valid = item.is_a?((0X)RPG.rb::Armor) && item.kind == kind &&
          @actor.equippable?(item)
        if valid && $imported["EquipExtension"]
          valid = @actor.ep_condition_clear?(equip_type, item)
        end
        valid
      }
      # パラメータ優先度を指定
      param_order = KGC::ExtendedEquipScene::STRONGEST_ARMOR_PARAM_ORDER
    end

    # 対象アイテムがない
    return nil if equips.empty?

    # 優先度に基づいて最強装備を取得
    result = []
    param_order.each { |param|
      # 比較用プロシージャ取得
      comp_proc = KGC::ExtendedEquipScene::COMP_PARAM_PROC[param]
      get_proc = KGC::ExtendedEquipScene::GET_PARAM_PROC[param]
      # パラメータ順にソート
      equips.sort! { |a, b| comp_proc.call(a, b) }
      # 最もパラメータが高いアイテムを取得
      highest = equips[0]
      result = equips.find_all { |item|
        get_proc.call(highest) == get_proc.call(item)
      }
      # 候補が１つに絞れたら終了
      break if result.size == 1
      equips = result.clone
    }

    # 結果を ID 降順に整列
    result.sort! { |a, b| b.id - a.id }

    return result[0]
  end
  #--------------------------------------------------------------------------
  # ○ すべて外す処理
  #--------------------------------------------------------------------------
  def process_remove_all
    type_max = ($imported["EquipExtension"] ? @actor.equip_type.size : 3) + 1
    type_max.times { |i| @actor.change_equip(i, nil) }
    refresh_window
  end
end
=end