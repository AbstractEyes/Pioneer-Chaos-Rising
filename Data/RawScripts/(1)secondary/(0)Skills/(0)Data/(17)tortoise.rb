module PHI
  module SKILL_DATA
      SKILLS[:tortoise][:snapper][0] = Hash.deep_clone(SKILLS[:template][0])
        bind(:tortoise, :snapper,0)
         set(:animation_on_hit, "1")
         set(:animation_on_use, "1")
       unbind
      SKILLS[:tortoise][:body][0] = Hash.deep_clone(SKILLS[:template][0])
        bind(:tortoise, :body,0)
         set(:animation_on_hit, "1")
         set(:animation_on_use, "1")
       unbind
      SKILLS[:tortoise][:shell][0] = Hash.deep_clone(SKILLS[:template][0])
        bind(:tortoise, :shell,0)
         set(:animation_on_hit, "1")
         set(:animation_on_use, "1")
       unbind
  end
end
