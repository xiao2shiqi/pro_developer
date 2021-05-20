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

