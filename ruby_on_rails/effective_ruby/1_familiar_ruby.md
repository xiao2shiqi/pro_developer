# 重学 Ruby：
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
以上仅仅是保证数组无法被修改，但是数组本身存在的元素还是可以修改的，参考示例：
```ruby
module Defaults
    NETWORKS = ["192.168.1", "192.168.2"]
end

def host_addresses (host, networks = Defaults::NETWORKS)
    networks.map {|net| net << ".#{host}" }
end
host_addresses("1")     # 输出：Defaults::NETWORKS = ["192.168.1.1", "192.168.2.1"]

```