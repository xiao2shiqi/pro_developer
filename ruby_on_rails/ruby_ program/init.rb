class Parent
    attr_accessor(:name)

    # 父类的构造逻辑
    def initialize(name)
        @name = name
    end
end

class Child < Parent
    attr_accessor(:grade)

    # 子类有自己的实例变量和构造逻辑
    def initialize(name, grade)
        super(name)
        @grade = grade
    end
end

child = Child.new("edward", 8)   # #<Child:0x00007fe83603a0e0 @grade=8>
p child             # #<Child:0x00007f965f825e90 @name="edward", @grade=8>
p child.name        # edward