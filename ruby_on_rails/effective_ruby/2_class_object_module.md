# ruby 中的面向对象
---

### 了解 Ruby 的继承是怎么回事 ？
先来看看一段最基本的继承代码：
```ruby
# 定义父类
class Person
    def name
        p "person name"
    end
end

# 定义子类
class Customer < Person
end

customer = Customer.new
p "customer: #{customer}" 
p "customer_class: #{customer.class}"
p "Customer SuperClass: #{Customer.superclass}"
p "have name methods? #{customer.respond_to?(:name)}"

# output：
# customer: #<Customer:0x00007fae17893d80>
# customer_class: Customer 
# Customer SuperClass: Person
# have name methods? true
```
从以上代码可以看出， Ruby 的继承模型比较简单，Customer 继承 Person 类同时也拥有的 Person.name 函数的功能，继承模型就类似一张单向链表，如下图所示：
![MIZOkt](https://pcloud-1258173945.cos.ap-guangzhou.myqcloud.com/uPic/MIZOkt.png)

当调用 customer.name 它会逐级向上查询 `name` 方法，所以 name 可以在 Person 找到并且正确返回，
假设方法向上无法查找，那么最终就会调用到 Kernel 模块中的 `method_missing` 方法，该方法默认抛出一个异常

下面我们看看 `include` 是如何影响 Ruby 的继承体系的