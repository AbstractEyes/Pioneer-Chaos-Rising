#==============================================================================
# ** Sound
#------------------------------------------------------------------------------
#  This module plays sound effects. It obtains sound effects specified in the
# database from $data_system, and plays them.
#==============================================================================

module Sound
  # Cursor
  def self.play_cursor
    #p $data_system.sounds.inspect
    $data_system.sounds[0].play
  end

  # Decision
  def self.play_decision
    $data_system.sounds[1].play
  end

  # Cancel
  def self.play_cancel
    $data_system.sounds[2].play
  end

  # Buzzer
  def self.play_buzzer
    $data_system.sounds[3].play
  end

  # Equip
  def self.play_equip
    $data_system.sounds[4].play
  end

  # Save
  def self.play_save
    $data_system.sounds[5].play
  end

  # Load
  def self.play_load
    $data_system.sounds[6].play
  end

  # Battle Start
  def self.play_battle_start
    $data_system.sounds[7].play
  end

  # Escape
  def self.play_escape
    $data_system.sounds[8].play
  end

  # Enemy Attack
  def self.play_enemy_attack
    $data_system.sounds[9].play
  end

  # Enemy Damage
  def self.play_enemy_damage
    $data_system.sounds[10].play
  end

  # Enemy Collapse
  def self.play_enemy_collapse
    $data_system.sounds[11].play
  end

  # Actor Damage
  def self.play_actor_damage
    $data_system.sounds[12].play
  end

  # Actor Collapse
  def self.play_actor_collapse
    $data_system.sounds[13].play
  end

  # Recovery
  def self.play_recovery
    $data_system.sounds[14].play
  end

  # Miss
  def self.play_miss
    $data_system.sounds[15].play
  end

  # Evasion
  def self.play_evasion
    $data_system.sounds[16].play
  end

  # Shop
  def self.play_shop
    $data_system.sounds[17].play
  end

  # Use Item
  def self.play_use_item
    $data_system.sounds[18].play
  end

  # Use Skill
  def self.play_use_skill
    $data_system.sounds[19].play
  end

  def self.flip_page_1
    $data_system.sounds[20].play
  end

  def self.flip_page_2
    $data_system.sounds[21].play
  end

  def self.open_book
    $data_system.sounds[22].play
  end

  def self.close_book
    $data_system.sounds[23].play
  end
=begin
  # Cursor
  def self.play_cursor
    p $data_system.sounds.inspect
    play_sound(0)
  end

  # Decision
  def self.play_decision
    play_sound(1)
  end

  # Cancel
  def self.play_cancel
    play_sound(2)
  end

  # Buzzer
  def self.play_buzzer
    play_sound(3)
  end

  # Equip
  def self.play_equip
    play_sound(4)
  end

  # Save
  def self.play_save
    play_sound(5)
  end

  # Load
  def self.play_load
    play_sound(6)
  end

  # Battle Start
  def self.play_battle_start
    play_sound(7)
  end

  # Escape
  def self.play_escape
    play_sound(8)
  end

  # Enemy Attack
  def self.play_enemy_attack
    play_sound(9)
  end

  # Enemy Damage
  def self.play_enemy_damage
    play_sound(10)
  end

  # Enemy Collapse
  def self.play_enemy_collapse
    play_sound(11)
  end

  # Actor Damage
  def self.play_actor_damage
    play_sound(12)
  end

  # Actor Collapse
  def self.play_actor_collapse
    play_sound(13)
  end

  # Recovery
  def self.play_recovery
    play_sound(14)
  end

  # Miss
  def self.play_miss
    play_sound(15)
  end

  # Evasion
  def self.play_evasion
    play_sound(16)
  end

  # Shop
  def self.play_shop
    play_sound(17)
  end

  # Use Item
  def self.play_use_item
    play_sound(18)
  end

  # Use Skill
  def self.play_use_skill
    play_sound(19)
  end

  def self.flip_page_1
    play_sound(20)
  end

  def self.flip_page_2
    play_sound(21)
  end

  def self.open_book
    play_sound(22)
  end

  def self.close_book
    play_sound(23)
  end
=end

  def self.play_sound(position)
    sound = $data_system.sounds[position]
    Audio[sound.name].play('Audio/SE/'+ sound.name, sound.volume, sound.pitch)
  end

  def self.create_sounds
    $data_system.sounds.push RPG::SE.new('Book2.mp3', 50, 150)
    $data_system.sounds.push RPG::SE.new('Book2.mp3', 50, 75)
    $data_system.sounds.push RPG::SE.new('Book_Open.mp3', 100, 100)
    $data_system.sounds.push RPG::SE.new('Book_Close.mp3', 100, 100)
  end

end
