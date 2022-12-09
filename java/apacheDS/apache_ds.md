# Apache Directory Project

使用 Java 编写的目录解决方案，包含目录服务器，该项已被 `Open Group` 组织认定为符合 LDAP v3 标准，还有基于 Eclipse 构建的目录工具 `Apache Directory Studio`



## Apache DS 目录服务

Apache DS 完全用 Java 编写的目录服务器（可扩展，可嵌入），已被 `Open Group` 组织认定为 LDAPv3 兼容，除了 LDAP，它还支持 `Kerberos 5` 和更改密码协议，它旨在将触发器、存储过程、队列和视图引入缺少这些丰富结构的LDAP世界。



它主要的特点有：

* 被 open group 认证为兼容 LDAPv3 标准
* Kerberos Server Built-in 绑定
* PassWord Policy Support 密码策略支持
* 嵌入 Java 应用：对 Java 开发者友好
* Full X500 Authorization：
* Multi-Master Replication 多副本复制
* 基于 LDIF 配置
* 多平台：支持 Linux, Mac OS X, Windows 等等



### 基本用户指南

LDAP 是一项复杂的技术，Apach DS（Directory Server）不仅仅提供 LDAP 服务，因此我们先通过快速开始来掌握它。



#### 1 如何开始

本示例讲解如何通过最少的配置，让服务器快速的运行



##### 1.1 什么是服务服务

愿景：

* Apache DS 是 LDAP 服务器
* 可嵌入：嵌入到 Java 应用程序中，配置，启动和停止它，可嵌入意味着你可以选择你喜欢的方式部署它
* 可扩展：可以编写自己的分布来存储目录数据，编写拦截器来添加功能
* 符合标准：遵守 LDAPv3 相关的所有 RFC
* 现代化：在遵循标准之上，构建的丰富的集成，例如 LDAP 存储过程和触发器
* 跨平台：完全用 Java 编写，天然具有跨平台能力



Apache DS 体系结构：

![50k 英尺建筑](./assets/50k-ft-architecture.png)





### 高级用户指南



### 开发指南



### Kerberos 用户指南



### 配置参考



### Java 文档



### 参考文档









## Apache Directory Studio

Apache Directory Studio 是一个目录服务工具，特别适用于 ApacheDS，它是一个 Eclipse RCP 应用程序，由 Eclipse OSGI 插件组成，这些插件可以轻松升级，这些插件运行在 Eclipse 内部



## Apache LDAP API

Version：

* 1.0.3
* 2.1.2



The Apache Directory LDAP API is an ongoing effort to provide an enhanced LDAP API, as a replacement for JNDI and the existing LDAP API (jLdap and Mozilla LDAP API). This is a "schema aware" API with some convenient ways to access all types of LDAP servers, not only ApacheDS but any LDAP server. The API is OSGI ready and extensible. New controls, schema elements and network layer could be added or used in the near future.



LDAP API （主要还是用于 ApacheDS），Spring 也有类型的 LDAP RestTemplate



## Apache Mavibot

Mavibot™ is a *Multi Version Concurrency Control* (MVCC) BTree in Java. It is expected to be a replacement for JDBM (The current backend for the Apache Directory Server), but could be a good fit for any other project in need of a Java MVCC BTree implementation.



Mavibot 是 Java 中的多版本并发控制（MVCC）BTree。它有望取代JDBM（Apache Directory Server的当前后端），但可能非常适合需要Java MVCC BTree实现的任何其他项目。



## Apache Kerby

Apache Kerby™ is a Java Kerberos binding. It provides a rich, intuitive and interoperable implementation, library, KDC and various facilities that integrates PKI, OTP and token (OAuth2) as desired in modern environments such as cloud, Hadoop and mobile.



Apahce Kerby 是 Java Kerberos 绑定。它提供了丰富、直观和可互操作的实现、库、KDC和各种设施，可根据现代环境（如云、Hadoop和移动）的需要集成PKI、OTP和令牌（OAuth2）。



## Apache Fortress

Apache Fortress™ is a standards-based authorization system that provides attribute and role-based access control, delegated administration and password policy services using an LDAP backend.



Apache Fortress 是一个基于标准的授权系统，它使用 LDAP 后端提供属性和基于角色的访问控制、委派管理和密码策略服务。

