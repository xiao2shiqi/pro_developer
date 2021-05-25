## 聚合

聚合操作是汇总多个操作的集合，并且返回单个结果，Mongodb 提供三种执行聚合的方法：
* [aggregation pipeline](https://docs.mongodb.com/manual/aggregation/#std-label-aggregation-framework)
* [map-reduce function](https://docs.mongodb.com/manual/aggregation/#std-label-aggregation-map-reduce)
* [single purpose aggregation methods](https://docs.mongodb.com/manual/aggregation/#std-label-single-purpose-agg-operations)


### aggregation pipeline 聚合管道

先看一个简单的聚合操作：
```json
db.orders.aggregate([
   { $match: { status: "A" } },
   { $group: { _id: "$cust_id", total: { $sum: "$amount" } } }
])
```
该聚合函数主要进行两步操作：
1. 使用 `$match` 过滤字段
2. 使用 `$group` 将字段分组，计算合计



### map-reduce 

前言
> 1. 对于大多数聚合操作，聚合管道提供更好的性能和更一致的接口。
> 2. 聚合管道 比map-reduce提供更好的性能和更一致的接口。
> 3. 各种map-reduce表达式可以使用被重写聚合管道运算符，诸如$group， $merge等

我们假设一个场景，有一个订单表，初始化数据如下
```json
db.orders.insertMany([
   { _id: 1, cust_id: "Ant O. Knee", ord_date: new Date("2020-03-01"), price: 25, items: [ { sku: "oranges", qty: 5, price: 2.5 }, { sku: "apples", qty: 5, price: 2.5 } ], status: "A" },
   { _id: 2, cust_id: "Ant O. Knee", ord_date: new Date("2020-03-08"), price: 70, items: [ { sku: "oranges", qty: 8, price: 2.5 }, { sku: "chocolates", qty: 5, price: 10 } ], status: "A" },
   { _id: 3, cust_id: "Busby Bee", ord_date: new Date("2020-03-08"), price: 50, items: [ { sku: "oranges", qty: 10, price: 2.5 }, { sku: "pears", qty: 10, price: 2.5 } ], status: "A" },
   { _id: 4, cust_id: "Busby Bee", ord_date: new Date("2020-03-18"), price: 25, items: [ { sku: "oranges", qty: 10, price: 2.5 } ], status: "A" },
   { _id: 5, cust_id: "Busby Bee", ord_date: new Date("2020-03-19"), price: 50, items: [ { sku: "chocolates", qty: 5, price: 10 } ], status: "A"},
   { _id: 6, cust_id: "Cam Elot", ord_date: new Date("2020-03-19"), price: 35, items: [ { sku: "carrots", qty: 10, price: 1.0 }, { sku: "apples", qty: 10, price: 2.5 } ], status: "A" },
   { _id: 7, cust_id: "Cam Elot", ord_date: new Date("2020-03-20"), price: 25, items: [ { sku: "oranges", qty: 10, price: 2.5 } ], status: "A" },
   { _id: 8, cust_id: "Don Quis", ord_date: new Date("2020-03-20"), price: 75, items: [ { sku: "chocolates", qty: 5, price: 10 }, { sku: "apples", qty: 10, price: 2.5 } ], status: "A" },
   { _id: 9, cust_id: "Don Quis", ord_date: new Date("2020-03-20"), price: 55, items: [ { sku: "carrots", qty: 5, price: 1.0 }, { sku: "apples", qty: 10, price: 2.5 }, { sku: "oranges", qty: 10, price: 2.5 } ], status: "A" },
   { _id: 10, cust_id: "Don Quis", ord_date: new Date("2020-03-23"), price: 25, items: [ { sku: "oranges", qty: 10, price: 2.5 } ], status: "A" }
])
```

**需求一：汇总统计每位客户的 price 总和**

使用可用的聚合管道运算符，您可以重写map-reduce操作，而无需定义自定义函数，代码和结果如下：
```json
db.orders.aggregate([
   { $group: { _id: "$cust_id", value: { $sum: "$price" } } },
   { $out: "agg_alternative_1" }
])
```
具体操作：
1. `$group` 对字段 `$cust_id` 进行汇总，`$sum` 对字段进行合计
2. `$out` 输出聚合结果到 collection 中

最终获得结果如下：
```json
{ "_id" : "Don Quis", "value" : 155 }
{ "_id" : "Ant O. Knee", "value" : 95 }
{ "_id" : "Cam Elot", "value" : 60 }
{ "_id" : "Busby Bee", "value" : 125 }
```

因为使用 `$out` 缘故，你可以直接再对集合进行排序
```json
db.agg_alternative_1.find().sort( { _id: 1 } )
```
结果如下：
```json
{ "_id" : "Ant O. Knee", "value" : 95 }
{ "_id" : "Busby Bee", "value" : 125 }
{ "_id" : "Cam Elot", "value" : 60 }
{ "_id" : "Don Quis", "value" : 155 }
```

需求二：统计每个项目的订单数总和，平均价格

使用可用的聚合管道运算符，您可以重写map-reduce操作，而无需定义自定义函数，聚合代码如下：
```json
   db.orders.aggregate( [
      { $match: { ord_date: { $gte: new Date("2020-03-01") } } },
      { $unwind: "$items" },
      { $group: { _id: "$items.sku", qty: { $sum: "$items.qty" }, orders_ids: { $addToSet: "$_id" } }  },
      { $project: { value: { count: { $size: "$orders_ids" }, qty: "$qty", avg: { $divide: [ "$qty", { $size: "$orders_ids" } ] } } } },
      { $merge: { into: "agg_alternative_3", on: "_id", whenMatched: "replace",  whenNotMatched: "insert" } }
   ] )
```

文档最终返回结果：
```json
 { "_id" : "apples", "value" : { "count" : 4, "qty" : 35, "avg" : 8.75 } }
 { "_id" : "carrots", "value" : { "count" : 2, "qty" : 15, "avg" : 7.5 } }
 { "_id" : "chocolates", "value" : { "count" : 3, "qty" : 15, "avg" : 5 } }
 { "_id" : "oranges", "value" : { "count" : 7, "qty" : 63, "avg" : 9 } }
 { "_id" : "pears", "value" : { "count" : 1, "qty" : 10, "avg" : 10 } }
```

这里就不仔细讲解，可以参考文档：[Map-Reduce Examples](https://docs.mongodb.com/manual/tutorial/map-reduce-examples/)

在 Mongodb 4.4 中大多数的都可以使用 聚合管道替代 map-reduce 
更多资料参考：[Aggregation Reference](https://docs.mongodb.com/manual/reference/aggregation/)



