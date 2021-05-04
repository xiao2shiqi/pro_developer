class Color
    attr_reader(:name)

    def initialize(name)
        @name = name
    end

    # def hash
    #     name.hash
    # end

    # def eql?(other) 
    #     name.eql?(other.name)
    # end 
end

a = Color.new("pink")
b = Color.new("pink")

{a => "like", b => "love"}