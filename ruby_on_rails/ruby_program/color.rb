class Color
    def initialize(name)
        @name = name
    end

    attr_reader(:name)

    def hash
        name.hash
    end

    def eql?(other) 
        # name.eql?(other.name)
        name == other.name
    end
end

hash = {Color.new("pink") => "like", Color.new("pink") => "love"}
p hash
# p Color.new("pink").hash
# p Color.new("pink").hash