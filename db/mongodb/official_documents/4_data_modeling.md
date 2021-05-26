# 数据模型

## Data Modeling Introduction 数据建模的介绍

**灵活的模式：**<br>

与关系型数据库的区别：
* mongodb 不需要预先设计表结构
* 新增删除字段也不需要指定对应的 DDL 操作

**嵌入式数据方式：**<br>
以 JSON 数据模型为存储单元，可以更加复合面向对象编程语言的交互设计，甚至可以直接用于返回页面进行展示。 <br>
可以将关联关系存储在当前对象内，如下： <br>
![data model with embedded fields](https://pcloud-1258173945.cos.ap-guangzhou.myqcloud.com/uPic/O1CGZk.jpg)

**引入数据方式：**<br>
可以向关系型数据一样，存储关联关系的引用：
数据存储方式如下：<br>
![data model using references to link document](https://pcloud-1258173945.cos.ap-guangzhou.myqcloud.com/uPic/oxPPsT.jpg)


## Schema Validation 验证

需要文档支持验证，使用 `$jsonSchema` 操作 `validator` 表达式中的运算符，示例如下：
```json
// 创建一个指定校验规则的 Collection
db.createCollection( "contacts",
   { validator: { $or:
      [
         { phone: { $type: "string" } },
         { email: { $regex: /@mongodb\.com$/ } },
         { status: { $in: [ "Unknown", "Incomplete" ] } }
      ]
   }
} )
```

尝试违反规则插入数据：
```json
db.contacts.insert([
   { "_id": 1, "name": "Anne", "phone": "+1 555 123 456", "city": "London", "status": "Complete" },
   { "_id": 2, "name": "Ivan", "city": "Vancouver" }
])
```
返回错误：
```
[2021-05-27 06:27:00] com.mongodb.MongoBulkWriteException: Bulk write operation error on server localhost:27017. Write errors: [BulkWriteError{index=1, code=121, message='Document failed validation', details={}}].

```

使用 `validationAction` 可以允许违反规则的数据插入，K-V 属性如下：
* 如果validationAction 为error （默认值），MongoDB将拒绝任何违反验证条件的插入或更新。
* 如果validationAction 为warn，MongoDB会记录任何冲突，但允许继续插入或更新。

schema validation 限制：
* 不能为admin、local和config 数据库中的集合指定验证器
* 不能为 system.*集合指定验证器

