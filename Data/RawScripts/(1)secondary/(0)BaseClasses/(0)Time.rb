class Time

  def self.lock(input_class)
    @locked_time = self.to_ms
    p 'locking time at ' + @locked_time.to_s + ' for class ' + input_class.class.to_s
  end

  def self.to_ms
    (self.now.to_f * 1000.0).to_i
  end

  def self.finish
    p 'finishing time at ' + self.to_ms.to_s + ' difference ' + self.time_diff_milli(@locked_time, self.to_ms).to_s + 'ms'
  end

  def self.time_diff_milli(start, finish)
    (finish - start) #* 1000.0
  end
end

class Window_Base < Window

  def wait_frame(frames)
    @wait_frame = frames
  end

  alias n_update update
  def update
    @wait_frame = 0 if @wait_frame.nil?
    return @wait_frame -= 1 if @wait_frame > 0
    n_update
  end
end

class Sprite

  def wait_frame(frames)
    @wait_frame = frames
  end

  alias n_update update
  def update
    @wait_frame = 0 if @wait_frame.nil?
    return @wait_frame -= 1 if @wait_frame > 0
    n_update
  end
end