## Document Insert

### 插入 Document
`db.collection.insertOne()` 插入单个 Docuemtn 到 Collection 中：

示例代码如下：
```bash
db.inventory.insertOne(  
        { item: "canvas", qty: 100, tags: ["cotton"], size: { h: 28, w: 35.5, uom: "cm" } }
)
```
使用 `insertOne` 几点注意事项：
* 如果未指定 `_id` 字段，那么 mongoDB 会自动创建 `_id` 字段
* `insertOne` 会返回一个新插入 Document 的 `_id` 字段值
  

### 插入 Many Document
`db.collection.insertMany()` 可以插入多个 Document 到 Collection 中，
示例如下（`_id` 规则跟插入单个 Document 差不多）
```bash
db.inventory.insertMany([
        { item: "journal", qty: 25, tags: ["blank", "red"], size: { h: 14, w: 21, uom: "cm" } }, 
        { item: "mat", qty: 85, tags: ["gray"], size: { h: 27.9, w: 35.5, uom: "cm" } },
        { item: "mousepad", qty: 25, tags: ["gel", "blue"], size: { h: 19, w: 22.85, uom: "cm" } }
    ])
```
值的注意是的：
* `insertMany` 会返回多个插入的 Document 的 `_id` 数组

另外使用 `db.inventory.find( {} )` 可以查询集合所有的文档，就可以看到刚刚插入的数据了

关于文档插入的另外几点补充：
* Document 关联的集合如果不存在，集合则会自动创建
* 插入未指定 `_id` 字段，Mongodb 则会自动为 `_id` 生成 **ObjectId**
* MongoDB 单个文档的插入是原子操作级别的

####  完结
关于 mongodb 的插入大致就这些，其他的插入方法似乎也不是很常用，如果有兴趣可以看看 [Additional Methods for Inserts](https://docs.mongodb.com/manual/reference/insert-methods/#additional-inserts)

