## 文档插入

### 插入一条数据：
`db.collection.insertOne()` 插入单个 Docuemtn 到 Collection 中：

```bash
db.inventory.insertOne(  
        { item: "canvas", qty: 100, tags: ["cotton"], size: { h: 28, w: 35.5, uom: "cm" } }
)
```
使用 `insertOne` 几点注意事项：
* 如果未指定 `_id` 字段，那么 mongoDB 会自动创建 `_id` 字段
* `insertOne` 会返回一个新插入 Document 的 `_id` 字段值
  

### 插入多条数据
`db.collection.insertMany()` 使用方式：
```bash
db.inventory.insertMany([
        { item: "journal", qty: 25, tags: ["blank", "red"], size: { h: 14, w: 21, uom: "cm" } }, 
        { item: "mat", qty: 85, tags: ["gray"], size: { h: 27.9, w: 35.5, uom: "cm" } },
        { item: "mousepad", qty: 25, tags: ["gel", "blue"], size: { h: 19, w: 22.85, uom: "cm" } }
    ])
```
值的注意是的：
* `insertMany` 会返回多个插入的 Document 的 `_id` 数组

关于文档插入的另外几点补充：
* Document 关联的集合如果不存在，集合则会自动创建
* 插入未指定 `_id` 字段，Mongodb 则会自动为 `_id` 生成 **ObjectId**
* MongoDB 单个文档的插入是原子操作级别的

对于插入更多的参考资料：[Additional Methods for Inserts](https://docs.mongodb.com/manual/reference/insert-methods/#additional-inserts)


## 文档查询

### 文档简单查询
方便理解，查询使用的示例数据：
```
db.inventory.insertMany([
{ item: "journal", qty: 25, size: { h: 14, w: 21, uom: "cm" }, status: "A" },
{ item: "notebook", qty: 50, size: { h: 8.5, w: 11, uom: "in" }, status: "A" },
{ item: "paper", qty: 100, size: { h: 8.5, w: 11, uom: "in" }, status: "D" },
{ item: "planner", qty: 75, size: { h: 22.85, w: 30, uom: "cm" }, status: "D" },
{ item: "postcard", qty: 45, size: { h: 10, w: 15.25, uom: "cm" }, status: "A" }
]);
```
**查询全部**：使用 `find( {} )` 可以查询所有集合，示例代码：
```
db.inventory.find( {} )
```

**相等条件**查询：<br>
例如我要查询集合 `inventory` 所有状态 `status` 为 `D` 的所有记录，查询语句如下：
```
db.inventory.find( { status: "D" } )
```

**使用匹配操作服**查询条件：
mongodb 也支持类似关系数据库的 `or`，`in` 操作符<br>
例如要查询 `inventory` 所有状态 `status` 为 `A` 或者 `D`  的所有记录，查询语句如下：
```
db.inventory.find( { status: { $in: [ "A", "D" ] } } )
```

更多的匹配操作符，可以参考官方文档：[Query and Projection Operators](https://docs.mongodb.com/manual/reference/operator/query/)

**复合条件**的使用：（相等 + 符号匹配）

例如：查询 `inventory` 集合中 `status` 为 `A` 并且 `qty` 小于 30 的记录：
```
db.inventory.find( { status: "A", qty: { $lt: 30 } } )
```

其他更多比较运算符，可以参考：[Comparison Query Operators](https://docs.mongodb.com/manual/reference/operator/query-comparison/#query-selectors-comparison)

<br>

**返回指定字段**：
使用以下格式查询语法，可以只展示指定的 `item` 和 `status` 字段：
```
db.inventory.find( { status: "A" }, { item: 1, status: 1 } )
```
排除指定字段：
```
db.inventory.find( { status: "A" }, { status: 0, instock: 0 } )
```

### 查询数组字段
可以使用以下语句精确匹配数组：
```
db.inventory.find( { tags: ["red", "blank"] } )
```
要查找数组中包含指定元素可以使用 `$all` 操作符，例如查询 `tags` 字段既包含 `red, blnak` 的语法，如下：
```
db.inventory.find( { tags: { $all: ["red", "blank"] } } )
```
查找数组中包含指定元素，例如 `tags` 字段中包含 `red` 元素的记录：
```
db.inventory.find( { tags: "red" } )
```
使用相等对比操作符：查询数组字段中，`dim_cm` 数组字段包含大于 `25` 的项目：
```
db.inventory.find( { dim_cm: { $gt: 25 } } )
```
数组的查询方法还有很多：
更多数组查询的技巧查阅文档：
* [查询数组](https://docs.mongoing.com/mongodb-crud-operations/query-documents/query-an-array)
* [查询嵌入式文档数组](https://docs.mongoing.com/mongodb-crud-operations/query-documents/query-an-array-of-embedded-documents)


### 查询空字段
查询所有 `null` 值的字段（包含不存在的字段）
```
db.inventory.find( { item: null } )
#=> query result: 2 item
```
只查询存在 `null` 值的字段（不包含字段不存在的情况）
```
db.inventory.find( { item : { $type: 10 } } )
#=> query result: 1 item
```

查询不存在字段的记录信息：
```
db.inventory.find( { item : { $exists: false } } )
#=> query result: 1 item
```


### 查询嵌套文档
填充假数据用于练习：
```
db.inventory.insertMany( [
    { item: "journal", qty: 25, size: { h: 14, w: 21, uom: "cm" }, status: "A" },
    { item: "notebook", qty: 50, size: { h: 8.5, w: 11, uom: "in" }, status: "A" },
    { item: "paper", qty: 100, size: { h: 8.5, w: 11, uom: "in" }, status: "D" },
    { item: "planner", qty: 75, size: { h: 22.85, w: 30, uom: "cm" }, status: "D" },
    { item: "postcard", qty: 45, size: { h: 10, w: 15.25, uom: "cm" }, status: "A" }
]);
```

内嵌文档完全匹配（需要匹配顺序）
```
db.inventory.find( { size: { h: 14, w: 21, uom: "cm" } } )
#=> query result: 1 item
```
如果匹配的内嵌文档顺序不同，则无法匹配，例如：
```
db.inventory.find(  { size: { w: 21, h: 14, uom: "cm" } }  )
#=> query result: 0 item
```
使用 `点符号` 完全匹配内嵌文档的字段，例如以下语句匹配 `size.uom` 字段：
```
db.inventory.find( { "size.uom": "in" } )
#=> query result: 2 item
```
也可以使用`查询运算符`来匹配内嵌文档，如下：
```
db.inventory.find( { "size.h": { $lt: 15 } } )
#=> query result: 4 item
```
使用 `AND` 兼顾外部和内嵌字段的查询
```
db.inventory.find( { "size.h": { $lt: 15 }, "size.uom": "in", status: "D" } )
```

##### 嵌套文档范围查询
很多时候你不知道嵌套文件的具体对象，那么可以使用以下语句对嵌套文档进行查询，例如我们要查出 `inventory` 集合中 `instock.qty <= 20` 的数据，查询语句如下：  
```
db.inventory.find( { 'instock.qty': { $lte: 20 } } )
```

##### 使用 `$elemMatch` ，多条件完全匹配
查询语法如下：
```
// 查询 instock 字段包含 {qty: 5, warehouse: "A" } 的对象的记录
db.inventory.find( { "instock": { $elemMatch: { qty: 5, warehouse: "A" } } } )
// 查询 instock 字段 qty > 10 and qty < 20 的记录
db.inventory.find( { "instock": { $elemMatch: { qty: { $gt: 10, $lte: 20 } } } } )
```

更多查询教程：
* [Query Documents](https://docs.mongodb.com/manual/tutorial/query-documents/)
* [Query an Array](https://docs.mongodb.com/manual/tutorial/query-arrays/)
* [Query an Array of Embedded Documents](https://docs.mongodb.com/manual/tutorial/query-array-of-documents/)



## 文档更新

mongdoDB 对于更新提供的三个方法：
* updateOne：更新单个文档
* updateMany：更新多个文档
* replaceOne：替换单个文档
* update：根据过滤器决定更新单个 or 多个文档

为了方便理解操作，我们先插入示例数据：
```
db.inventory.insertMany( [
   { item: "canvas", qty: 100, size: { h: 28, w: 35.5, uom: "cm" }, status: "A" },
   { item: "journal", qty: 25, size: { h: 14, w: 21, uom: "cm" }, status: "A" },
   { item: "mat", qty: 85, size: { h: 27.9, w: 35.5, uom: "cm" }, status: "A" },
   { item: "mousepad", qty: 25, size: { h: 19, w: 22.85, uom: "cm" }, status: "P" },
   { item: "notebook", qty: 50, size: { h: 8.5, w: 11, uom: "in" }, status: "P" },
   { item: "paper", qty: 100, size: { h: 8.5, w: 11, uom: "in" }, status: "D" },
   { item: "planner", qty: 75, size: { h: 22.85, w: 30, uom: "cm" }, status: "D" },
   { item: "postcard", qty: 45, size: { h: 10, w: 15.25, uom: "cm" }, status: "A" },
   { item: "sketchbook", qty: 80, size: { h: 14, w: 21, uom: "cm" }, status: "A" },
   { item: "sketch pad", qty: 95, size: { h: 22.85, w: 30.5, uom: "cm" }, status: "A" }
] );
```

**更新单条数据**：updateOne 使用：
```
db.inventory.updateOne({ item: "paper" },
    {
        $set: { "size.uom": "cm", status: "P" }, 
        $currentDate: { lastModified: true }
    }
);
```
以上操作详解如下：
* $set： 更新字段 `size.uom`, `status` 的值，如果字段不存在则创建
* $currentData： 更新字段 `lastModified` 的日期，如果字段不存在则会创建

**更新多条数据**：updateMany 使用：
```
db.inventory.updateMany({ "qty": { $lt: 50 } },
  {  
  $set: { "size.uom": "in", status: "P" }, 
  $currentDate: { lastModified: true }  
  }
)
```
如果表达式 `{ "qty": { $lt: 50 } }` 能匹配到多条记录，那么就会更新多条记录

关于 Update 更多的补充：
* MongDB 所有写操作都是原子性的
* 你无法更新 `_id` 字段的值
* 更新操作不会修改字段顺序

更多的更新操作参考官方文档：[Update Document](https://docs.mongodb.com/manual/tutorial/update-documents/)

### 聚合管道
聚合管道容易写出表达性更强的 `update` 语句

**使用聚合管道更新数据**

先输入示例数据
```
db.students.insertMany([
   { _id: 1, test1: 95, test2: 92, test3: 90, modified: new Date("01/05/2020") },
   { _id: 2, test1: 98, test2: 100, test3: 102, modified: new Date("01/05/2020") },
   { _id: 3, test1: 95, test2: 110, modified: new Date("01/04/2020") }
])
```
使用聚合管道使用_id更新文档：3：
```
db.students.updateOne( { _id: 3 }, { $set: { "test3": 98, modified: "$$NOW"} } )
```

**使用聚合管道标准化文档的字段**

先输入示例数据
```
db.students2.insertMany([
        { "_id" : 1, quiz1: 8, test2: 100, quiz2: 9, modified: new Date("01/05/2020") }, 
        { "_id" : 2, quiz2: 5, test1: 80, test2: 89, modified: new Date("01/05/2020") },
])
```
再来看看这个乱七八糟的文档：
```
db.students2.find()
```
使用聚合管道来把乱七八糟的文档整理为标准化的文档
```
db.students2.updateMany( {},
    [
        { $replaceRoot: { newRoot: 
            { $mergeObjects: [ { quiz1: 0, quiz2: 0, test1: 0, test2: 0 }, "$$ROOT" ] } 
    } },
        { $set: { modified: "$$NOW"}  }
    ]
)
```

简单介绍这里用到的 2个管道函数：
* $replaceRoot：使用 $mergeObjets 表达式，并且为字段 `quiz1, 1uiz2, test1, test2` 设置默认值（如果不存在的化）
* $set：将文档字段 `modified` 值更新为当前时间，如果字段不存在则创建

可以再看看整理后的文档（处女座的强迫症）
```
db.students2.find()
```

更多的管道更新操作：[Updates with Aggregation Pipeline](https://docs.mongodb.com/manual/tutorial/update-documents-with-aggregation-pipeline/)


## 删除文档

Mongodb 常用的几个删除方法：
* deleteMany()：删除多个文档
* deleteOne()：删除单个文档
* remove()：根据筛选项删除文档

填充数据用于展示：
```
db.inventory.insertMany( [
   { item: "journal", qty: 25, size: { h: 14, w: 21, uom: "cm" }, status: "A" },
   { item: "notebook", qty: 50, size: { h: 8.5, w: 11, uom: "in" }, status: "P" },
   { item: "paper", qty: 100, size: { h: 8.5, w: 11, uom: "in" }, status: "D" },
   { item: "planner", qty: 75, size: { h: 22.85, w: 30, uom: "cm" }, status: "D" },
   { item: "postcard", qty: 45, size: { h: 10, w: 15.25, uom: "cm" }, status: "A" },
] );
```

删除所有文档：
```
db.inventory.deleteMany({})
```

删除匹配条件文档：
```
db.inventory.deleteMany({ status : "A" })

```
仅删除第一个匹配项：
```
db.inventory.deleteOne( { status: "D" } )
```


## MongoDB CRUD 概念

几个比较重要的知识点，属于重要但是不紧急，等待记录…………

**查询计划**

**查询优化**

**分析查询**


