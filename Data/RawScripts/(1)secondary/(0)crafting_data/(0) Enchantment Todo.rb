=begin

  Data:
    Currency to exchange for enchantments
    Enchantment formulas to create enchantments
    Functions to add and remove enchantments from equipment

    Enchantments


  Objects:

  Windows:
    Enchant System:
      Equipment window:     to display equipment with sockets
      Enchantment window:   to provide enchantments into the equipment itself.
      Costs window:         to display costs of the enchantments
      Details window:       displays the before and after details of the equipment
    Enhance System:
      Equipment window:     to display all equipment with enchantments
      Enhance window:       lets the player select enchantments after selecting equipment
      Costs window:         displays the costs for upgrading the current enchantment
      Details window:       displays the before and after details of the equipment
  Scenes:
    Scene Flow:
      equipment >
        select socket >
          (disenchant / confirm) /
          (enhance / confirm) /
            enchant window >
              (select enchantment / confirm)


=end