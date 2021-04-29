# 重新熟悉 Ruby：
---
熟悉 Ruby 的语法
### Ruby 中特殊的 True

在 Ruby 中除了 false 和 nil，其他都是真值

### 理解 Ruby 中的 nil
跟大多数静态语言调用 nil 会直接报错不同，ruby 很多内置函数可以讨巧的帮你避免遇到 nil，例如 `to_s`，`to_i`，`to_f`，参考示例：
```ruby
13.to_s
=> "13"

nil.to_s
=> ""

nil.to_a
=> []

nil.to_i
=> 0

nil.to_f
=> 0.0
```

另外 2个关于 nil 的技巧是：
* nil? 可以帮你检查空对象
* Array#compact 可以移除所有 nil 元素

### Ruby 常量是可变的
跟大多数编程语言不同的是， Ruby 的常量是可以改变的，参考示例：
```ruby
module Defaults
    NETWORKS = ["192.168.1", "192.168.2"]
end

def purge_unreachable (networks = Defaults::NETWORKS) 
    networks.delete_if do |net|
        net == "192.168.2"
    end
end

purge_unreachable(Defaults::NETWORKS)   # 常量被改变，输出：Defaults::NETWORKS = ["192.168.1"]
```
如果不想常量 `NETWORKS` 被修改，那么解决的方式就是为常量增加 `freeze` 方法，如下：
```ruby
    NETWORKS = ["192.168.1", "192.168.2"].freeze
    # 再尝试修改会报错：can't modify frozen Array (FrozenError)
```
以上证明 `freeze` 方法仅仅只是可以保证数组无法被增加和删除，但是数组本身存在的元素还是可以修改的，参考示例：
```ruby
module Defaults
    NETWORKS = ["192.168.1", "192.168.2"]
end

def host_addresses (host, networks = Defaults::NETWORKS)
    networks.map {|net| net << ".#{host}" }
end
host_addresses("11")     # 输出：Defaults::NETWORKS = ["192.168.1.11", "192.168.2.11"]
```
上面例子证明，常量 `NETWORKS` 既有的值已经被修改了，如果想要保证已有的元素不被修改，那么需要将 Array 所有的元素增加 freeze，例如
```ruby
    NETWORKS = ["192.168.1", "192.168.2"].map!(&:freeze).freeze
```
那么再执行 host_addresses 的时候就可以看到 `can't modify frozen String (FrozenError)` 异常信息

最后一件可怕的事情来了，当通过 `freeze` 限制了常量 `NETWORKS` 和已有的元素无法被更改的时候，常量的引用还是可以被修改，例如：
```ruby
    Defaults::NETWORKS = ["192.168.1.9"]
    # warning: already initialized constant Defaults::NETWORKS
    # warning: previous definition of NETWORKS was here
    # out: Defaults::NETWORKS = ["192.168.1.9"]
```
Ruby 编译器会告诉你警告，但是这不会影响变量被修改，唯一能解决这个问题的就是，给模块也加上 `freeze`，例如：
```ruby
    Defaults.freeze
```
最终如果再尝试修改，就会报错：`can't modify frozen Module (FrozenError)` 通过以上三级保护，应该可以保护常量完全不被修改了
对于 Ruby 常量，最终总结如下：
* 普通常量可以通过 `freeze` 来保证常量不被修改
* 数组和集合类常量，需要保证给所有元素加上 `freeze` 方法，才能保证既有的元素不被修改
* 要想保证常量的引用不被修改，那么需要给模块加上 `freeze` 方法

