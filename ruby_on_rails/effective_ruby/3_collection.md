# Ruby 中的集合
---
### 改变集合参数前为什么要先克隆 ？
Ruby 多数对象是通过引用而不是值传递。并且任何一个持有对象应用的代码都可以完成对这个对象的修改。尽管 Ruby 中约定使用 `!` 来声明引用对象修改的函数，但多数情况下，别人不希望自己参数在不知情的情况下被改变

随意修改参数会出现什么问题，我们先看看如下代码：
```ruby
# 定义一个调节器
class Tuner
     def initialize (presets)
        @presets = presets
        clean
     end

     private 

     def clean 
        # 清理一些频道
        @presets.delete_if { |f|
            f[-1].to_i.even?
        }
     end
end

presets = %w(90.1, 106.2, 88.5)
=> # ["90.1,", "106.2,", "88.5"]
tuner = Tuner.new(presets)
=> #<Tuner:0x00007f912f0708b0 @presets=["88.5"]>
presets
=> # ["88.5"]
```
可以看到 `presets` 属性的内容被 `@presets.delete_if` 不小心的改变，这样会导致 `presets` 在后续方法的传参中容易发生错误，我们修改以上程序，使用 `reject` 方法替代 `delete_if` 这是因为 `reject` 会返回一个新的数组，修改后代码如下
```ruby
class Tuner
     def initialize (presets)
        @presets = clean(presets)
     end

     private 

     def clean (presets)
        presets.reject {|f| f[-1].to_i.even? }
     end
end

presets = %w(90.1, 106.2, 88.5)
=> # ["90.1,", "106.2,", "88.5"]
tuner = Tuner.new(presets)
=> #<Tuner:0x00007f912f0708b0 @presets=["88.5"]>
presets
=> # ["90.1,", "106.2,", "88.5"]
```
以上程序似乎还不够完美，`reject` 可以解决 clean 的问题，但是无法保证在其他方法中 presets 不会被修改，所以最好的解决方法是直接复制参数，这样才方法中就可以随意操作它了

##### Ruby 的两个复制对象的方法： dup 和 clone
先说说两者的区别：
* clone：会保留对象的冻结状态，就是说 clone 可能会返回一个不可变的对象，适合不需要修改对象的场景
* dup：不会保留对象的冻结状态，适合需要修改对象的场景

我们使用 `dup` 拷贝参来修改一下第一个程序，来解决同样的问题，代码如下：
```ruby
class Tuner
     def initialize (presets)
        @presets = presets.dup
        clean
     end

     private 
     def clean
        @presets.delete_if { |f|
            f[-1].to_i.even?
        }
     end
end

presets = %w(90.1, 106.2, 88.5)
=> # ["90.1,", "106.2,", "88.5"]
tuner = Tuner.new(presets)
=> #<Tuner:0x00007f912f0708b0 @presets=["88.5"]>
presets
=> # ["90.1,", "106.2,", "88.5"]
```
使用 dup 虽然可以复制新的数组引用，可以操作数据的新增和删除，但是对于已经存在的元素并没有复制新的引用，如果对原本存在的数组元素进行修改还是会对原数组产生应用，如下代码可以证明：
```ruby
presets = %w(90.1, 106.2, 80.5)
copy_presets = presets.dup
copy_presets.each {|x| x.sub!("0", "1")}     # change presets!
p presets  # ["91.1,", "116.2,", "81.5"]
```
为什么发生这种情况，我们可以打印它们的 `object_id` 来探一探究竟：
```ruby
presets.each {|p| p p.object_id}   # 60, 80, 100
copy_presets.each {|c| p c.object_id}  # 60, 80, 100
p "presets #{presets.object_id}"  # 120
p "copy_presets #{copy_presets.object_id}"   # 140
```
发现上述原因在于 `dup` 只会拷贝数组本身的引用，并不会拷贝集合类型内的元素引用

如果需要保证集合内元素不被修改，就需要进行**深拷贝**，可以使用 Marshal 类对集合进行深拷贝，使用方式如下：
```ruby
presets = %w(90.1, 106.2, 80.5)
copy_presets = Marshal.load(Marshal.dump(presets))
copy_presets.each {|c| c.sub!('0', '1')}
=> presets  # ["90.1,", "106.2,", "80.5"]
=> copy_presets # ["91.1,", "116.2,", "81.5"]
```
当使用 Marshal 进行深度拷贝的时候需要明白它的副作用在哪里：
1. 使用深度拷贝，创建对象副本的话会消耗额外的内存
2. 有些持有闭包，单例的对象无法被序列化，还有一些 Ruby 核心类在序列化时会抛出 TypeError 异常

不必太过于担心上述的问题，当你知道 Marshal 的局限才能更好的使用它，并且在大多数情况下 `dup` 就够用了

这段写的比较多，我们可以的出以下结论：
* Ruby 中参数都是按引用传递，而不是值传递（所以需要手动拷贝来解决引用修改的问题）
* 在使用参数前，最好先克隆它，避免发生意外的修改
* dup 和 clone 都可以拷贝对象，但是如果要修改拷贝的对象 dup 会更加合适
* 如果要保证集合的元素不被修改，可以使用 Marshal 进行深度拷贝


---
~~### 使用 Array 方法将 nil 对象转成数组 （感觉就是 Array 方法的使用而已）~~

### 使用 Set 高效的对程序进行检查

我们经常喜欢使用 `include?` 来判断元素是否存在数组中，在少量数据的情况下是没有问题的，但是数据量比较大的情况下就不建议使用了，因为 `include?` 是基于数组搜索，时间复杂度是线性的  `O(n)` ，而且当数据持续增加性能会越来越低，我们先看一段使用 `include?` 的代码：
```ruby
class Role

  # 初始化角色权限
  def initialize(name, permissions)
      @name, @permissions = name, permissions
  end

  # 权限检查
  def can?(permission)
    # TODO 随着权限越来，include? 搜索会越来越慢
    @permissions.include?(permission)
  end
end
```
每次执行 `@permissions.include?(permission)` 搜索数组检查权限，随着数据越多，查询性能会越慢，我们需要引入一种 `O(1)` 查询复杂度的方法，从而保证每次检查权限的性能，应对这种场景，基于 `Hash` 实现的 `Set` 集合就登场了。

我们看看使用 `Set` 改造 Role 类的代码：
```ruby
require 'set'   # set 非核心库，需要额外引入

class Role
  def initialize(name, permissions)
      @name, @permissions = name, Set.new(permissions)
  end

  def can?(permission)
    # 使用 哈希查询，时间复杂度 O(1)
    @permissions.include?(permission)
  end
end
```

以上代码，我们使用 `set` 重构了 Role 类，解决的数组搜索的性能问题，推荐性能敏感场景使用 `set` 替代 `Array` 进行搜索

关于数组的检查我们可以得出以下结论：
* 如果对效率有要求，考虑使用 `Set` 来进行集合元素的检索
* `Set` 是基于 `Hash` 实现的，所以集合是无序的，如果对顺序有要求应该考虑使用 `SorteSet` 类
* `Set` 非核心类库，使用前需要先 `require` 它

---

### 使用 reduce 方法折叠集合
相信大家平时都非常熟悉 Ruby 中的 `map` 和 `select` 还有 `each` 方法了，其实在 `Enumerable` 模块中还有一个更强大的的方法，他不仅具备同时以上几种方法的能力，而且还有更为强大的扩展能力和想象空间，它就是 `reduce` 方法（貌似在 Ruby 1.9 之前称为 `inject` 方法）。

##### 使用 reduce 替代 each 实现数组求和

我们先看一段代码，平时对数组求和，我们通常会用 `each` 方法，代码如下
```ruby
sum = 0
(0..5).each do |e|
  sum += e
end
#=> 15
```

但是使用 `reduce` 也可以达到同样的求和效果，代码如下：
```ruby
(0..5).reduce(0) do |sum, e|
  sum + e
end
#=> 15
```
如果你追求代码简洁的话，甚至可以用一行代码表示求和运算：
```ruby
(0..5).reduce(0, :+)
#=> 15
```

##### 使用 reduce 替代 Hash 将数组转哈希
我们通常会遇到数组转哈希的场景，通常我们会使用构建 `Hash` 对象的方式来处理，代码如下：
```ruby
array = (0..5)
p "array #{array.to_a}"
ary_hash = Hash[
  array.map do |x| 
    [x, true] 
  end
]
p "array map build hash: #{ary_hash}"
#=> "array map build hash: {0=>true, 1=>true, 2=>true, 3=>true, 4=>true, 5=>true}"
```

当然我们也可以使用 `reduce` 来讲一个数组转换为哈希，而且实现方式似乎可以更加的优雅，代码如下：
```ruby
# {} 声明 hash 的初始值，否则 update 没有 update 方法
ary_hash = array.reduce({}) do |hash, element|
  hash.update(element => true)
end
p "array reduce build hash: #{ary_hash}"
#=> "array reduce build hash: {0=>true, 1=>true, 2=>true, 3=>true, 4=>true, 5=>true}"
```

##### 使用 reduce 替代 select 实现对象搜索
假如我们有一个需求，需要将 users 集合中 `age > 21` 的用户挑选出来，通常我们会用 `select` 来实现，其实强大的 `reduce` 也可以实现，我们可以对比一下他们实现的区别：
```ruby
# 使用 Struct 构建 user 对象
user = Struct.new(:name, :age)
users = [user.new("phoenix", 19), user.new("jack", 21), user.new("tom", 23)]


# select 方法实现筛选 age > 21 的对象，并且返回 names 数组
names = users.select {|u| u.age >= 21}.map{|u| u.name}
#=> ["jack", "tom"]

# reduce 方法实现筛选 age > 21 的对象，并且返回 names 数组
names = users.reduce([]) do |names, user|
  names << user.name if user.age >= 21
  names
end
#=> ["jack", "tom"]
```

`reduce` 就介绍到这里，它还有更多的使用场景和更强大的功能需要我们去挖掘，在使用时还需要注意以下两点：
* reduce 总是需要一个初始值，这个初始值就是你最终返回值的类型
* reduce 总是需要声明返回值

---
### 使用 Hash 默认值来避免 NilClass 错误
Hash 应该是最常用的数据结构，因为 Hash 查找不存在的 key 的时候返回的是 `nil`，所以当我们对 Hash 进行运算如果一不小心就容易遇到 `nil:NilClass (NoMethodError)` 异常，例如下面这段统计数组元素出现次数的代码：
```ruby
# 初始化数组
array = [1, 2, 3, 4, 5]

hash_res = array.reduce({}) do |hash, element|
  # 因为 hash[element] 有可能获取 nil
  # 所以在进行 += 1 的时候可能会出现 undefined method `+' for nil:NilClass (NoMethodError)
  hash[element] += 1
  hash
end
#=> undefined method `+' for nil:NilClass (NoMethodError)
```

##### 通过 `||=` 设置默认值
没有默认值，使用 Hash 战战兢兢，随时担心出现 NoMethodError，当然我们也有在运算前通过 `||=` 为不存在的元素进行默认值声明，代码如下：
```ruby
hash_res = array.reduce({}) do |hash, element|
  # 没有默认值，使用 Hash 战战兢兢，随时担心出现 NoMethodError
  # 使用防御式编程： hash[element] ||= 0 来获得安全感
  hash[element] ||= 0
  hash[element] += 1
  hash
end
#=> {1=>1, 2=>1, 3=>1, 4=>1, 5=>1}
```
但是这样写出来的代码，似乎并不优雅，而且 `||=` 容易散落各地不好排查，而且代码也容易重复。因此我们在初始化`Hash.new` 的时候声明默认值，这样 **Hash 在找不到键的时候就会使用默认值**，所以我们在使用 Hash 的时候也会有安全感很多，使用默认值我们可以把以前的代码改造如下：
```ruby
hash_res = array.reduce(Hash.new(0)) do |hash, element|
  hash[element] += 1
  hash
end
#=> {1=>1, 2=>1, 3=>1, 4=>1, 5=>1}
```

##### 使用 fetch 处理默认值
除了在 `Hash.new` 初始化默认值，某些时候使用 `fetch` 来处理默认值也是很好的方式，虽然工作方式类似，但是它们的使用方式还是有些区别：
* fetch 接收 2个参数，第1个参数是 key 值，第2个参数是默认值
* fetch 如果不传第2个参数也可以工作，只是如果出现找不到 key 的情况会抛出 `KeyError` 异常

总体来说相比对整个哈希设置默认值，`fetch` 看上去更加灵活和安全

```ruby
hash_res = array.reduce({}) do |hash, element|
  hash[element] = hash.fetch(element, 0) + 1
  hash
end
#=> {1=>1, 2=>1, 3=>1, 4=>1, 5=>1}
```

关于哈希默认值的使用建议如下：
* 如果你操作 `Hash` 不希望遇到 `NoMethodError` 可以考虑使用 Hash 默认值
* 如果你期望查找不存在 key 的时候返回 `nil`，那么就不要使用 Hash 默认值
* 相比对整个哈希设置默认值，`fetch` 更加灵活和安全

---
### 对集合优先使用委托而非继承



参考资料：
* 《Effectvie Ruby》：https://book.douban.com/subject/26690609/