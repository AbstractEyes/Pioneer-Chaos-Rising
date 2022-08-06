=begin
(str,agi,int,def)
<stat (+-*/)value(%)>
<drop id min_amt max_amt freq>
<(element_res/element_dam) id (+-)value>
<(state_res/state_dam) id (+-)value>
=end

module PHI
  module ENEMY
    NOTES = %w(str def int agi hp mp stam cri exp ele_res ele_dam state_res state_dam level drop)

    OLD_ELEMENT_RANKS = [0, 200, 150, 100, 50, 0, -100]
    ELEMENT_RANKS = [0, 200, 150, 100, 50, 25, 0]
  end
end

module RPG
  class Enemy
    attr_accessor :param_list
    attr_accessor :damage
    attr_accessor :hp
    attr_accessor :mp
    attr_accessor :stats
    #Weapons + Armors
    attr_accessor :level
    attr_accessor :drops

    def setup_list_for_self
      prepare_params
      prepare_notes
      process_param_list
    end

    def prepare_params
      @param_list = {}
      @level = 1
      @damage = 0
      self.drops = [self.drop_item1, self.drop_item2]
      self.stats = StatContainer.new
    end

    def hp
      @hp + get_stat(:hp)
    end
    def hp=(val)
      @hp = val
    end
    def mp
      @mp + get_stat(:mp)
    end
    def mp=(val)
      @mp = val
    end
    def atk
      @atk + get_stat(:str)
    end
    def atk=(val)
      @atk=val
    end
    def spi
      @spi + get_stat(:int)
    end
    def spi=(val)
      @spi = val
    end
    def agi
      @agi + get_stat(:agi)
    end
    def agi=(val)
      @agi = val
    end
    def def
      @def + get_stat(:def)
    end
    def def=(val)
      @def = val
    end
    def cri
      get_stat(:cri)
    end
    def ele_res(id)
      get_ele(:ele_res, id)
    end
    def ele_dam(id)
      get_ele(:ele_dam, id)
    end
    def sta_res(id)
      get_stat(:sta_res)
    end
    def get_drops
      self.drops
    end

    def get_stat(key)
      return 0 unless self.stats.keys.include?(key)
      return self.stats[key].calculate(self.level).to_i
    end
    def get_ele(key, id)
      return self.stats[key][id]
    end

    def prepare_notes
      # Splits the possible note params into keys and sequences them.
      PHI::ENEMY::NOTES.each do |note|
        note_sym = note.to_sym
        @param_list[note_sym] = [] unless @param_list.keys.include? note_sym
        # Splits the current line
        self.note.split(/[\r\n]/).each do |baseline|
          next unless baseline.include?(note_sym.to_s)
          # Deletes and records the main paremeters.
          line = baseline.delete('<')
          line = line.delete('>')
          raw = get_modifier(line)
          modifier, line = raw[0], raw[1]
          raw = get_percent(line)
          percent, line = raw[0], raw[1]
          modifier = '+' if modifier.nil?
          line = line.delete(':')
          @param_list[note_sym].push [percent, modifier] + line.split(' ')[1..line.split(' ').size]
        end
      end
    end

    def get_percent(line)
      if line.include?("%")
        percent = true
        line = line.delete("%")
      else
        percent = false
      end
      return [percent, line]
    end

    def get_modifier(line)
      modifier = nil
      if line.include?("+")
        modifier = "+"
        line = line.delete("+")
      end
      if line.include?("-")
        modifier = "-"
        line = line.delete("-")
      end
      if line.include?("*")
        modifier = "*"
        line = line.delete("*")
      end
      if line.include?("/")
        modifier = "/"
        line = line.delete("/")
      end
      modifier = "+" if modifier.nil?
      return [modifier, line]
    end

    def process_param_list
      #p @param_list.inspect
      for key in @param_list.keys
        data_node = @param_list[key]
        #p key.to_s
        next if data_node.empty?
        case key.to_s
          when 'str', 'def', 'int', 'agi', 'hp', 'mp', 'stam', 'cri'
            for chg in data_node
              if chg[1] == '-'
                chg[2] = -(chg[2].to_i)
              end
              if !chg[0]
                self.stats[key].value.push chg[2].to_i
              else
                self.stats[key].mods.push chg[2].to_i
              end
            end
          when 'ele_res', 'ele_dam', 'state_res', 'state_dam'
            for chg in data_node
              if chg[1] == '-'
                chg[2] = -(chg[2].to_i)
              end
              if chg[0]
                self.stats[key][chg[2].to_i] += chg[3].to_i
              else
                self.stats[key][chg[2].to_i] += chg[3].to_i
              end
            end
          when 'exp'
            for chg in data_node
              self.exp += chg[2].to_i
            end
          when 'level'
            for chg in data_node
              self.level += chg[2].to_i
            end
          when 'damage'
            for n in data_node
              @damage += n[2].to_i
            end
          when 'drop'
            for n in data_node
              self.drops.push [n[2].to_i, n[3].to_i, n[4].to_i, n[5].to_i]
            end
          else
            next
        end
      end
    end

  end
end