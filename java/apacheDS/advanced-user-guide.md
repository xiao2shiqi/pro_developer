# 架构

了解服务器的工作方式



## 架构概览

Apache DS 体系结构层次：

![ApacheDS architecture](./assets/architecture.png)

如你所见，分为四个层次：

* 网络层 network
* 会话层 session
* 分区层 PartitionNexus
* 后端层 backend

以下逐渐介绍每个层的技术架构



## 网络层

我们不仅仅提供 LDAP 协议，还包含：

* Kerberos
* NTP
* DHCP
* DNS
* ChangePassword



它们都依赖 LDAP 的服务器作为后端存储：

* LDAP 服务需要 2 个 TCP 传输端口，默认为 10389，LDAPS 端口为 10636（中所周知的为 636）（LDAPS 已被视为弃用）
* Kerberos服务器使用一个TCP传输（默认为60088，但众所周知的端口是88）和一个UDP传输（两个端口的值相同）
* ChangePassword 服务器也使用一个TCP传输和一个UDP传输。默认值为60464，但众所周知的端口为464
* 我们也在运行 HttpServer，它用于管理。声明的端口都是TCP端口，一个用于HTTP，默认值为8080，另一个用于HTTPS，默认值是8443



## 目录服务

* 目录服务 DirectoryService 是服务器程序核心，处理所有传入的请求
* DirectoryService 有一个 schemaManager 示例，还有拦截器链 Interceptors
* DirectoryService 不仅仅是服务器的逻辑，它还保存每个客户端的当前状态



## 拦截器 

* 拦截器 Interceptors 是 DirectoryService 的特定功能，负责处理特定任务
* DirectoryService 接收的请求都将交由 Interceptors 处理，处理完成后再进入后端程序
* 拦截器可以禁用也可以启用，也可以添加新的拦截器



### 处理操作

以下为拦截器可以操作的子集：

|   Operation   |       Description        |
| :-----------: | :----------------------: |
|      add      |    添加 Entry 到后端     |
|     bind      |    添加绑定到目录服务    |
|    compare    | 将元素和后端元素进行比较 |
|    delete     |        删除 entry        |
|   getRooDSE   |     获取根节点 entry     |
|   hasEntry    |   告知 entry 是否存在    |
|    lookup     |        获取 entry        |
|    modify     |        修改 entry        |
|     move      |        移动 entry        |
| moveAndRename |    移动和重命名 entry    |
|    rename     |       重命名 entry       |
|    search     |       搜索 entries       |
|    unbind     |    跟目录服务解除绑定    |



### 已存在拦截器

以下拦截器已经存在服务中，但有些默认未启用，如下：

|            Interceptor            | Enabled | add  | bnd  | cmp  | del  | DSE  | has  | lkp  | mod  | mov  | m&r  | ren  | sea  | ubd  |
| :-------------------------------: | :-----: | :--: | :--: | :--: | :--: | :--: | :--: | :--: | :--: | :--: | :--: | :--: | :--: | :--: |
|    AciAuthorizationInterceptor    |   yes   |  X   |  -   |  X   |  X   |  -   |  X   |  X   |  X   |  X   |  X   |  X   |  X   |  -   |
|  AdministrativePointInterceptor   |   yes   |  X   |  -   |  -   |  X   |  -   |  -   |  -   |  X   |  X   |  X   |  X   |  ?   |  -   |
|     AuthenticationInterceptor     |   yes   |  X   |  X   |  X   |  X   |  X   |  X   |  X   |  X   |  X   |  X   |  X   |  X   |  X   |
|       ChangeLogInterceptor        |   yes   |      |  X   |  -   |  -   |  X   |  -   |  -   |  -   |  X   |  X   |  X   |  X   |  -   |
|  CollectiveAttributeInterceptor   |   yes   |  X   |  -   |  -   |  -   |  -   |  -   |  X   |  X   |  -   |  -   |  -   |  X   |  -   |
|  DefaultAuthorizationInterceptor  |   yes   |  -   |  -   |  -   |  X   |  -   |  -   |  X   |  X   |  X   |  X   |  X   |  X   |  -   |
|     DelayInducingInterceptor      |   no    |  -   |  -   |  -   |  -   |  -   |  -   |  -   |  -   |  -   |  -   |  -   |  X   |  -   |
|         EventInterceptor          |   yes   |  X   |  -   |  -   |  X   |  -   |  -   |  -   |  X   |  X   |  X   |  X   |  -   |  -   |
|       ExceptionInterceptor        |   yes   |  X   |  -   |  -   |  X   |  -   |  -   |  -   |  X   |  X   |  X   |  X   |  -   |  -   |
|        JournalInterceptor         |   yes   |  X   |  -   |  -   |  X   |  -   |  -   |  -   |  X   |  X   |  X   |  X   |  -   |  -   |
|     KeyDerivationInterceptor      |   no    |  X   |  -   |  -   |  -   |  -   |  -   |  -   |  X   |  -   |  -   |  -   |  -   |  -   |
|     NormalizationInterceptor      |   yes   |  X   |  X   |  X   |  X   |  -   |  X   |  X   |  X   |  X   |  X   |  X   |  X   |  -   |
|    NumberIncrementInterceptor     |   yes   |  X   |  -   |  -   |  -   |  -   |  -   |  -   |  -   |  -   |  -   |  -   |  -   |  -   |
|  OperationalAttributeInterceptor  |   yes   |  X   |  -   |  -   |  X   |  -   |  -   |  X   |  X   |  X   |  X   |  X   |  X   |  -   |
|    PasswordHashingInterceptor     |   no    |  X   |  -   |  -   |  -   |  -   |  -   |  -   |  X   |  -   |  -   |  -   |  -   |  -   |
|  CryptPasswordHashingInterceptor  |   no    |  X   |  -   |  -   |  -   |  -   |  -   |  -   |  X   |  -   |  -   |  -   |  -   |  -   |
|   Md5PasswordHashingInterceptor   |   no    |  X   |  -   |  -   |  -   |  -   |  -   |  -   |  X   |  -   |  -   |  -   |  -   |  -   |
| Pkcs5s2PasswordHashingInterceptor |   no    |  X   |  -   |  -   |  -   |  -   |  -   |  -   |  X   |  -   |  -   |  -   |  -   |  -   |
| Sha256PasswordHashingInterceptor  |   no    |  X   |  -   |  -   |  -   |  -   |  -   |  -   |  X   |  -   |  -   |  -   |  -   |  -   |
| Sha384PasswordHashingInterceptor  |   no    |  X   |  -   |  -   |  -   |  -   |  -   |  -   |  X   |  -   |  -   |  -   |  -   |  -   |
| Sha512PasswordHashingInterceptor  |   no    |  X   |  -   |  -   |  -   |  -   |  -   |  -   |  X   |  -   |  -   |  -   |  -   |  -   |
|   ShaPasswordHashingInterceptor   |   no    |  X   |  -   |  -   |  -   |  -   |  -   |  -   |  X   |  -   |  -   |  -   |  -   |  -   |
|  Smd5PasswordHashingInterceptor   |   no    |  X   |  -   |  -   |  -   |  -   |  -   |  -   |  X   |  -   |  -   |  -   |  -   |  -   |
| Ssha256PasswordHashingInterceptor |   no    |  X   |  -   |  -   |  -   |  -   |  -   |  -   |  X   |  -   |  -   |  -   |  -   |  -   |
| Ssha384PasswordHashingInterceptor |   no    |  X   |  -   |  -   |  -   |  -   |  -   |  -   |  X   |  -   |  -   |  -   |  -   |  -   |
| Ssha512PasswordHashingInterceptor |   no    |  X   |  -   |  -   |  -   |  -   |  -   |  -   |  X   |  -   |  -   |  -   |  -   |  -   |
|  SshaPasswordHashingInterceptor   |   no    |  X   |  -   |  -   |  -   |  -   |  -   |  -   |  X   |  -   |  -   |  -   |  -   |  -   |
|        ReferralInterceptor        |   yes   |  X   |  -   |  -   |  X   |  -   |  -   |  -   |  X   |  X   |  X   |  X   |  -   |  -   |
|         SchemaInterceptor         |   yes   |  X   |  -   |  X   |  -   |  -   |  -   |  X   |  X   |  -   |  ?   |  X   |  X   |  -   |
|        SubentryInterceptor        |   yes   |  X   |  -   |  -   |  X   |  -   |  -   |  ?   |  X   |  X   |  X   |  X   |  X   |  -   |
|         TimerInterceptor          |   no    |  X   |  X   |  X   |  X   |  X   |  X   |  X   |  X   |  X   |  X   |  X   |  X   |  X   |
|        TriggerInterceptor         |   yes   |  X   |  -   |  -   |  X   |  -   |  -   |  -   |  X   |  X   |  X   |  X   |  -   |  -   |



### 拦截器执行顺序

顺序决定拦截器什么时候执行：

| Order |           Interceptor           |
| :---: | :-----------------------------: |
|   1   |    NormalizationInterceptor     |
|   2   |    AuthenticationInterceptor    |
|   3   |       ReferralInterceptor       |
|   4   |   AciAuthorizationInterceptor   |
|   5   | DefaultAuthorizationInterceptor |
|   6   | AdministrativePointInterceptor  |
|   7   |      ExceptionInterceptor       |
|   8   |        SchemaInterceptor        |
|   9   | OperationalAttributeInterceptor |
|  10   |       SubentryInterceptor       |
|  11   |        EventInterceptor         |
|  12   |       TriggerInterceptor        |
|  13   |      ChangeLogInterceptor       |
|  14   |       JournalInterceptor        |



### 处理过程

* 拦截器接收请求，进行预处理，调用下一个拦截器，进行后处理，并且返回结果
* 下一个拦截器的执行过程和前者一样，只是拦截逻辑不同
* 每一个操作都被传递到 OperationContext 对象中，它包含操作和环境的所有内容



## 后端

目前我们有 3 种不同的后端：

* JDBM：JDBM 后端使用 BTrees 将数据存储在磁盘上。检索数据时速度很快，而添加数据时速度较慢
* LDIF：它有两种形式：一种是单文件，另一种是多个文件
* In-Memory：此后端在内存中加载一组完整的条目。所有这些都必须由现有内存保存，我们不在磁盘上写入任何内容，也不从磁盘上读取任何内容。如果服务器停止，一切都将丢失



关于未来的后端的展望：

* 我们打算添加另一个内存后端，基于 Mavibot，一个 MVCC BTREE
* 与其他系统相比，最大的优势是速度快，在处理某些写入操作时，当其他后端阻止读取时，它允许并发读取，而无需锁定。此外，它定期将内容保存在磁盘上，并有一个日志，以便我们可以从崩溃中恢复。
* 唯一的缺点是所有条目和索引都必须保存在内存中。另一方面，我们不再需要缓存。



如何工作 ？

* 每个后端实例都继承自 AbstractBTreePartition 类。我们可以看到后端必须是 BTree
* MasterTable 包含所有序列化的条目，此表是一个<Key，Value>BTree，其中键是条目的 UUID
* 