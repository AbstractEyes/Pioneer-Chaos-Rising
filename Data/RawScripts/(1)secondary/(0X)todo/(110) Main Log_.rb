=begin
  2/6/2017
    Will begin today with the equipment enchantment objects.
  # -------------------------------------------------------------------------- #
  2/5/2017
    Began recording to log again, its been a long time, long update in store.
    Entire statistic system implemented for both battler types.
    Item spawning functions from rocks, currently no proper way for respawning rocks.
    Pioneer book menu implemented, still need a field book to be implemented.
    Skill maker sub program functional, still needs work.
    Enemy maker sub program functional, mostly done.
    Graphics topical system re-hauled, proper larger sprites and battle animations
      for sprites themselves will be possible.
    Still need to make weapon sprite animations in the sprite sheets function.
    Death animation does not work, and currently sprites cannot be destroyed,
      because I can't solve the issue with the ID destruction yet.
      Will approach again soon.
    Entire skill use battle system functions, still no item use yet, plan to
      worry about making a skill sequence for it soon.
    Crafting and enchanting is my current goal, so I can finish implementing
      baseline statistics into gear and modifications to gear.
    Soon I will implement globs and glob currency to spend in the new craft scenes

  # -------------------------------------------------------------------------- #
  9/8/2014
    Fixed a cursor bug, and found another.
    Worked out a simple option interface.
  # -------------------------------------------------------------------------- #
  8/27/2014
    Started school, work will be slower.
    Created items need to be included and saved.
  # -------------------------------------------------------------------------- #
  8/19/2014
    Added startup forks for atb handler.
    Added Menu Todo updates to include required changes.
  # -------------------------------------------------------------------------- #
  8/17/2014
    Added the correct status message method update system.
  # -------------------------------------------------------------------------- #
  8/16/2014
    Fixed minor bug with the Map_Scene causing stalls when switching hud types.
    Redid the methods for hud updates, going to revert.
    Determined exact flow method for hud.
      Window - if refreshed item changed, modify window.
      Scene - pass refresh calls to the windows, and update battlers.
  # -------------------------------------------------------------------------- #
  8/15/2014
    Fixed the overall structure of the hud, allowing easier flow of screens.
    Redesigned the appearance of the hud.
  # -------------------------------------------------------------------------- #
  8/14/2014
    Remodelled the scene for Scene_Map and included features for $game_options
      within the map itself.
    Created $game_options object, containing (0)options from the option menu.
    Commented Scene_Map to correctly display the separate pieces.
    Modified Game_Battler to include default macros.
  # -------------------------------------------------------------------------- #
  8/13/2014
    Included features for sprites and bars, including hidability.
  # -------------------------------------------------------------------------- #
  8/12/2014
    Completed the autohide feature of the player window.  Finally functioning.
  # -------------------------------------------------------------------------- #
  8/9/2014
    Partially fixed the window hide system, still needs window show.
  # -------------------------------------------------------------------------- #
  8/6/2014
    Tinkered with self.contents, only to find a dead space in windows.
  # -------------------------------------------------------------------------- #
  8/5/2014
    Worked on new outline for battler hud.
    Simplified the concept of the overlay into something possible.
  # -------------------------------------------------------------------------- #
  8/1/2014
    Decided on crafting forge algorithms.
    Sorted script list.
    Wrote algorithms for retrieving players.
    Rewrote option (0X)todo.
    Rewrote parts of map battler scene.
  # -------------------------------------------------------------------------- #
  7/31/2014
    Rewrote part of the game troop to handle the entire map's troop.
  # -------------------------------------------------------------------------- #
  7/30/2014
    Wrote Todo lists:
      Rethought a few strategies in the mean time.
      Reviewed basic oop principals in head.
  # -------------------------------------------------------------------------- #
  
  
=end