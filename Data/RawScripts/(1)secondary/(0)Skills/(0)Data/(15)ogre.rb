module PHI
  module SKILL_DATA
      SKILLS[:ogre][:club][0] = Hash.deep_clone(SKILLS[:template][0])
        bind(:ogre, :club,0)
         set(:cast_message, "Eat this club!")
         set(:shove, "[[:away_host, 1, 1]]")
         set(:dam_attr, "[[:str, 100]]")
         set(:raw_dam, "['+25%',]")
         set(:ele_dam, "[['25%', 100, :crush]]")
         set(:sequence, "[:full]")
         set(:animation_on_hit, "1")
         set(:animation_on_use, "1")
       unbind
      SKILLS[:ogre][:head][0] = Hash.deep_clone(SKILLS[:template][0])
        bind(:ogre, :head,0)
         set(:cast_message, "HEADBUMP!")
         set(:dam_attr, "[[:str, 100]]")
         set(:ele_dam, "[['25%', 100, :crush]]")
         set(:animation_on_hit, "1")
         set(:animation_on_use, "1")
       unbind
      SKILLS[:ogre][:rags][0] = Hash.deep_clone(SKILLS[:template][0])
        bind(:ogre, :rags,0)
         set(:cast_message, "Slapping with rags.")
         set(:dam_attr, "[[:str, 290]]")
         set(:ele_dam, "[['25%', 100, :slash]]")
         set(:animation_on_hit, "1")
         set(:animation_on_use, "1")
       unbind
  end
end
