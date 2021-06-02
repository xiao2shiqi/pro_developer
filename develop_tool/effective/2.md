

##### 基于 P3C 编译 PMD 可执行文件

下载阿里巴巴 p3c 源码：

```shell
git clone  https://github.com/alibaba/p3c
```

进入 p3c-pmd 目录编译 kotlin 源码（需要提前安装 maven）

```shell
cd p3c-pmd
mvn clean kotlin:compile package
```

编译完成后开始打包工程，执行命令

```shell
mvn package
```

执行成功后在，p3c-pmd/target/ 目录可以看到 p3c-pmd-2.x.x-jar-with-dependencies.jar 包即可

<img src="https://pcloud-1258173945.cos.ap-guangzhou.myqcloud.com/uPic/bdyuBA.png" alt="bdyuBA" style="zoom:50%;" />

在当前目录（p3c-pmd/target/）下执行即可检查 Jar 是否运行正常

```shell
java -cp p3c-pmd-2.0.1-jar-with-dependencies.jar net.sourceforge.pmd.PMD -d {代码路径} -R rulesets/java/ali-comment.xml
```

<img src="https://pcloud-1258173945.cos.ap-guangzhou.myqcloud.com/uPic/yJo4TN.png" alt="yJo4TN" style="zoom:50%;" />



#####  PMD 加入 Git hook 实现提交自动检查

将工具包复制到你项目的 .git/hooks/ 目录下，如图：

![gzn2Bd](https://pcloud-1258173945.cos.ap-guangzhou.myqcloud.com/uPic/gzn2Bd.png)



然后创建 pre-commit，并且加入检查代码，具体如下：

```shell
vim pre-commit
```

pre-commit 预检查脚本：

```shell
REJECT=0

java -cp .git/hooks/p3c-pmd-2.1.1-jar-with-dependencies.jar net.sourceforge.pmd.PMD -d {扫描的代码路径} -R rulesets/java/ali-comment.xml,rulesets/java/ali-concurrent.xml,rulesets/java/ali-constant.xml,rulesets/java/ali-exception.xml,rulesets/java/ali-flowcontrol.xml,rulesets/java/ali-naming.xml,rulesets/java/ali-oop.xml,rulesets/java/ali-orm.xml,rulesets/java/ali-other.xml,rulesets/java/ali-set.xml 2>/dev/null
REJECT=$?
echo $REJECT
exit $REJECT
```

将 pre-commit 更新为可执行文件

```shell
chmod 777 pre-commit
```



最后回到根目录执行 git commit -am 'update' 会发现 p3c 自动检查，不通过无法提交：

<img src="https://pcloud-1258173945.cos.ap-guangzhou.myqcloud.com/uPic/zJoQ9L.png" alt="zJoQ9L" style="zoom:50%;" />