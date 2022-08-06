class Actor_Index_Node
  attr_accessor :id
  attr_accessor :index1
  attr_accessor :index2
  attr_accessor :index3
  attr_accessor :tree
  attr_accessor :macro_index

  def initialize(actor_id)
    @id = actor_id
    @index1 = 0
    @index2 = 0
    @index3 = 0
    @tree = 0
    @macro_index = 0
  end

end

class Game_Index

  def initialize
    initialize_actors
    initialize_book
  end

  def initialize_actors
    @actor_id = 0
    @actors = []
    (0...$data_actors.size).each { |n| @actors.push Actor_Index_Node.new(n) }
    @actors.sort!{|a,b| a.id <=> b.id }
  end

  def initialize_book
    @book_index = 0
  end

  def book
    return @book_index
  end

  def book=(val)
    @book_index = val
  end

  def dex
    return @actors[@actor_id]
  end

  def bind(actor_id)
    @actor_id = actor_id
  end

  def index1
    return dex.index1
  end

  def index2
    return dex.index2
  end

  def index3
    return dex.index3
  end

  def tree
    return dex.tree
  end

  def index1=(index)
    dex.index1 = index
  end

  def index2=(index)
    dex.index2 = index
  end

  def index3=(index)
    dex.index3 = index
  end

  def tree=(index)
    dex.tree = index
  end

  def macro_index=(index)
    dex.macro_index = index
  end

  def macro_index
    return dex.macro_index
  end

end