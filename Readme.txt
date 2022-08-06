# ------------------------- #
# Pioneer v0.01 - Pre Alpha #
# ------------------------- #

# --------------- #
# Begining Notes: #
# --------------- #

	# The town scripts are very buggy.  I would be surprised if you don't crash testing them.

	# Many NPC's are just completely broken, so save often and keep track of the ones you find that are broken.

	# Many inconsistencies with the new systems and the old, keep track of all problems you run into and log them.

	# There is no crash log handler at this point, I had one but found it to be buggy so I removed it.  I will rewrite later to upload the crash files directly to the server for those who are using .net 4.5.

	# Because I broke most of the systems which include the hotspotter systems, monster systems, and so on, you will find many very buggy things here and there.  I would make a list myself but the list is huge.  I need your help.

	# MOST areas do not have individual recipes for their upgrades, if you find yourself shelling out herbs and mushrooms for everything, don't be alarmed.  They are simply in a base recipe location that will be replaced at another time with a proper recipe for the area or building.
	
# ------------- #
# Future Plans: #
# ------------- #

	# Every suggestion will be taken into account with how I progress the game, including story suggestions, designs for characters, music, icons, and so on.  This job is huge, and I find myself overencumbered with the work.  Any contribution will be useful and benificial to the game itself.  Keep in mind, anything copyright by another company cannot be used without the company's direct consent.  DO NOT submit content that is under copyright laws.
	
	# All systems will be properly calibrated with the new item scale algorithms here:
		# Resource and Coin Value Algorithms
		# coin_value = resource_value * 10
		# resource_value = coin_value / 10
		#
		# single_item_resources = (level * 1) # 1 item
		# single_item_coins = (level * 10) # 1 item
		#
		# build_area_resources = (level * 20) # 20 items
		# build_area_coins = (level * 200) # 20 items
		#
		# upgrade_area_resource = (level * 20) # 20 items
		# upgrade_area_coins = (level * 200) # 20 items
		#
		# single_gear_cost = (level * 10) # 10 items
		# full_character_gear_cost = ((level * 10) * 5) # 50 items
		# full_party_gear_cost = (((level * 10) * 5) * party_members) # (50 * (4 to 10))
		# ------------- #
		# # # Notes # # #
		# --------------------------------------------------------------------- #
		# These are the basis for the algorithms that run the game's balancing. #
		# --------------------------------------------------------------------- #
	They will be calibrated at a later time.  The build is very preliminary and needs to be cleaned up.
	
# --------------------------------------------- #
# Any questions are to be directed at my steam: #
# --------------------------------------------- #
Steam ID:  Jojomonkey15
Steam Name:  Funplayer