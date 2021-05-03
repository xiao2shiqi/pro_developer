# ruby 中的面向对象
---

### 了解 Ruby 的继承是怎么回事 ？
先来看看一段最基本的继承代码：
```ruby
# 定义父类
class Car
    def driver
        p "drive a car!"
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

# output：
# honda: #<Honda:0x00007f92a083fc40>"
# honda_class: Honda"
# honda SuperClass: Car"
# have name methods? true"
```
从以上代码可以看出 Ruby 继承比较简单，Honda 继承 Car 类同时也拥有的 Car.driver 函数的功能，继承模型就类似一张单向链表，如下图所示：
![MIZOkt](https://pcloud-1258173945.cos.ap-guangzhou.myqcloud.com/uPic/MIZOkt.png)

当调用 honda.driver 因为它自身没有 method 所以该类会逐级向上查询 `driver` 方法，driver 可以在 Car 找到，所以会正确返回 "drive a car!"
假设该类无法向上无法找到方法 driver，那么最终就会调用到 Kernel 模块中的 `method_missing` 方法，该方法默认抛出一个异常。

下面我们看看 `include` 是如何影响 Ruby 的继承体系的
