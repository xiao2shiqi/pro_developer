# 数据模型

## 数据建模的介绍

### 灵活的模式
与关系型数据库的区别：
* mongodb 不需要预先设计表结构
* 新增删除字段也不需要指定对应的 DDL 操作

### 嵌入式数据方式
以 JSON 数据模型为存储单元，可以更加复合面向对象编程语言的交互设计，甚至可以直接用于返回页面进行展示。 <br>
可以将关联关系存储在当前对象内，如下： <br>
![data model with embedded fields](https://pcloud-1258173945.cos.ap-guangzhou.myqcloud.com/uPic/O1CGZk.jpg)

### 引入数据方式
可以向关系型数据一样，存储关联关系的引用：
数据存储方式如下：<br>
![data model using references to link document](https://pcloud-1258173945.cos.ap-guangzhou.myqcloud.com/uPic/oxPPsT.jpg)

