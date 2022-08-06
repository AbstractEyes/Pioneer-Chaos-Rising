=begin
  *************************************************************************************
  # SKILL SEQUENCE
  *************************************************************************************
       <full>
          performs the standard "animation", "damage", "effects" sequence.
        <use n>
          uses another skill template for the rest of the skill
          potentially infinite skills careful.
        <mult n>
          n = multiplier for the next damage use
          multiplies the damage of the next damage use by this percentage
        <animation n>
          n = animation_id
            If no id, <animation> uses the current animation attached to skill.
          bypasses the rest of the animations for this animation id
        <damage n1 n2>
          n1 = exact_damage
            If no exact damage specified, uses current skill to determine it.
          n2 = damage_type
            If no damage type determined, takes primary damage type of skill template.
          Performs damage, shows numbers, and calculates properly.
        <code ["",...]>
          "" = place code here, evaluates when sequence reaches this point, separate priority with ,""
        <add_ele_dam n1 n2>
          n1 = element type
          n2 = element damage
            Adds element damage to the next attack.
        <add_state_dam n1 n2>
          n1 = state type
          n2 = state damage
            Adds state damage to the next attack.
        <spawn "">
          "" = entity name
            Spawns an entity at the target location.
=end
module PHI
  module SKILL_CONFIG

    NOTES = %w(full use mult animation damage code add_effect remove_effect add_state remove_state spawn timer)

  end
end
=begin
module RPG
  class Skill
    attr_accessor :sequence

    def process_sequence
      @sequence = []
      self.note.split(/[\r\n]/).each do |line|
        next unless contains_tag?(line)
        @sequence.push clip(line)
      end
      @sequence.push 'full' if @sequence.empty?
    end

    def contains_tag?(line)
      PHI::SKILL_CONFIG::NOTES.each do |note_tag|
        return true if line.include?(note_tag)
      end
      return false
    end

    def clip(line)
      line.delete('<')
      line.delete('>')
      return line.split(' ')
    end

  end

end

=end