module PHI
  module SKILL_DATA
      SKILLS[:skeleton][:weapon41][0] = Hash.deep_clone(SKILLS[:template][0])
        bind(:skeleton, :weapon41,0)
         set(:animation_on_hit, "1")
         set(:animation_on_use, "1")
       unbind
  end
end
