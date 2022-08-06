=begin
  Quest:
    name = name_string

    description = multi line string, separated by /n tags

	rewards = array of arrays
		markers: [:markers, amount_int]
		globs: [:type, amount_int]
		item: [:item, id, amount]

	requirements = array of arrays
		markers: [:markers, amount_int]
		globs: [:type, amount_int]
		item: [:item, id, amount]
		quest: [:quest, id, complete_bool]

	cost = amount_int
    Currency charged to undertake the quest.

	area = field_sym
    The field symbol to display the proper strings and graphics.

	level = level_int
    Required level to start quest.

=end

module PHI
  module PIONEER_BOOK
    class Quest
      attr_accessor :name
      attr_accessor :description
      attr_accessor :post_description
      attr_accessor :rewards
      attr_accessor :requirements
      attr_accessor :cost
      attr_accessor :area
      attr_accessor :level
      attr_accessor :hotspot_list
      def initialize(name,
                     level,
                     desc,
                     post_desc = '',
                     rewards = [],
                     requirements = [],
                     cost = 0,
                     area = nil)
        self.name = name; self.rewards = rewards; self.description = desc; self.post_description=post_desc;
        self.requirements = requirements; self.cost = cost; self.area = area;  self.level = level;
      end
    end
    AREA_DATA = {
        #   => [name, small_icon_id, large_picture_location, description, area_ids]
        -1  => ['error', 0, '', ''],
        0   => ['Sunder Flats', 35, '',
                'These flats were once an underwater region. \n' +
                    'Ever since a nearby massive ember reactor explosion,\n' +
                    'the entire area has been blighted.\n' +
                    'Caution is in order.'
        ],
    }
    QUEST_DATA = {
        #name, level, desc, post_desc, rewards, requirements, cost, area
        0 => Quest.new(
            'Test',
            '1-3',
            'This is a test quest, and the quest \n' +
                'itself actually does nothing.',
            'This is a completed test quest information \n' +
            'posted only as a followup after completion.',
            [[:markers, 25]],
            [[:markers, 1000]],
            350,
            :sunder_flats
        )
    }
  end
end

class Pioneer_Book
  attr_reader :finished
  attr_reader :quest_id

  def initialize
    @quest_id = -1
    @finished = []
  end

  def areas
    return PHI::PIONEER_BOOK::AREA_DATA
  end
  def list
    return PHI::PIONEER_BOOK::QUEST_DATA
  end

  def quest
    return nil if @quest_id == -1
    return list[@quest_id]
  end

  def cancel_quest
    @quest_id = -1
  end

  def finish_quest(id)
    cancel_quest
    @quest_id = id
    @finished.push(id) unless @finished.include?(id)
  end

  def start_quest(id)
    @quest_id = id
  end

end