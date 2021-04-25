# 如何使用 Yard ?

资料来源：[Yard Getting Started Guide](https://rubydoc.info/gems/yard/file/docs/GettingStarted.md#docing)

##### 在文档中使用 Tags
yard 使用 @tag-style 样式语法，用于标记特殊属性字段

下面代码会在文档中声明当前 class 的作者
```ruby
# @author Loren Segal
class MyClass
end
```

yard 会将标签缩进后的文字标记为标签的一部分
例如下面是一段废弃代码的声明：
```ruby
# @deprecated Use {#my_new_method} instead of this method because
#   it uses a library that is no longer supported in Ruby 1.9.
#   The new method accepts the same parameters.
def mymethod
end
```
更多的 tag 清单可以参考：[Yard Tags 清单](https://rubydoc.info/gems/yard/file/docs/Tags.md#taglist)

##### 标签复用（Reference Tags）
减少重复的文档注释可以使用，Reference Tags 来复用已存在的文档，使用语法是：（see ...）
例如以下代码，方法 post 直接复用了 get 函数的文档描述，代码如下：
```ruby
class MyWebServer
  # Handles a request
  # @param request [Request] the request object
  # @return [String] the resulting webpage
  def get(request) "hello" end

  # (see #get)
  def post(request) "hello" end
end
```
另外补充一下，get 函数的 @params、@return 分别对入参和出参的类型和行为的描述，post 使用`(see ....)`函数直接复用了 get 的所有文档描述，你不必手写大量重复的代码
当然你在引入 `(see ...)` 后可以自己补充细节，如下代码：
```ruby
# (see #get)
# @note This method may modify our application state!
def post(request) self.state += 1; "hello" end
```

当然你也不可不必上面那样引入整段的 docstring，你可以单独只引入某一条标签的描述，例如下面，我们只引入对 @param、@return 标签的描述
```ruby
class MyWebServer
  # Handles a GET request
  # @param request [Request] the request object
  # @return [String] the resulting webpage
  def get(request) "hello" end

  # Handles a POST request
  # @note This method may modify our application state!
  # @param (see #get)
  # @return (see #get)
  def post(request) self.state += 1; "hello" end
end
```

##### 声明类型
对于大多数函数，声明返回类型可以让使用者更加清楚函数的作用，下面是 @return 的使用
```ruby
# @return [String, nil] the contents of our object or nil
#   if the object has not been filled with data.
def validate; end

# We don't care about the "type" here:
# @return the object
def to_obj; end
```
可以看到使用 [type1, type2, ....] 格式来可以表示多个返回类型，对于入参的 @parma 也有同样的效果，下面展示对一个或多个参数的声明，示例代码：
```ruby
# @param argname [#to_s] any object that responds to `#to_s`
# @param argname [true, false] only true or false
```

对于集合类型的参数，建议使用 `CollectionClass<ElementType, ...>` 格式来表示集合类型，示例代码：
```ruby
# @param list [Array<String, Symbol>] the list of strings and symbols.
```

##### 声明属性
在 ruby 属性中，添加文档描述即可对完成对属性的描述，还可以使用 `@return` 标签声明属性的类型，示例代码：
```ruby
# Controls the amplitude of the waveform.
# @return [Numeric] the amplitude of the waveform
attr_accessor :amplitude
```

##### 使用 YARD 生成文档

注意事项：
* 生成文档前，先使用 `yard doc` 解析文档
* 启动服务 `yard server`，然后访问: http://localhost:8088 （默认）即可访问文档