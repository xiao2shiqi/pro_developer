# Ruby 中的面向对象
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
##### 结论
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

##### 结论
* 在同名方法中使用 super 可以帮你调用父类的同名方法
* 当父类中没有子类 super 同名方法时，会抛出 NoMethodError 异常

### 利用 super 复用父类的 initialize 方法
在 Ruby 中类的初始化工作都是通过 `initialize` 来完成的，但如果是继承关系，那么父类和子类都会有各自的 initialize 方法，如果子类在构建的时候想复用父类的初始化函数，那么显然是行不通了，代码如下：
```ruby
class Parent
    attr_accessor(:name)

    # 父类的构造逻辑
    def initialize
        @name = "Howard"
    end
end

class Child < Parent
    attr_accessor(:grade)

    # 子类有自己的实例变量和构造逻辑
    def initialize
        @grade = 8
    end
end

p Parent.new        # #<Parent:0x00007fe83603a518 @name="Howard">
child = Child.new   # #<Child:0x00007fe83603a0e0 @grade=8>
p child
p child.name    # name = nil
```
天哪，**child.name 竟然为 nill**，父类 Parent 经常没有把自己的构造逻辑传给 Child，原因是因为子类在实现 Child.initialize 方法时实际上已经把父类的 Parent.initialize 方法给覆盖了，这种情况我们可以使用 `super` 关键字来让 Child 复用父类的 initialize 逻辑，代码如下：
```ruby
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
```
可以看到上面子类 Chlid 对象调用 `child.name` 可以正确获取父类的 `name` 属性。
结论：
* 使用继承无法复用父类的 initialize 方法
* 在子类的 initialize 使用 super 可以复用父类的 initialize 构造方法

### 使用 Struct 存储结构化数据
`Hash` 可以说是最常用的数据结构，它的优点是非常灵活，缺点是可读性差，你必须对 `Hash` 内部的结构非常清楚，你才方便的去操作它，可以参考示例代码：
```ruby
class AnnualWeather
  # 模拟外部文件
  Csv = [{date: '2020-01', high: 31.3, low: 25.1}, {date: '2020-02', high: 32.3, low: 26.1}, {date: '2020-03', high: 33.3, low: 27.1}]

  def initialize  
    @readings = []
    # 从 Csv 中装载初始化数据
    Csv.each { |e|  
      @readings.append({:date => e[:date], :high => e[:high], :low => e[:low]}) 
    }
  end
end
```
我们写一个处理天气的类，它可以从外部加载CSV文件，然后存储在本地的 `@readings` 哈希数组中。这段程序很好理解，但是如果我想要扩展它的话就会比较麻烦，例如我想写一个 `mean` 方法计算平均温度，我们为 AnnualWeather 类添加以下代码：
```ruby
  # 计算平均温度
  def mean
    return 0.0 if @readings.size.zero?
    total = @readings.reduce(0.0) do |sum, reading|
      # 我需要知道 reading 的结构，我才方便操作它
      sum + (reading[:high] + reading[:low]) / 2.0
    end
    # 算出平均温度
    total / @readings.size.to_f
  end
```

代码很简单，但是会遇到问题，如果我不是 `initialize` 函数的代码作者，那么我在编写 `mean` 函数会异常困难，因为我不清楚 `@readings` 内部是如何加载数据的，我不得不去读完 `initialize` 函数的代码，我才知道 `@readings` 内部有哪些 `Key` 和 `Value`，搞清楚这些后我才能使用它。

使用 `Struct` 代替 `Hash` 可以使我们程序表达的意图更加清晰，修改后的代码如下：
```ruby
class AnnualWeather
  # 模拟外部文件
  Csv = [{date: '2020-01', high: 31.3, low: 25.1}, {date: '2020-02', high: 32.3, low: 26.1}, {date: '2020-03', high: 33.3, low: 27.1}]

  # 定义 strcut 存储结构化对象
  Reading = Struct.new(:date, :high, :low) do
    # 对象方法 mean
    def mean 
      (high + low) / 2.0
    end
  end

  def initialize  
    @readings = []
    Csv.each { |e| 
      # 将 Csv 数据构造为 struct 对象
      reading = Reading.new(e[:date], e[:high], e[:low])
      @readings.append(reading) 
    }
  end

  # 计算平均温度
  def mean
    return 0.0 if @readings.size.zero?
    # 调用对象方法获取 total 
    total = @readings.reduce(0.0) {|sum, reading| sum + reading.mean }
    total / @readings.size.to_f
  end
end
```
修改后的程序，方法 `mean`，`initialize` 看上去代码意图都清晰很多，`Struct` 可以便捷的封装属性和类方法更加方便使用者调用。因此我们可以得出如下结论：
* 处理结构化的数据，如果 Hash 太灵活，创建 Class 又太重，那么使用 Strcut 处理可能刚刚好
* 使用 Strcut 封装一些类方法可以让代码看上去更简洁和具备封装性

### 使用 module 来创建 namespace
如果想要避免跟顶级的类产生冲突，那么可以使用命名空间来解决类名冲突的问题，module 代码如下：
```ruby
module Notebooks
  class Binding
    def initialize (bookname)
      p bookname
    end
  end
end
```
不过以上的写法不仅会导致大量的缩进，而且还会导致模块不好扩展的问题，Ruby 还支持另一种快捷创建 namespace 的方式：
```ruby
class Notebooks::Binding
    #...
end
```
使用该方式需要小心，要提前在入口处定义 `module` 模块，然后 `Notebooks` 文件才能被顺利加载，否则会出现 NameError 异常。另外在 Ruby 项目结构的约定中，请保持项目结构和命名空间的映射，例如上面代码的 `Notebooks::Binding` 应该对应文件夹 `notebooks/bindings.rb`，从而使项目结构保持清晰。



##### 使用限定顶级常量 `::` 来解决 namespace 冲突问题
当你命名空间和 ruby 内部顶级类冲突的时候，这时你的程序运行可能不如你的预期，例如下面代码：
```ruby
module Cluster
    class Array
        def initialize (n)
            # stack level too deep (SystemStackError)
            @disks = Array.new(n) {|i| "disk#{i}" }
        end
    end
end
```
当我尝试在 Cluster::Array 中调用 Ruby 顶级类 Array 时候，程序误认为是要调用自身，结果导致 `stack level too deep (SystemStackError)` 异常，这时候需要使用限定符 `::` 来解决程序可能出现的歧义问题，限定符的含义是从 Object 为根节点向下寻找，因此限定符的全称是 `Object::Array`，因为 Ruby 支持简写的方法，所以可以省略 Object，简写为 `::Array`

我们使用限定符，修改一下刚才有歧义的程序，再来看看结果：
```ruby
    @disks = ::Array.new(n) {|i| "disk#{i}" }
# ->: #<Cluster::Array:0x00007fbb1281af68 @disks=["disk0", "disk1", "disk2", "disk3", "disk4"]>
```
可以看到程序输出已经符合我们的预期，通过以上程序，关于 Namespace 我们可以得出以下总结：
* 使用 module 来实现命名空间，可以避免和其他库的类名发生冲突
* 从约定上来说，请保证命名空间和目录结构的映射关系
* 当类名出现歧义的时候，使用 `::` 来限定类加载的顺序，比如 `::Array`

### 理解 ruby 相等的不同用法

##### `==` 和 `equal?`
`==` 和 `equal?` 虽然都是比较相等，但是他们却有不同的含义，示例代码：
```ruby
"foo" == "foo"
--> true

"foo".equal?("foo")
--> false
```
要理解以上程序，需要先理解它们的区别：
* `==` 比较的是值相等
* `equal?` 比较的是对象相同（既 obejct_id 相等）

这里的等价跟 Java 是相反的，Java == 比较对象相等，equal 比较值相等

##### `==` 和 `eql?`
上面例子很好理解，但这里就比较抽象了，先看代码：
```ruby
1 == 1.0
=> true
1.eql?(1.0)
=> false
```
`==` 和 `eql?` 虽然都是**值比较**，但是他们都存在也是有原因的，通过示例程序，我们可以得出以下结论：
* `==` 对比值相等，但是会做一些隐式的类型转换
* `eql?` 对比值相等，也会对比类型是否相等


##### Hash 使用 eql? 判断相等
一个 Hash 对象是不允许存在相同的主键（key），例如代码：
```ruby
# 声明一个重复的键，只有最后的键有效
{"pink": "like", "pink": "love"}
 => {:pink=>"love"} 
```
默认情况下 Hash 通过 `==` 进行值匹配（严格来说是调用 object.hash 方法来匹配），如果 key 重复则不会放入 Hash 桶中，这种判断条件对于普通的数据类型没有问题，例如字符，数值等，但是如果 Key 是对象的话，那么判断就会出错了。如下代码：
```ruby
class Color
    def initialize(name)
        @name = name
    end
end

hash = {Color.new("pink") => "like", Color.new("pink") => "love"}
=> {#<Color:0x00007f89620165d8 @name="pink">=>"like", #<Color:0x00007f8962016470 @name="pink">=>"love"}
```
从输出来看，**两个相同的对象**都生成了 `Hash Key`，这似乎不符合我们的预期，我们希望相同的对象都可以被排除掉，不放入 Hash 桶中（类似示例代码）

跟 Java 一样，在 Ruby 中我们想要改变对象默认的等价策略，那么我们需要重写它的 `hash`，`eql?` 方法，因为 Ruby 是根据 `object.hash` 的值来判断对象是否相等，我们在 `Color` 类中尝试添加以下代码：
```ruby
def hash
    # 默认的 hash 返回的是 object_id，修改后相同的 name，则被认定为相同的对象
    name.hash
end

def eql?(other) 
    name == other.name
end

hash = {Color.new("pink") => "like", Color.new("pink") => "love"}
=> {#<Color:0x00007fe38990a550 @name="pink">=>"love"}
# 有兴趣可以打印两个对象 Color.new("pink").hash 的值看看
```
示例程序中可以看出，两个相同对象最终只会生成一个 Key，通过重写 `hash`，`eql?` 方法，程序执行的结果最终符合我们的预期。

思考题：
另外 Ruby 还提供 `===` 操作符，它大多被用在 case..when 语句的默认匹配上，有兴趣的话也可以思考以下 `===` 和以上三种等价操作符(`==`，`eql?`, `equal?`) 的区别

结论：
* `==`：比较两个对象的值，是比较宽松的等价操作符，会进行一些隐式的条件转换
* `eql?`：比较两个对象的值和类型，Hash 冲突不符合预期的时候，可以重写类的 `eql?` 方法
* `equal?`：比较两个对象的引用，既内存地址 `object_id` 的相等性
* `===`：是在 case..when 表达式中使用的等价操作符，具体的区别还需要探索

### 优先使用实例变量
实例变量绑定在单个对象上，是以 `@` 开头命名的变量，
类变量是以 `@@` 开头命名的变量，它们和对象无关，而是绑定在一个类型上并且保持全局唯一。

类变量因为其本身的全局唯一属性，所以常常会被用于实现单例，单例类通常用于配置信息、数据库等对象 <br> 我们通过一个手写的单例程序，先看看类变量有哪些问题：
```ruby
class Singleton
    private_class_method(:new, :dup, :clone)

    def self.instance
        @@single ||= new
    end
end

class Configuration < Singleton
    #....
end

class Database < Singleton
    #...
end

Configuration.instance
=> #<Configuration:0x00007fcc5c0d64b8>
Database.instance
=> #<Configuration:0x00007fcc5c0d64b8>
```
但是上面的程序似乎有些混乱了，Configuration、Database 打印同一个对象了，原因是 `Singleton.instance` 使用类变量 `@@single` 导致第二次调用 instance 获取到上一次的对象，我们将类变量 `@@single` 修改为实例变量即可解决问题：
```ruby
def self.instance
    @single ||= new
end

Configuration.instance
=> #<Configuration:0x00007fa09701d120>
Database.instance
=> #<Database:0x00007fa09701cdb0>
```
通过以上程序证明，实例变量避免子类直接继承父类的类变量关系，提供更好的封装特性，在大多数场景下推荐尽量使用实例变量。

以上的单例示例程序不建议作为参考，因为 Ruby 标准库提供更好的单例实现，如下：
```ruby
require 'singleton'

class Configuration
    include(Singleton)
end

class Database
    include(Singleton)
end
```

关于实例变量的结论如下：
* 实例变量提供更好的封装性，优先实现实例变量，而非类变量
* ruby 标准库 `singleton` 提供很好的单例实现，无需自己实现单例集合


参考资料：
* 《Effectvie Ruby》：https://book.douban.com/subject/26690609/