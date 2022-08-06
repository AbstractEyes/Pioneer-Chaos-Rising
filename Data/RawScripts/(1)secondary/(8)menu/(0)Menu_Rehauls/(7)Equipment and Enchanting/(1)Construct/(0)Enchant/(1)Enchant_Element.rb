class Enchant_Element_Select < Window_Base

  def initialize(x,y,w,h)
    super(x,y,w,h)
  end

  def refresh(limiter=nil)
    if limiter.nil?
      #create list of all elements

    else
      #limit elements to list of chaos bound books and counter element
    end
  end

end

class Enchant_Element_Books < Window_Base

  def initialize(x,y,w,h)
    super(x,y,w,h)
  end

  def refresh(books)
    @data = books
    @item_max = books.size
    for i in 0...@item_max

    end
  end



end