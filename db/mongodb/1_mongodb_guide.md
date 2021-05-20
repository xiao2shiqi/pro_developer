# 数据库和集合
MongoDB 的数据库跟关系型数据库类似，但是 集合（Collection）相当于关系型数据库中的 表（Table）

### 创建数据库：
```shell
use myDatabase
```
使用 `use` 指定，数据库 myDatabase 不存在则会自动创建

### 创建文档

#### 自动创建
在 db 中创建数据：
```shell
db.myNewCollection1.insertOne( { x: 1 } )
```
跟 `use` 同理，使用 `insertOne` 指令当 myNewCollection1 文档（表）不存在则会自动创建文档，另外值的补充的是：为文档创建索引也有同样效果：
```shell
db.myNewCollection3.createIndex( { y: 1 } )
```
`createIndex` 也会自动创建 myNewCollection3 版本（如果不存在）

#### 手动创建
使用 `db.createCollection()` 可以显式的创建文档（当然自动创建比较方便，用的也比较多）

另外在创建文档也可以预设检验规则，具体参考：[Schema Validation](https://docs.mongodb.com/v4.2/core/schema-validation/)


### 视图

#### 视图的创建

Mongodb 的视图是基于已有的 Collection 或者 View（视图）创建只读的 View 视图。
创建视图的语句是：
```shell
db.createView(<view>, <source>, <pipeline>, <collation> )
```
#### 视图的限制

* 因为视图是`只读`的，所以 View 只支持 mongodb 只读查询函数：find()、findOne()、aggreate()、count()、distinct()
* 视图上的 find 不支持 projection 操作
* 视图不能重命名

#### 封顶集合
创建固定大小的集合可以提升集合的性能（查询，插入，吞吐量），这种集合在 mongo 中成为封顶集合

使用封顶集合，只需要在创建 collection  的时候加入限制即可，如下：
```shell
db.createCollection( "log", { capped: true, size: 100000 } )
```

# 文档 Document 

数据在 Mongodb 存储为 BSON 文档，BSON 是 JSON 的二进制表示方式，更多资料查看：
* [BSON 规范](https://bsonspec.org/)
* [BSON 类型](https://docs.mongodb.com/v4.2/reference/bson-types/)

一个 MongoDB Document 如下：
```json
{
  name: "sushan",   // field1: value1
  age: 26,
  status: "A",
  groups: ["news", "sports"]
}
```

Document 对字段名称的限制：
* 主键 `_id` 是保留主键：不可变，必须唯一，创建集合自动生成
* 字段名不能是 `null`
* 字段名不能以 `$` 符号开头

使用点符号访问嵌入式文档，格式如下：
```bash
"<embedded document>.<field>"
```

例如一个如下的 Document
```json
{
   ...
   name: { first: "Alan", last: "Turing" },
   contact: { phone: { type: "cell", number: "111-222-3333" } },
   ...
}
```
* 要访问嵌入式文档获取 `last` 的值，就使用点符号：`name.last`
* 还有更深一些的层级，例如如果要访问 `numbenr`，那么就使用点号：`contact.phone.number`

