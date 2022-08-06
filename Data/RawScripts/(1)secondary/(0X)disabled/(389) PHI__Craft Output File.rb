class Game_Party < Game_Unit
  
  def deposit_items_into_files
    
    item_file = File.open("System/zitems.txt", 'w')
    for item in $data_items
      item_file.write("#{item.id} #{item.name}\n") if item != nil
    end
    item_file.close
    weapon_file = File.open("System/zweapons.txt", 'w')
    for item in $data_weapons
      weapon_file.write("#{item.id} #{item.name}\n") if item != nil
    end
    weapon_file.close
    armor_file = File.open("System/zarmor.txt", 'w')
    for item in $data_armors
      armor_file.write("#{item.id} #{item.name}\n") if item != nil
    end
    armor_file.close
    
  end
  
end