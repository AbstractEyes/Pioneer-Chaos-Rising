#_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
#_/   ◆                 BGM Continuance - KGC_ContinueBGM                ◆ VX ◆
#_/   ◇                       Last Update: 2008/08/31                         ◇
#_/   ◆                    Translation by Mr. Anonymous                       ◆
#_/   ◆ KGC Site:                                                             ◆
#_/   ◆ http://ytomy.sakura.ne.jp/                                            ◆
#_/   ◆ Translator's Blog:                                                    ◆
#_/   ◆ http://mraprojects.wordpress.com                                      ◆
#_/----------------------------------------------------------------------------
#_/  This script makes it possible to continue the currently playing BGM from
#_/ the map after battle without resetting the BGM position. Also note that
#_/ this effect DOES NOT work if a Victory ME(Music effect) is set to play after
#_/ the battle ends.
#_/============================================================================
#_/ Install: As close to the top of custom scripts as possible, as to gain 
#_/          greater influence to other scripts. 
#_/ This script completely overwrites Scene_Map's call_battle method as well as 
#_/  Scene_Battle's process_victory method.
#_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/

#=================================================#
#                    IMPORT                       #
#=================================================#

$imported = {} if $imported == nil
$imported["ContinueBGM"] = true

#=================================================#

#==============================================================================
# ■ (0X)RPG.rb::AudioFile
#==============================================================================

class RPG::AudioFile
  #--------------------------------------------------------------------------
  # ○ 一致判定
  #--------------------------------------------------------------------------
  def equal?(obj)
    return false unless obj.is_a?(RPG::AudioFile)
    return false if self.name != obj.name
    return false if self.volume != obj.volume
    return false if self.pitch != obj.pitch

    return true
  end
  #--------------------------------------------------------------------------
  # ○ 等値演算子
  #--------------------------------------------------------------------------
  def ==(obj)
    return self.equal?(obj)
  end
end

#★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★

#==============================================================================
# ■ Scene_Map
#==============================================================================

class Scene_Map < Scene_Base
  #--------------------------------------------------------------------------
  # ● バトル画面への切り替え
  #--------------------------------------------------------------------------
  def start_battle_bgm
    @spriteset.update
    Graphics.update
    #$game_player.make_encounter_count
    #$game_player.straighten
    #Audio['field'].fade(0, 30)

    $game_temp.map_bgm = RPG::BGM.last
    $game_temp.map_bgs = RPG::BGS.last
    if $game_temp.map_bgm != $game_system.battle_bgm
      RPG::BGM.stop
      RPG::BGS.stop
    end
    #Audio.bgm_stop
    #Audio['BGM'].fade(0,30)
    #Audio['BGM'].volume = 0
    #Audio.finish_fading
    #Audio['BGM'].pause
    #Audio['battle'].play('Audio/BGM/Battle8.mp3', 0, 100)
    #Audio['battle'].fade($system.music_volume, 60)
    #Audio.finish_fading
    #$game_system.battle_bgm.play
    #$game_temp.next_scene = nil
    #$scene = Scene_Battle.new
  end
  #--------------------------------------------------------------------------
  # ● 勝利の処理
  #--------------------------------------------------------------------------
  def end_battle_bgm
    #@info_viewport.visible = false
    #@message_window.visible = true
   #unless $game_system.battle_end_me.name.empty?
    #RPG::BGM.stop
    #  $game_system.battle_end_me.play
    #end
    #Audio['battle'].fade(0, 30)
    #Audio.finish_fading
    #Audio['battle'].pause
    #Audio['BGM'].volume = 0
    #Audio['BGM'].fade($system.music_volume,30)
    #Audio['BGM'].resume
    #Audio.finish_fading
    unless $BTEST
      $game_temp.map_bgm.play
      $game_temp.map_bgs.play
    end
    #display_exp_and_gold
    #display_drop_items
    #display_level_up
    #battle_end(0)
  end
end