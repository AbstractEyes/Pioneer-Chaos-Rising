module PHI
  module Vocab
    MENU_ITEM = 'Inventory'
    MENU_EQUIP = 'Equipment'
    MENU_SKILL = 'Abilities'
    MENU_STATUS = 'Statistics'
    MENU_SAVE = 'Save Game'
    MENU_CONFIG = 'Configuration'
    MENU_EXIT = 'Return'
    MENU_PARTY = 'Party'
    MENU_FORMATION = 'Formation'
    
    HP_SHORT            = 'HP'
    HP                  = 'Health Points'
    MP_SHORT            = 'SP'
    MP                  = 'Skill Points'
    ATTACK_SHORT        = 'ATK'
    ATTACK              = 'Attack Strength'
    DEFENSE_SHORT       = 'DEF'
    DEFENSE             = 'Defensive Potential'
    AGILITY_SHORT       = 'AGI'
    AGILITY             = 'Agility'
    SPIRIT_SHORT        = 'SPI'
    SPIRIT              = 'Magic Strength'
    DEXTERITY_SHORT     = 'RAN'
    DEXTERITY           = 'Range Strength'

    BLOCKED             = 'had their path blocked.'

    WINDOWS = {
      0  => [true, 'Black'],
      1  => [false, 'Orange'],
      2  => [false, 'Yellow'],
      3  => [false, 'Green'],
      4  => [false, 'Cyan'],
      5  => [false, 'Navy'],
      6  => [false, 'Blue'],
      7  => [false, 'Violet'],
      8  => [false, 'Purple'],
      9  => [false, 'Pink'],
      10 => [false, 'Grey'],
      11 => [false, 'Red'],
    }
    INPUTS = {
      0 => [true, 'Configure ->'],
    }
    CURSOR = {
      0 => [true, 'Configure ->'],
    }
    ATB = {
      0 => [false, 'Active'],
      1 => [true, 'Wait'],
    }
    AUTOHIDE = {
      0 => [true, 'Players'],
      1 => [true, 'Details'],
      2 => [true, 'Minimap'],
    }
    VOLUME = {
      0 => [true, 'Music'],
      1 => [true, 'Effects'],
    }
    MINIMAP = {
      0 => [true, 'Configure ->'],
    }
    AUTODASH = {
      0 => [true, 'Enabled'],
      1 => [false, 'Disabled'],
    }
    OPTIONS = {
      0 => ['Window: ', WINDOWS],
      1 => ['Inputs: ', INPUTS],
      2 => ['Cursor: ', CURSOR],
      3 => ['ATB: ', ATB],
      4 => ['Autohide: ', AUTOHIDE],
      5 => ['Volume: ', VOLUME],
      6 => ['Minimap: ', MINIMAP],
      7 => ['Autodash: ', AUTODASH],
    }
    
  end
end
