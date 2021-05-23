## Document Query

为了查询方便，先填充 `inventory` 集合数据，操作如下：
```
db.inventory.insertMany([
{ item: "journal", qty: 25, size: { h: 14, w: 21, uom: "cm" }, status: "A" },
{ item: "notebook", qty: 50, size: { h: 8.5, w: 11, uom: "in" }, status: "A" },
{ item: "paper", qty: 100, size: { h: 8.5, w: 11, uom: "in" }, status: "D" },
{ item: "planner", qty: 75, size: { h: 22.85, w: 30, uom: "cm" }, status: "D" },
{ item: "postcard", qty: 45, size: { h: 10, w: 15.25, uom: "cm" }, status: "A" }
]);
```

#### 查询全部
使用 `find( {} )` 可以查询所有集合，示例代码：
```
db.inventory.find( {} )
```

#### 查询相等条件
查询表达式如下：
```
{ <field1>: <value1>, ... }
```

例如我要查询集合 `inventory` 所有状态 `status` 为 `D` 的所有记录，查询语句如下：
```
db.inventory.find( { status: "D" } )
```
那么它翻译为 SQL 如下：
```
SELECT * FROM inventory
```

#### 查询匹配条件
mongodb 也支持类似关系数据库的 `or`，`in` 操作符，格式如下：
```
{ <field1>: { <operator1>: <value1> }, ... }
```
例如要查询 `inventory` 所有状态 `status` 为 `A` 或者 `D`  的所有记录，查询语句如下：
```
db.inventory.find( { status: { $in: [ "A", "D" ] } } )
```
翻译为 SQL 如下：
```
SELECT * FROM inventory WHERE status in ("A", "D")
```

更多的 operator1 操作符，可以参考文档：[Query and Projection Operators](https://docs.mongodb.com/manual/reference/operator/query/)

使用复合条件进行查询（相等 + 符号匹配）

例如：查询 `inventory` 集合中 `status` 为 `A` 并且 `qty` 小于 30 的记录：
```
db.inventory.find( { status: "A", qty: { $lt: 30 } } )
```

翻译为 SQL 就是：
```
SELECT * FROM inventory WHERE status = "A" AND qty < 30
```

其他更多比较运算符，可以参考：[Comparison Query Operators](https://docs.mongodb.com/manual/reference/operator/query-comparison/#query-selectors-comparison)

### 返回指定字段
使用以下格式查询语法，可以只展示指定的 `item` 和 `status` 字段：
```
db.inventory.find( { status: "A" }, { item: 1, status: 1 } )
```
翻译为 SQL 就是：
```
SELECT _id, item, status from inventory WHERE status = "A"
```

从上面格式可以看出指定 `<field>: 1 `  可以显示指定字段，当然也可以使用 `<field>: 0` 来显示的排除指定字段：
```
db.inventory.find( { status: "A" }, { status: 0, instock: 0 } )
```


### 查询嵌套文档
嵌套文档也是通过 `db.collection.find()` 函数进行查询，我们先插入演示数据：
```
db.inventory.insertMany( [
    { item: "journal", instock: [ { warehouse: "A", qty: 5 }, { warehouse: "C", qty: 15 } ] },  
    { item: "notebook", instock: [ { warehouse: "C", qty: 5 } ] },
    { item: "paper", instock: [ { warehouse: "A", qty: 60 }, { warehouse: "B", qty: 15 } ] },
    { item: "planner", instock: [ { warehouse: "A", qty: 40 }, { warehouse: "B", qty: 5 } ] }, 
    { item: "postcard", instock: [ { warehouse: "B", qty: 15 }, { warehouse: "C", qty: 35 } ] }
]);
```

想要查询 `inventory` 中的 `instock` 包含和匹配对象的查询语法如下：
```
db.inventory.find( { "instock": { warehouse: "A", qty: 5 } } )
#=> {item: journal}
```
使用嵌套查询需要注意的是：整个嵌入式/嵌套文档上的相等匹配要求与指定文档（包括字段顺序）完全匹配
例如我们改变查询对象的顺序：`{ qty: 5, warehouse: "A" }` 那么就无法查出结果：
```
db.inventory.find( { "instock": { qty: 5, warehouse: "A" } } )
#=> null
```

##### 嵌套文旦范围查询
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

对于嵌套查询更多信息查阅问题：[查询嵌入式文档数组](https://docs.mongoing.com/mongodb-crud-operations/query-documents/query-an-array-of-embedded-documents)

### 查询数组
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
更多数组查询的技巧查阅文档：[查询数组](https://docs.mongoing.com/mongodb-crud-operations/query-documents/query-an-array)


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

更多查询教程：
* [Query Documents](https://docs.mongodb.com/manual/tutorial/query-documents/)
* [Query an Array](https://docs.mongodb.com/manual/tutorial/query-arrays/)
* [Query an Array of Embedded Documents](https://docs.mongodb.com/manual/tutorial/query-array-of-documents/)

本章完。。。。