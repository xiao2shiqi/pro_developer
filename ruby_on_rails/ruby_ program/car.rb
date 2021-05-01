# 定义父类
class Car
    def driver
        p "open the car"
    end
end

# 定义子类
class Honda < Car
end

honda = Honda.new
p "honda: #{honda}" 
p "honda_class: #{honda.class}"
p "honda SuperClass: #{Honda.superclass}"
p "have name methods? #{honda.respond_to?(:driver)}"