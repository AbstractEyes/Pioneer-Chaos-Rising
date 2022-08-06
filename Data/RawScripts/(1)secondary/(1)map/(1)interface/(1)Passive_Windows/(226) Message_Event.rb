class Message_Event
  attr_accessor :type
  attr_accessor :data
  def initilize(type, data)
    self.type = type
    self.data = data
  end
end