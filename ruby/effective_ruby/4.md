# 异常
---
有时候粗鲁的使用异常，会让代码和程序更加复杂，我们来学习如何避免常见的错误处理异常的方式，编写更安全的代码


### 使用特定的异常，来明确异常含义

#### 抛异常中常见的问题是什么 ?
你在编写一段代码，你觉得这段代码可能会出现，于是你打算抛出异常提声明程序错误<br>
一个普遍的现象是很多人会直接使用 `raise + 字符串` 的方式抛出异常，代码如下：
```ruby
raise("Oops, something went wrong")
```

熟悉 `raise` 风格的可能还会加上异常类型参数，如下：
```ruby
raise(RuntimeError, "Oops, something went wrong")
```
如果你不是期望程序停止运行，那么直接抛出 **RuntimeError 和直接抛出字符串都不是一个好主意**，你应该为你的错误定义一个异常类型，这样的做的目的主要有两个：
1. 便于其他程序员捕获和处理你的异常，让程序可以在异常中恢复
2. 让你的异常区别于其他标准类型异常，更加容易定位问题

#### 那么正确定义异常的姿势是什么 ？

在创建新的异常前，需要前考虑 Ruby 两个异常原则：
* 自定义标准异常，多数情况下应该直接继承 `StandardError` 类（以 `Exception` 为基础的继承体系，`Exception` 的子类通常是会直接导致程序崩溃的低级错误）
* 虽然不是程序上要求，但是异常类通常以 `Error` 作为后缀命名

根据以上要求，定义一个简单标准类型的异常代码如下：
```ruby
class ItemNotFoundError < StandardError; end
```

我们使用新增的类型代替刚才的 `RuntimeError` 异常，代码如下：
```ruby
raise(ItemNotFoundError, "user input params error")
#=> user input params error (ItemNotFoundError)
```
就通过以上简单的两行信息，就为程序提供丰富的信息，更好阅读，也更加便于后期定位问题

#### 为异常附加更多信息
有时候抛出异常，不仅仅是输出字符串，有时候附加一些当时的变量、上下文信息可以更加方便定位和排查问题，如果要定义一个这样类型的变量，那么上面那种简单的类型就无法满足需求了，我们下面定义个 `TemperatureError` 温度异常类，当发现温度异常时，该异常还会记录当时的温度信息，方便程序员定位和排查信息：
```ruby
class TemperatureError < StandardError
  attr_reader(:temperature)

  def initialize (temperature)
    @temperature = temperature
    super("invalid temperature: #{@temperature}")
  end
end

# 抛出异常对象，需要传入构造参数
raise(TemperatureError.new(180))
#=> invalid temperature: 180 (TemperatureError)
```
通过以上的定义，我们会得到一条有价值的异常信息，而不是刚开始那毫无意义的 `Oops, something went wrong` 提示，通过本章分享你应该知道如何让你的错误信息更具备表达能力

关于 Ruby 的自定义异常，我们得出如下总结和建议：
* 避免直接抛出字符串和 RuntimeError 异常，因为你无法根据这些信息快速定位问题
* 自定义的异常应该继承 `StandardError` 类，并且符合 `Error` 结尾的命名规范
* 为自定义异常添加 `initialize` 和调用 `super` 方法，可以记录更多的上下文信息
* 当你项目异常过多的时候，可以参考 `Exception` 为异常设计层级关系，但是基类必须是`StandardError` 


### 应该只捕获特定的异常

很多人刚开始接触编程的时候，大多都会对可能出现异常的代码都是直接用 `begin……rescue` 全部包起来，例如下面这样：
```ruby
begin
  raise("Oops, something went wrong")
rescue => e # Default Error : RuntimeError
  # handle exception code....
end
#=> #<RuntimeError: Oops, something went wrong>
```
会出现以上这种代码的大多有以下几个情况：
1. 你也不知道程序会出什么问题，索性使用通用的 `RuntimError` 包住所有问题
2. 让程序看起来运行正常……

结合前面一节如何为你的错误定义特定类型的异常，所以对异常的处理我有如下建议：
1. 你应该先定义你知道的异常类型，然后在 `begin...rescue` 中优先处理你知道的异常
2. 如果确实发生无法预见的异常，应该向上抛出，及时反馈问题，而不是使用 `begin...rescue` 来尝试掩盖问题

结合以上的建议，我们来看看建议的异常处理代码应该怎么写 ？
```ruby
# 首先定义你自己的异常类型
# 当然如果你的异常可以复用异常标准库的异常，建议优先复用标准库的异常：
# 例如：NetworkConnectionError，InvalidRecordError 等……

# 我根据自己的程序定义了：参数异常，类型异常
class ParamsError < StandardError; end
class TypeError < StandardError; end
```

然后我们来看看在一段可能出现 `ParamsError`， `TypeError` 的异常代码中我们应该怎样捕获？ 代码如下：
```ruby
# 原则是应该优先对可预见的异常类型进行恢复处理……
begin 
  # a few code....
  raise(ParamsError, "parama value error !!") # wow ! raise error !
rescue ParamsError => e
  # 程序可能在这里恢复
  p "处理参数错误的逻辑代码……"
rescue TypeError => e
  # 程序可能在这里恢复
  p "处理可预见的类型异常逻辑代码……"
rescue => e
  # 处理不了，通知上级了！
  p "未知的通用异常，继续向上抛出……"
  raise 
ensure
  #... 通常 ensure 负责执行一些关闭资源的操作，例如： file.close,  db.close ...
end
```
通过以上程序，我们看到几个处理异常的原则：
1. 显示声明捕获的异常类型，可以让你的代码更具表达性和可读性
2. 优先处理可预见的异常类型，因为你知道如何恢复它，从而你的程序也更健壮
3. 越抽象的异常应该越挡在底部，例如通用的 `RuntimeError` 因为你不知道如何处理它，只能继续向上抛
4. 使用 `ensure` 来执行不管是否发生异常都必须执行的代码，例如：关闭连接资源

可以通过以上的方式来改造你的程序，让你的程序更加的健壮！