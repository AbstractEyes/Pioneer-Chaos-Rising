class String
  def each_char
    self.split("").each { |i| yield i }
  end
end

module PHI
  module ENTITY_DATA
    ENTITIES = {}

    def self.convert_type(str_in)
      out_val = str_in
      str_in.each_char do |char|
        if char == '['
          eval('out_val = ' + str_in)
          break
        elsif char =~ /[0-9]/
          out_val = str_in.to_i
          break
        elsif char =~ /[a-zA-Z]/
          if str_in[0...5] == 'false' or str_in[0...4] == 'true'
            out_val = str_in.to_bool
            break
          else
            out_val = str_in
            break
          end
        end
      end
      return out_val
    end

  end
end