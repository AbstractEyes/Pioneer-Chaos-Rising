

module PHI
  module ENCHANTMENT


    #PHI::ENCHANTMENT::FRAGMENT_TYPE_DATA
    FRAGMENT_TYPE_DATA = {
        # currency:  :gold :collateral :carbon :metal :elemental :chaotic
        :hp        => ['Health Points',       5  , [[:carbon, 1], [:metal, 1]] ],
        :mp        => ['Enchant Points',      1  , [[:carbon, 1], [:elemental, 1]] ],
        :stamina   => ['Stamina Points',      2  , [[:carbon, 2]] ],
        :atk       => ['Strength',            2  , [[:metal, 3]] ],
        :spi       => ['Intelligence',        2  , [[:elemental, 3]] ],
        :agi       => ['Agility',             2  , [[:carbon, 3]] ],
        :cri       => ['Critical Rate',       1  , [[:carbon, 1], [:metal, 1], [:elemental, 1]] ],
        :cri_mul   => ['Critical Multiplier', 0.2, [[:metal, 3]] ],
        :def       => ['Defense',             2  , [[:carbon, 1], [:metal, 1], [:elemental, 1]] ],
        :all_res   => ['All Resistance',      0.2, [[:chaos, 1]] ],
        :phy_res_i => ['Physical Resistance', 2  , [[:chaos, 1]] ],
        :ele_res_i => ['Elemental Resistance',2  , [[:chaos, 1]] ],
        :sta_res   => ['Status Resistance',   2  , [[:chaos, 1]] ],
        :ele_res   => ['Resistance',          10 , [[:carbon, 1], [:elemental, 3]] ],
        :ele_dam   => ['Damage',              10 , [[:carbon, 1], [:elemental, 3]] ],
        :harvest   => ['Harvest',             5  , [[:metal, 3]] ]
    }

    CONVERTED_FRAGMENT_KEYS = {
        :hp        => :hp,
        :mp        => :mp,
        :stamina   => :sta,
        :atk       => :str,
        :spi       => :int,
        :agi       => :agi,
        :cri       => :crat,
        :cri_mul   => :cmul,
        :def       => :def,
        :all_res   => :ares,
        :phy_res_i => :pres,
        :ele_res_i => :eres,
        :sta_res   => :sres,
        :ele_res   => :res,
        :ele_dam   => :dam,
        :harvest   => :harvest,
    }

=begin
1 :slash
2 :crush
3 :puncture
4 :bullet
5 :energy
6 :blast
7 fire :ember
8 ice :brisk
9 :bolt
10 water :flood
11 :stone
12 air :aer
13 :light
14 dark :shadow
15 :chaos
PHI::ENCHANTMENT::EQUIPMENT_FRAGMENT_TABLE
=end
    def self.call_book(element)
      return EQUIPMENT_FRAGMENT_TABLE[element][:books][:data]
    end

    def self.book_list
      out = {}
      (0...EQUIPMENT_FRAGMENT_TABLE[:ele_key_order].size).each {|element|
        out[elemental_keys[element]] = EQUIPMENT_FRAGMENT_TABLE[EQUIPMENT_FRAGMENT_TABLE[:ele_key_order][element]][:books][:data]
      }
      return out
    end

    def self.flat_book_list
      out = []
      (0...EQUIPMENT_FRAGMENT_TABLE[:ele_key_order].size).each {|element|
        t = EQUIPMENT_FRAGMENT_TABLE[EQUIPMENT_FRAGMENT_TABLE[:ele_key_order][element]][:books][:data]
        for ai in 0...t.size
          for n in 0...t[ai].size
            out.push t[ai][n]
          end
        end
      }
      return out
    end

    def self.elemental_keys
      return EQUIPMENT_FRAGMENT_TABLE[:ele_key_order]
    end

    def self.physical_elements
      return EQUIPMENT_FRAGMENT_TABLE[:phy_elements]
    end

    def self.all_elements
      return self.physical_elements + self.elemental_keys
    end

    def self.negate(ele_sym)
      return EQUIPMENT_FRAGMENT_TABLE[:negation][ele_sym]
    end

    #done: finished data table iteration 1
    #todo: more data for descriptions
    EQUIPMENT_FRAGMENT_TABLE = {
        :ele_key_order =>  [
            :ember,
            :brisk,
            :bolt,
            :flood,
            :stone,
            :aer,
            :light,
            :shadow,
            :chaos
        ],
        :phy_elements => [
            :slash,
            :crush,
            :puncture,
            :bullet,
            :energy,
            :blast
        ],
        :negation => {
            :ember => :aer,
            :brisk => :bolt,
            :bolt => :brisk,
            :flood => :stone,
            :stone => :flood,
            :aer => :ember,
            :light => :shadow,
            :shadow => :light,
            :chaos => :all,
        },
        :ember => {
            :books => {
                :ele_id => 6,
                :size => 4,
                :names => [
                    'Book of Ember',
                    'Lost Ember pages',
                    'Clarity of Fire Novel',
                    'The Path Novel',
                ],
                :data => [
                    [:atk, [:ele_res, 7], [:ele_dam, 7]],
                    [:agi, [:ele_res, 1], [:ele_dam, 1]],
                    [:cri_mul, [:ele_res, 10], [:ele_dam, 10]],
                    [:spi, [:ele_res, 6], [:ele_dam, 6]]
                ],
                :descriptions => ['','','',''],
            },

        },
        :brisk => {
            :books => {
                :ele_id => 7,
                :size => 4,
                :names => [
                    'Book of Brisk',
                    'Lost Brisk pages',
                    'Burning Soul Manifesto',
                    'Frozen Darts of Fire Instruction Manual',
                ],
                :data => [
                    [:spi, [:ele_res, 8], [:ele_dam, 8]],
                    [:cri, [:ele_res, 3], [:ele_dam, 3]],
                    [:atk, [:ele_res, 7], [:ele_dam, 7]],
                    [:def, [:ele_res, 4], [:ele_dam, 4]]
                ],
                :descriptions => ['','','',''],
            },

        },
        :bolt => {
            :books => {
                :ele_id => 8,
                :size => 4,
                :names => [
                    'Book of Bolt',
                    'Lost Bolt pages',
                    'Thundarus scribe',
                    'Tranquil Eyes of Lightning diary',
                ],
                :data => [
                    [:cri, [:ele_res, 9], [:ele_dam, 9]],
                    [:spi, [:ele_res, 4], [:ele_dam, 4]],
                    [:agi, [:ele_res, 12], [:ele_dam, 12]],
                    [:cri_mul, [:ele_res, 3], [:ele_dam, 3]]
                ],
                :descriptions => ['','','',''],
            },

        },
        :flood => {
            :books => {
                :ele_id => 9,
                :size => 4,
                :names => [
                    'Book of Aqua',
                    'Lost Aqua pages',
                    'Thunderstorm tome',
                    'Obliteration scribbles',
                ],
                :data => [
                    [:cri_mul, [:ele_res, 10], [:ele_dam, 10]],
                    [:def, [:ele_res, 5], [:ele_dam, 5]],
                    [:cri, [:ele_res, 9], [:ele_dam, 9]],
                    [:atk, [:ele_res, 2], [:ele_dam, 2]]
                ],
                :descriptions => ['','','',''],
            },

        },
        :stone => {
            :books => {
                :ele_id => 10,
                :size => 4,
                :names => [
                    'Book of Stone',
                    'Lost Stone pages',
                    'Decomposition of Mass Notes',
                    'Eye Full of Truth Tome',
                ],
                :data => [
                    [:def, [:ele_res, 11], [:ele_dam, 11]],
                    [:cri_mul, [:ele_res, 2], [:ele_dam, 2]],
                    [:spi, [:ele_res, 8], [:ele_dam, 8]],
                    [:agi, [:ele_res, 5], [:ele_dam, 5]]
                ],
                :descriptions => ['','','',''],
            },

        },
        :aer => {
            :books => {
                :ele_id => 11,
                :size => 4,
                :names => [
                    'Book of Aer',
                    'Lost Aer pages',
                    'Dust\'s Diary',
                    'Pure Cutlery Book',
                ],
                :data => [
                    [:agi, [:ele_res, 12], [:ele_dam, 12]],
                    [:atk, [:ele_res, 6], [:ele_dam, 6]],
                    [:def, [:ele_res, 11], [:ele_dam, 11]],
                    [:cri, [:ele_res, 1], [:ele_dam, 1]]
                ],
                :descriptions => ['','','',''],
            },

        },
        :light => {
            :books => {
                :ele_id => 12,
                :size => 4,
                :names => [
                    'Book of Light',
                    'Lost Light pages',
                    'Purity Ignite Torn Pages',
                    'Pain of Purity Novel',
                ],
                :data => [
                    [:hp, [:ele_res, 13], [:ele_dam, 13]],
                    [:mp, :all_res, :sta_res],
                    [[:ele_res, 1], [:ele_res, 2], [:ele_res, 3]],
                    [[:ele_res, 4], [:ele_res, 5], [:ele_res, 6]]
                ],
                :descriptions => ['','','',''],
            },

        },
        :shadow => {
            :books => {
                :ele_id => 13,
                :size => 4,
                :names => [
                    'Book of Darkness',
                    'Lost Darkness pages',
                    'Drasto Tales Novel',
                    'Epitome of Eternity Novel',
                ],
                :data => [
                    [:mp, [:ele_res, 14], [:ele_dam, 14]],
                    [:hp, :phy_res_i, :ele_res_i],
                    [[:ele_dam, 1], [:ele_dam, 2], [:ele_dam, 3]],
                    [[:ele_dam, 4], [:ele_dam, 5], [:ele_dam, 6]]
                ],
                :descriptions => ['','','',''],
            },

        },
        :chaos => {
            :books => {
                :ele_id => 14,
                :size => 4,
                :names => [
                    'Book of Chaos',
                    'Lost Chaos pages',
                    'Stanrai\'s Scrolls',
                    'Stanrai\'s Manifesto'
                ],
                :data => [
                    [:hp, :mp, :atk],
                    [:agi, :spi, :def],
                    [:cri, :cri_mul, :all_res],
                    [:phy_res_i, :ele_res_i, :sta_res]
                ],
                :descriptions => ['','','',''],
            },
        }
    }

    public
    def self.books
      return @books
    end

    class Enchant_Book
      attr_accessor :name
      attr_accessor :ele_id
      attr_accessor :base_type
      attr_accessor :description
      attr_accessor :enchantments
      attr_accessor :position
    end

    private
    @books = {}
    for type_i in 0...EQUIPMENT_FRAGMENT_TABLE[:ele_key_order].size
      key = EQUIPMENT_FRAGMENT_TABLE[:ele_key_order][type_i]
      @books[key] = []
      for book_i in 0...EQUIPMENT_FRAGMENT_TABLE[key][:books][:size]
        raw_book = EQUIPMENT_FRAGMENT_TABLE[key][:books]
        book = Enchant_Book.new
        book.name = raw_book[:names][book_i]
        book.base_type = key
        book.position = book_i
        book.description = raw_book[:descriptions][book_i]
        book.ele_id = raw_book[:ele_id]
        book.enchantments = raw_book[:data][book_i]
        @books[key].push(book)
      end
    end

  end
end

