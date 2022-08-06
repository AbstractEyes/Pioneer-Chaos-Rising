class String
  def to_bool
    return true if self == true || self =~ (/^(true|t|yes|y|1)$/i)
    return false if self == false || self.empty? || self =~ (/^(false|f|no|n|0)$/i)
    raise ArgumentError.new("invalid value for Boolean: \"#{self}\"")
  end
end

class String
  def each_char
    self.split("").each { |i| yield i }
  end
end

class Fixnum
  def to_bool
    return true if self == 1
    return false if self == 0
    raise ArgumentError.new("invalid value for Boolean: \"#{self}\"")
  end
end

class TrueClass
  def to_i; 1; end
  def to_bool; self; end
end

class FalseClass
  def to_i; 0; end
  def to_bool; self; end
end

class NilClass
  def to_bool; false; end
end

class Hash
  def self.deep_clone(o)
    Marshal.load(Marshal.dump(o))
  end
  def self.pump(hash, tabs=0)
    tab_str = ''
    (0...tabs).each {|t|; tab_str += '  '; }
    for key in hash.keys
      if hash[key].is_a?(Hash)
        p tab_str + key.inspect
        pump(hash[key], tabs+1)
      else
        p tab_str + key.inspect + ' ' + hash[key].inspect
      end
    end
  end
end
