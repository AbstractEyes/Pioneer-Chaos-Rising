module PHI
  module SKILL_DATA
      SKILLS[:wolf][:teeth][0] = Hash.deep_clone(SKILLS[:template][0])
        bind(:wolf, :teeth,0)
         set(:animation_on_hit, "1")
         set(:animation_on_use, "1")
       unbind
      SKILLS[:wolf][:claws][0] = Hash.deep_clone(SKILLS[:template][0])
        bind(:wolf, :claws,0)
         set(:animation_on_hit, "1")
         set(:animation_on_use, "1")
       unbind
      SKILLS[:wolf][:pelt][0] = Hash.deep_clone(SKILLS[:template][0])
        bind(:wolf, :pelt,0)
         set(:animation_on_hit, "1")
         set(:animation_on_use, "1")
       unbind
  end
end
