module PHI
  module Sprite_Data
    #PHI::Sprite_Data.get_data(@character_name)

    # Contains the individual frames for each animation
    # Todo: Changes to this object will allocated automatically on load time for optimization purposes.
    FRAME_DATA_TEMPLATE = {
        :move_down          => [0, 0,  7,  8],
        :move_left          => [0, 1,  7,  8],
        :move_right         => [0, 2,  7,  8],
        :move_up            => [0, 3,  7,  8],
        :bat_move_left      => [7, 0,  7,  8],
        :bat_move_right     => [7, 1,  7,  8],
        :bat_move_up        => [7, 2,  7,  8],
        :bat_move_down      => [7, 3,  7,  8],
        :dialog_left        => [0, 4,  5,  8],
        :dialog_right       => [0, 5,  5,  8],
        :dead               => [5, 4,  4,  8],
        :victory            => [5, 5,  4,  8],
        :hide_weapons       => [9, 4,  5,  8],
        :show_weapons       => [9, 5,  5,  8],
        :idle_stance        => [0, 6,  7,  8],
        :idle_ani           => [0, 7,  7,  8],
        :bat_idle_stance    => [7, 6,  7,  8],
        :defend             => [7, 7,  7,  8],
        :use_item           => [0, 14, 7, 8],
        :gather_item        => [7, 16, 7, 8],
        :mine               => [7, 14, 7, 8],
        :fish               => [7, 15, 7, 8],
        :disassemble        => [0, 16, 7, 8],
        :alchemize          => [0, 15, 7, 8],
        :hitstun            => [0, 8,  7,  8],
        :dodge              => [7, 8,  7,  8],
        :interrupted        => [7, 9,  7,  8],
        :channel            => [0, 9,  7,  8],
        :skill1             => [0, 10, 7, 8],
        :skill2             => [0, 11, 7, 8],
        :skill3             => [0, 12, 7, 8],
        :skill4             => [0, 13, 7, 8],
        :skill5             => [7, 10, 7, 8],
        :skill6             => [7, 11, 7, 8],
        :skill7             => [7, 12, 7, 8],
        :skill8             => [7, 13, 7, 8],
    }

    KEY_LIST = [:x, :y, :frames, :wait]

    OVERWRITE_DATA = {
        :char_name     => {
            :overwrite_key => {
                :x => 0,
                :y => 0,
                :wait => 5,
                :frames => 10
            }
        },
        :Garet        => {
            :move_left => {
                :frames  => 4,
            },
            :move_right => {
                :frames => 4,
            },
            :move_up => {
                :frames => 4,
            },
            :move_down => {
                :frames => 4,
            },
        },
        #:Maximus        => {
        #    :move_left => {
        #        :frames  => 4,
        #    },
        #    :move_right => {
        #        :frames => 4,
        #    },
        #    :move_up => {
        #        :frames => 4,
        #    },
        #    :move_down => {
        #        :frames => 4,
        #    },
        #}
    }

    def self.get_data(filename=nil)
      return Battle_Sprite_Data.new(filename.clone)
    end

    class Sprite_Data_Chunk
      attr_accessor :x
      attr_accessor :y
      attr_accessor :frames
      attr_accessor :wait
      def initialize(arry_in)
        self.x = arry_in[0]
        self.y = arry_in[1]
        self.frames = arry_in[2]
        self.wait  = arry_in[3]
      end
      def filter(key)
        return self.x if key == :x
        return self.y if key == :y
        return self.frames if key == :frames
        return self.wait if key == :wait
        return 0
      end
      def set_filtered(key, val)
        self.x      = val if key == :x
        self.y      = val if key == :y
        self.frames = val if key == :frames
        self.wait   = val if key == :wait
      end
    end

    class Battle_Sprite_Data < Hash
      def initialize(fn_in)
        filekey = chop_to_key(fn_in.clone)
        if special?(fn_in)
          p filekey.inspect
          for i in 0...FRAME_DATA_TEMPLATE.keys.size
            actionkey = FRAME_DATA_TEMPLATE.keys[i]
            vals = Sprite_Data_Chunk.new(FRAME_DATA_TEMPLATE[actionkey])
            KEY_LIST.each {|propertykey|
              if has_overwritten_property?(filekey, actionkey, propertykey)
                vals.set_filtered(propertykey, OVERWRITE_DATA[filekey][actionkey][propertykey])
              end
            }
            self[actionkey] = vals
          end
        else
          return FRAME_DATA_TEMPLATE
        end
      end

      def chop_to_key(filename)
        return nil if filename.nil? or filename.empty?
        return filename.delete('~').to_sym
      end

      def special?(fn_in)
        return fn_in.include?('~')
      end

      def has_overwritten_property?(filekey, actionkey, propertykey)
        return false unless OVERWRITE_DATA.keys.include?(filekey)
        return false unless OVERWRITE_DATA[filekey].keys.include?(actionkey)
        return false unless OVERWRITE_DATA[filekey][actionkey].keys.include?(propertykey)
        return !OVERWRITE_DATA[filekey][actionkey][propertykey].nil?
      end

      def get_property(filekey, propertykey)
        return OVERWRITE_DATA[filekey, propertykey]
      end

    end


  end
end