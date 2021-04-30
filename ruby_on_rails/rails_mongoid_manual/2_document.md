### Docuemtn 的使用

在 Rails Class 引入即可使用 Document
```ruby
    inlcude Mongoid::Document
```

Mongo 其实非常适合 Ruby 这种类型的动态语言，因为 Mongo 的 BSON 对象非常类似 Ruby 的 Hash 和 JSON 对象，操作起来非常方便


##### 定义字段类型

定义一个简单的 String 字段类型：
```ruby
    field :name, type: String
```

MongoDB 支持以下有效的字段类型：（不需要一个一个记，需要再查）
Array、BigDecimal、Boolean、Date、DateTime、Float、Hash、Integer、BSON::ObjectId、BSON::Binary、Range、Regexp、Set、String、StringifiedSymbol、Symbol、Time、TimeWithZone

在 Mongoid 中也忽略字段类型，所有字段会被当成字符串处理，这样可以避免字段类型转换，带来微弱的性能提升，但是也无法使用 MongoDB 为类型内置的函数（权衡利弊）
示例代码如下：
```ruby
    field :name
```

定义好字段后，可以通过以下三种方式访问字段：
```ruby
# get value
person.name
person[:name]
person.read_attribute(:name)

# set value
person.name = 'james'
person[:name] = 'james'
person.waite_attribute(:name, 'james')
```

如果要一次设置多个字段的话，可以通过 `new`， `attributes` 或者 `write_attributes` 来实现