# 前言
大多对质量有要求的项目，都会要求代码前进行代码风格检查、单元测试。如果每次都手动执行命令检查，那么费时费力不说，也会降低工作效率。

既然我们提交代码都要经过 git 的 `commit`、`push` 那么何不把代码风格集成到 `git` 里面自动检查，既保证工作效率又保证质量

接下来我们使用 `git hook` 将代码风格检查和单元测试接入到提交代码中，我们通过以下 5 步可以完成：
1. 创建代码风格执行脚本
2. 创建单元测试执行脚本
3. 创建 commit 预加载文件
4. 创建 push 预加载文件
5. 创建 一键安装脚本，方便他人使用

---

## 创建代码风格执行脚本
下面，我们从第一步开始 <br>
我们创建代码风格执行脚本：run-rubocop.bash
```ruby
#!/usr/bin/env bash

set -e

cd "${0%/*}/.."

echo "Running rubocop standardrb"
bundle exec standardrb
```
脚本很简单，输出一段提示语，然后执行检查代码风格的指令，这里我用的是 Ruby，你可以替换为成自己语法的检查代码风格指令


---

## 创建单元测试执行脚本
然后下一步，创建单元测试执行脚本，创建文件：run-tests.bash 

```ruby
#!/usr/bin/env bash

set -e

cd "${0%/*}/.."

echo "Running tests"
bundle exec rspec
```

---

## 创建 commit 预加载文件
检查脚本创建好后，我们创建预加载文件：pre-commit.bash <br>
```ruby
#!/usr/bin/env bash

echo "Running pre-commit hook"
./scripts/run-rubocop.bash

# $? stores exit value of the last command
if [ $? -ne 0 ]; then
 echo "Code must be clean before commiting"
 exit 1
fi
```
它可以让你在执行 `git commit ` 前执行指定的脚本文件，因为指向刚才创建的 run-rubocop.bash 
所以我们可以在提交代码前，自动执行**代码风格检查**

---

## 创建 push 预加载文件

一些比较重要的检查项，可以放到 `git push` 前处理，例如单元测试就比较合适 <br>
我们先创建 push 预加载文件：
```ruby
#!/usr/bin/env bash

echo "Running pre-push hook"
# ./scripts/run-brakeman.bash
./scripts/run-tests.bash

# $? stores exit value of the last command
if [ $? -ne 0 ]; then
 echo "Brakeman and Tests must pass before pushing!"
 exit 1
fi
```
以上代码执行执行，我们刚才创建的 run-tests.bash 脚本，所以我们就实现了在 `git push` 前 git 会自动帮我们执行单元测试检查，如果代码有问题，提交就不会通过

---

### 创建 一键安装脚本，方便他人使用

最后的最后，以上脚本只需要创建一次，然后放在项目的 /scripts 目录下，以后的小伙伴**只需要执行一行命令，就可以让本地环境支持提交自动检查的功能**，<br>
我们创建 install-hooks.bash 脚本文件，内容如下：
```ruby
#!/usr/bin/env bash

GIT_DIR=$(git rev-parse --git-dir)

echo "Installing git hooks..."
# this command creates symlink to our pre-commit script
ln -s ../../scripts/pre-commit.bash $GIT_DIR/hooks/pre-commit
ln -s ../../scripts/pre-push.bash $GIT_DIR/hooks/pre-push
echo "Done!"
```
以上脚本就是把我们刚才创建的 `pre-commit`、`pre-push` 加载到 `git hook` 中，这样就完成自动提交检查了。

运行该脚本需要2步骤：
```ruby
# 设置 scripts 执行权限
chmod +x scripts/*bash

# 安装自检脚本
./scripts/install-hooks.bash

Installing hooks...
Done!
```

