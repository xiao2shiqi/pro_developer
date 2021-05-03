# ruby 中的面向对象
---

### 了解 Ruby 的继承是怎么回事 ？
##### 简单的继承
先来看看一段简单的继承代码：
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
![ruby_extend](https://pcloud-1258173945.cos.ap-guangzhou.myqcloud.com/uPic/u9FVuY.png)

##### 关于 method_missing

当调用 `honda.driver` 因为它自身没有 method 所以该类会逐级向上查询 `driver` 方法，driver 可以在 Car 找到，所以会正确返回 "drive a car!"
假设该类无法向上无法找到方法 driver，那么最终就会调用到 Kernel 模块中的 `method_missing` 方法，该方法默认抛出一个异常。

##### 搞清楚 include 和继承的关系
下面我们看看 `include` 是如何影响 Ruby 的继承体系的，简单改造上面的代码：
```ruby
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

p "have methods? #{honda.respond_to?(:driver)}"
# out: "have name methods? true"
```
这里可以看到 honda 依然可以调用 driver 函数（父类 Car 已经没有了 driver 函数），原因当你使用 `include` 引入模块时， Ruby 对你类的继承体系加了一些黑魔法，它会把 **Engine模块创建一个单例类，并且让 Car 继承它**，这时候你的类图大概如下：
![include_extend](https://pcloud-1258173945.cos.ap-guangzhou.myqcloud.com/uPic/D22aTK.png)
但是这个单例类是匿名不可见的，所以当你在 Car 类上调用 `superclass` 的时候会跳过他们，依然返回 `Object` 

上述就是 ruby 的简单继承，已经可以足够解决大多的情况了。
##### 回顾要点：
* 当类调用方法时，Ruby 会沿着继承体系向上搜索，直到最起点的 `method_missing` 方法，抛出异常
* 使用 `include` 时 Ruby 会创建单例类，并且插入到继承体系中，因为 Ruby 向上搜索会跳过单例类，所以 `superclass` 会跳过单例类

### 了解 super 的工作原理

使用 super 很简单，它就是从继承体系中的上一层寻找和当前方法同名的方法，以下程序可以证明：
```ruby
class Base
    def m1(x, y)
        p "base: methods: m1  params: #{x} + #{y}"
    end
end

class Derived < Base 
    def m1(x)
        # 调用父类的 m1 方法
        p "derived m1 #{x}"
        super x, "super"
        super x       # wrong number of arguments  super 找不到匹配参数的 m1 方法
    end
end

p Derived.new.m1("console")

# out:
# "derived m1 console"
# "base: methods: m1  params: console + super"
```
上面示范代码是在 Derived m1 方法中使用 `super` 调用父类 Base 中的 m1 方法，从下面的输出可以看出。
值得注意的是这段比较有意思的这段注释代码：
```ruby
super x       # 提示：wrong number of arguments  因为 super 找不到匹配参数的 m1 方法
```
当尝试调用父类 m1 方法但是没有传参的情况下，就会出现 wrong number of arguments 提示

##### super 和 method_missing 的相互作用

当你对继承类的方法不够熟悉的时候，使用 `super` 容易引发 method_mission 错误，我们通过以下示例代码来展示：
```ruby
class Base
end

class Derived < Base 
    def m1(x)
        super
        p "derived m1 #{x}"
    end
end
```
当你尝试在 Derived 类中使用 `super` 的时候，不出意外应该会遇到返回异常
```shell
`m1': super: no superclass method `m1' for #<Derived:0x00007fed7c082b60> (NoMethodError)
```
刚看到这段提示你可能会有点迷茫，因为 Derived 是有 m1 方法的，不过当你了解 super 的工作原理，应该就可以避免

##### 回顾要点
* 在同名方法中使用 super 可以帮你调用父类的同名方法
* 当父类中没有子类 super 同名方法时，会抛出 NoMethodError 异常

### 初始化子类时调用 super 