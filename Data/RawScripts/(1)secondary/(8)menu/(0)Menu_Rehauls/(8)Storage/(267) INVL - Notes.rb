################################################################################
# Fridgecrisis' Inventory Limit (INVL)                                         #
#------------------------------------------------------------------------------#
# Version 1.0
#
# This script limits the number/total size of items or equips you can hold at
# once. Shopping and the Equip menu both reflect these new changes. 'Use' and
# 'Drop' (0)options have been added to the Item menu, and there is a storage system
# that can be called from a simple line of script.
#
# Version Details:
# 1.0 - 04/27/10 - Major debugging and testing finished.
# 0.9 - 04/19/10 - Finished most basic functions.
#
# Future Features:
# - Fix multiple mandatory Use/Drop windows when getting more than one kind of
#   item.
# - Storage space limit.
# - Options for storage window format.
# - Show the space gauge when shopping.
#
# Overwrites:
# - Window_ShopBuy: draw_item
# - Scene_Map: update_scene_change
# - Scene_Item: update_item_selection, use_item_nontarget
# - Scene_Equip: update_item_selection
# - Scene_Shop: update_buy_selection, update_sell_selection
#
# Aliases:
# - Game_Party: initialize, gain_item
# - Window_Item: enable?

# - Window_EquipItem: enable?
# - Window_ShopSell: enable?
# - Scene_Item: start, terminate, update
#
# Incompatible With:
# - KGC/Yanfly_ExtendedEquipScene (Won't display the stat window and creates a
#   long pause)
#
# Credits:
# - KGC_CategorizeItem. I would have been very lost without its example.
#
################################################################################
# Instructions                                                                 #
#------------------------------------------------------------------------------#
#
# This script includes 3 basic functions: Use/Drop, Space and Size, and Storage.
# I have also included this general-use tag:
#
#-No Sell---#
# <no sell> #
#-----------#
# Add this tag to an item, weapon, or armor to disable selling it. This way, you
# can still buy something but be unable to sell it back.
#
################################################################################
# Function 1: Use/Drop                                                         #
#------------------------------------------------------------------------------#
#
# Open the Item menu, and you'll find a new window that asks whether you would
# like to Use or Drop an item. Use works like the regular item menu, while
# choosing to Drop an item will simply remove it from your inventory. You can
# change the vocabulary and window width in the editing section below.
#
#-No Drop---#
# <no drop> #
#-----------#
# Add this tag to an item or equip and the player will not be allowed to drop
# it.
#
################################################################################
# Function 2: Space and Size                                                   #
#------------------------------------------------------------------------------#
#
# Another new window you'll see on the Item screen is the space gauge. It will
# show you the values of two new elements: space and size.
#
#-Space-------------#
# DEFAULT_SPACE = x #
# MAX_SPACE = x     #
#-------------------#
# Space is how big your bag is. Set DEFAULT_SPACE to the amount of space you'd
# like to have by default. MAX_SPACE sets a limit to the total amount of space
# you can have.
#
#-Adding Space--------#
# <add space x>       #
# <equip for space>   #
# <unequip for space> #
#---------------------#
# Add the <add space x> tag to items, weapons, or armors to add x amount of
# space to your total inventory space. By default, weapons and armors that add
# space will add it regardless of whether or not you have them equipped, but if
# you'd like to have the space take effect only when the object is equipped or
# unequipped, add the <equip for space> or <unequip for space> tags. For
# instance, a backpack with <add space 5> and <equip for space> will only add
# that space if it's equipped, and won't add any space when it's not.
#
#-Size----------------------------#
# <item size x>                   #
# INCLUDE_EQUIP_SIZE = true/false #
#---------------------------------#
# Add <item size x> onto your items or equips to set their size. Your
# inventory's total size is compared to your total space by the space gauge. By
# default, everything has a size of 1. Set INCLUDE_EQUIP_SIZE to true if you
# want your equipment to be included in the size
#
#-Checking Size--------------------#
# $game_party.can_hold?('x', y, z) #
# $game_party.force_drop?          #
#----------------------------------#
# On most occassions, when getting an item, the game will automatically check
# your total item size against your current space, and if the check fails, it
# will run a mandatory Use/Drop screen that won't let you exit from it until
# your item size is below your current space. However, the drop screen will not
# run during a battle, and opening a treasure chest just to be required to drop
# something else can be frustrating. These two lines of script are here to
# fix these problems.
#
# $game_party.can_hold?('x', y, z) can tell you whether or not the player can
# hold a certain item. x is the word 'item', 'weapon', or 'armor' (be sure to
# put one pair of single quotes around it!), y is the ID of the item, weapon, or
# armor you'd like to check, and z is how many you're checking for. Call this
# line of script in a Conditional Branch. This can allow treasure chests to keep
# their contents until the player is ready for them, or an NPC to hold on to an
# item if the player can't hold it.
#
# $game_party.force_drop? will check to see whether or not your inventory is
# past full, and will run the mandatory Use/Drop screen if it is. You can call
# this from any common event or regular event, wherever you see fit. Just
# remember that the Use/Drop screen will not appear in battle.
#
# As a side note, when gaining more than one kind of item or equip at once, each
# kind will get added one at a time, and this can cause the mandatory Use/Drop
# scene to appear multiple times in a row if the player has already reached
# their inventory limit. To avoid some of the confusion, when giving the player
# more than one kind of item, you can create a "Got Item!" window for each item
# and add the Change Items event for each item just after their respective
# windows. This will make it more apparent that the player's inventory is
# changing between Use/Drop screens. Sorry about this. If I can find a way to
# fix it, I will.
#
################################################################################
# Function 3: Storage                                                          #
#------------------------------------------------------------------------------#
#
# With a limit on how many things you can carry, it's necessary to make a way to
# store extra things without getting rid of them completely.
#
#-Do Storage-------------#
# $game_party.do_storage #
#------------------------#
# Run this line of script from an event to call storage. Your storage can hold
# an infinite amount of items (for now--future versions may allow for a storage
# limit as well), but it won't let you take things out if it would put you over
# your inventory space limit.
#
#-No Store---#
# <no store> #
#------------#
# Add this tag to an item or equip and you won't be able to store it.
#
################################################################################
# End.                                                                         #
################################################################################