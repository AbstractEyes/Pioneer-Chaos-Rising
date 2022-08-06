=begin
class Airship_Window < Window_Selectable
  
  def initialize(x,y,width,height)
    super(x,y,width,height)
    initialize_list
    self.index = 0
    @column_max = 1
    refresh
  end
  
  
  def region(index)
    return nil if @(0)options == nil
    return nil if @(0)options.empty?
    return @(0)options[index]
  end
  
  def refresh
    return if @(0)options == nil
    return if @(0)options.empty?
    self.contents.clear
    @item_max = @(0)options.size
    create_contents
    for i in 0...@item_max
      option = @(0)options[i]
      rect = item_rect(i)
      self.contents.draw_text(rect,"#{@(0)options[i].name}")
    end
  end
  
  def initialize_list
    @(0)options = []
    @list = PHI.region_list
    for item in @list
      if $game_variables[601+item.id] > 0 or item.name == "Exit"
        @(0)options.push item
      end
    end
    return if @(0)options == nil
    return if @(0)options.empty?
    @(0)options.sort! { |a,b| a.id <=> b.id }
  end
  
end

class Airship_Help < Window_Base
  
  def initialize(x,y,width,height)
    super(x,y,width,height)
  end
  
  def refresh(item)
    @item = item
    self.contents.clear
    return if @item == nil
    return if @item.name == "Exit"
    self.contents.font.size = 24
    @z = 0
    self.contents.draw_text(0,24*@z,width,WLH,"#{@item.name}")
    self.contents.font.size = 20
    @z += 1
    self.contents.draw_text(0,24*@z,width,WLH,"Area Level #{@item.level}")
    @z += 1
    # Draw Description
    self.contents.font.size = 16
    unless @item.description.empty?
      for x in 0...@item.description.size
        self.contents.draw_text(10,24*@z,width,WLH,"#{@item.description[x]}")
        @z += 1
      end
    end
    self.contents.font.size = 20
    self.contents.draw_text(0,24*@z,width,WLH,"Possible Bosses:")
    # Draw Bosses
    @z += 1
    unless @item.bosses.empty?
      bosses_size = @item.bosses.size
      for x in 0...bosses_size
        # Boss Name
        self.contents.font.color = knockout_color
        self.contents.draw_text(10,24*@z,width,WLH,"Boss: #{@item.bosses[x][0]}")
        @z += 1
        # Boss level
        self.contents.font.color = Color.new(100,250,100,255)
        self.contents.draw_text(10,24*@z,width,WLH,"Boss Level: #{@item.bosses[x][1]}")
        @z += 1
        # Boss details
        self.contents.font.color = normal_color
        self.contents.draw_text(10,24*@z,width,WLH,"#{@item.bosses[x][2]}")
        @z += 1
      end
    else
      @z += 1
      self.contents.draw_text(10,24*@z,width,WLH,"No Bosses Present")
    end
    # Draw Requirements
    unless @item.requirements.empty?
      self.contents.draw_text(10,24*@z,width,WLH,"Requirements:")
      @z += 1
      req_size = @item.requirements.size
      for x in 0...@item.requirements.size
        @z += 1
        self.contents.draw_text(10,24*@z,width,WLH,"#{@item.requirements[x][0]}")
      end
    end
    # Draw Changes
    self.contents.font.size = 16
    unless @item.area_changes.empty?
      for x in 0...@item.area_changes.size
        @z += 1
        self.contents.draw_text(10,24*@z,width,WLH,"#{@item.area_changes[x]}")
      end
    end
  end
  
end

class Airship_Confirm < Window_Selectable
  
  def initialize(x,y,width,height)
    super(x,y,width,height)
    self.index = 0
    refresh
  end
  
  def refresh
    @list = ["Confirm", "Nevermind"]
    @item_max = @list.size
    create_contents
    for i in 0...@item_max
      rect = item_rect(i)
      self.contents.draw_text(rect,@list[i])
    end
  end
  
end
=end