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

~~使用 reduce 方法折叠集合~~ （感觉是减少代码的语法糖，暂时不值得学习，降低代码可读性，增加代码的维护难度）

### 考虑使用默认哈希值



参考资料：
* 《Effectvie Ruby》：https://book.douban.com/subject/26690609/