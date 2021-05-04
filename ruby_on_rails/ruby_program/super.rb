class Base
end

class Derived < Base 
    def m1(x)
        super
        p "derived m1 #{x}"
    end
end

p Derived.new.m1("console")