# 定义父类
module Engine
    def driver
        p "open the car"
    end
end

class Car
    include Engine
end

class Honda < Car
end


honda = Honda.new

def honda.driver
    "honda driver"
end

p "honda: #{honda}" 
p "honda_class: #{honda.class}"
p "honda SuperClass: #{Honda.superclass}"
p "honda SuperClass SuperClass: #{Honda.superclass.superclass}"     
p "have methods? #{honda.respond_to?(:driver)}"
p "honda_driver ? #{honda.driver}"