module PHI
  module SKILL_DATA
      SKILLS[:item][:Curative][0] = Hash.deep_clone(SKILLS[:template][0])
        bind(:item, :Curative,0)
         set(:animation_on_hit, "1")
         set(:animation_on_use, "1")
       unbind
      SKILLS[:item][:Destructive][0] = Hash.deep_clone(SKILLS[:template][0])
        bind(:item, :Destructive,0)
         set(:animation_on_hit, "1")
         set(:animation_on_use, "1")
       unbind
      SKILLS[:item][:Ammos][0] = Hash.deep_clone(SKILLS[:template][0])
        bind(:item, :Ammos,0)
         set(:animation_on_hit, "1")
         set(:animation_on_use, "1")
       unbind
  end
end
