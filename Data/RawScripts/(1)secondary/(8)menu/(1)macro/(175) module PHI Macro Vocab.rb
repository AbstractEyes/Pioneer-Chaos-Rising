module Macro_Requirements
  
  PRIORITY = {
    :DEFAULT => "Normal",
    :RANDOM  => "Random",
    :HIGHEST => "Highest",
  }
  
  FORMULA = {
    :STANDARD => "(priority)((target)(statistic) (comparison) (direct)(param))",
    :TARGET   => "(priority)((target)(statistic) (comparison) (target)(statistic))",
  }
  
  STATISTIC = {
    :HP           => "Health",
    :MP           => "Skill",
    :LEVEL        => "Level",
    :STRENGTH     => "Strength",
    :DEXTERITY    => "Dexterity",
    :MAGI         => "Magi",
    :WILLPOWER    => "Willpower",
    :AGILITY      => "Agility",
    :DURABILITY   => "Durability",
    :TOUGHNESS    => "Toughness",
    :RAW_RES      => "Raw Resistence",
    :MAGIC_RES    => "Magic Resistence",
    :SKILL_RES    => "Skill Resistence",
    :ELEMENT      => "(element) Resistence",
    :STATE        => "(state) Resistence",
    :HAS_STATE    => "(state) is active",
    :NO_STATE     => "(state) is not active",
  }
  
  TARGET = {
    :SELF           => "Self",
    :FRIEND         => "Friend",
    :FRIEND_GENERAL => "General",
    :FRIEND_NAMED   => "(name)",
    :ENEMY          => "Enemy",
  }
  
  DIRECT_PARAM = {
    :DIRECT      => "Amount",
    :PERCENT     => "%",
  }
  
  CONDITIONAL = {
    :GT => ">",
    :LT => "<",
    :ET => "=",
  }
  
  COMPARISON = {
    :AMOUNT   => 999,
    :PERCENT  => (10...100).to_a,
  }
  
  BATTLE_COMMANDS = {
    :attack   =>    "Attack",
    :defend   =>    "Defend",
    :item     =>    "Item",
    :move     =>    "Move",
    :escape   =>    "Escape",
  }
  
  
end
