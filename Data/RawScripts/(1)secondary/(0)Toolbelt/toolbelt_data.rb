module TOOL_BELT

  KEYS = [
      :pickaxe,
      :siphon,
      :fishing,
  ]
=begin

      :tool_format => {
          :name => "",
          :id => position_in_array,


      }


=end

private
  @tool_data = {
      :pickaxe => {
          :name => "Pickaxe",

      }
  }

  def self.data
    return @data
  end

  def self.set_data(input_data)
    @data = input_data
  end


end