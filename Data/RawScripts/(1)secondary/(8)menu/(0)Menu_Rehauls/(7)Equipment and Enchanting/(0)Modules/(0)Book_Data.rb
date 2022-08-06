class Game_Party < Game_Unit
  attr_accessor :enchant_books

  alias old_i_a_o initialize unless $@
  def initialize(*args, &block)
    old_i_a_o(*args,&block)
    @enchant_books = {
        :ember => [0, 1],
        :brisk => [0, 1],
        :stone => [0, 1],
        :aer   => [0],
        :light => [3],
    }
  end

  def get_unlocked_books
    out = {}
    @enchant_books.each do |key, positions|
      positions.sort.each do |position|
        PHI::ENCHANTMENT.books[key].each do |book|
          out[key] = [] unless out.keys.include?(key)
          out[key].push book if book.position == position && !out[key].include?(book)
        end
      end
    end
    return out
  end

  def book_unlocked?(key, position)
    return @enchant_books.keys.include?(key) &&
        @enchant_books[key].include?(position)
  end

  def unlock_all_enchant_books
    @enchant_books = {
        :ember => [0, 1, 2, 3],
        :brisk => [0, 1, 2, 3],
        :bolt => [0, 1, 2, 3],
        :flood => [0, 1, 2, 3],
        :stone => [0, 1, 2, 3],
        :aer => [0, 1, 2, 3],
        :light => [0, 1, 2, 3],
        :shadow => [0, 1, 2, 3],
        :chaos => [0, 1, 2, 3]
    }
  end

end
