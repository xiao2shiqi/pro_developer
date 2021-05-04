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

