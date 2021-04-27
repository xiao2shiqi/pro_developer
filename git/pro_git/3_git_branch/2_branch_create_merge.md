# git merge 的两种模式： Fast-forward 和 no-Fast-forward

### 前言
`git merge` 应该是开发者最常用的 git 指令之一，
默认情况下你直接使用 `git merge` 命令，没有附加任何选项命令的话，那么应该是交给 git 来判断使用哪种 merge 模式，实际上 git 默认执行的指令是 `git merge -ff` 指令（默认值）

对于专业的开发者来说，你可能无须每次合并都指定合并模式（如果需要的话还是要指定的），但是你可能需要知道 git 在背后为你默认做了什么事情，这样才能保证你的代码万无一失。

### 先说说什么是 Fast-forward

我们从一个正常开发流程来看看：

开发者小王接到需求任务，从 master 分支中创建功能分支，git 指令如下：
```shell
git checkout -b feature556
Switched to a new branch 'feature556'
```

小王在 feature556 分支上完成的功能开发工作，然后产生1次 commit，
```shell
git commit -m 'Create pop up effects'
[feature556 6104106] create pop up effects
 3 files changed, 75 insertions(+)
```

我们再更新一下 README 自述文件，让版本差异更明显一些
```shell
git commit -m `updated md`
```

这时候我们看看当前分支的 git 历史记录，输入 `git log --online -all` 可以看到全部分支的历史线：
```shell
f2c9c7f (HEAD -> feature556) updated md
6104106 create pop up effects
a1ec682 (origin/main, origin/HEAD, main) import dio
c5848ff update this readme
8abff90 update this readme
```

直接看下图可能会更好理解一些
![git-flow-fast-forward](https://pcloud-1258173945.cos.ap-guangzhou.myqcloud.com/uPic/xkrZa4.png)

功能完成后自然要上线，我们把代码合并，完成上线动作，代码如下
```shell
git checkout master
git merge feautre556
Updating a1ec682..38348cc
Fast-forward
  .......  | 2+++
 1 file changed, 2 insertions(+)
```

如果你注意上面的文字的话，你会发现 git 帮你自动执行了 `Fast-forward` 操作，那么什么是 `Fast-forward` ？ 
`Fast-forward` 是指 Master 合并 Feature 时候发现 Master 当前节点一直和 Feature 的根节点相同，没有发生改变，那么 Master 快速移动头指针到 Feature 的位置，所以 **Fast-forward 并不会发生真正的合并**，只是通过移动指针造成合并的假象，这也体现 git 设计的巧妙之处。合并后的分支指针如下：
![merge-Fast-forward](https://pcloud-1258173945.cos.ap-guangzhou.myqcloud.com/uPic/N5wea3.png)

通常功能分支（feature556） 合并 master 后会被删除，通过下图可以看到，通过 `Fast-forward` 模式产生的合并可以产生**干净并且线性的历史记录**：
![remove-feature556](https://pcloud-1258173945.cos.ap-guangzhou.myqcloud.com/uPic/sKocLW.png)


关于 --ff, --no-ff, --ff-only 三种模式的官方说明：
> Specifies how a merge is handled when the merged-in history is already a descendant of the current history.  --ff is the default unless merging an annotated (and possibly signed) tag that is not stored in its natural place in the refs/tags/ hierarchy, in which case --no-ff is assumed. 

> With --ff, when possible resolve the merge as a fast-forward (only update the branch pointer to match the merged branch; do not create a merge commit). When not possible (when the merged-in history is not a descendant of the current history), create a merge commit.

> With --no-ff, create a merge commit in all cases, even when the merge could instead be resolved as a fast-forward.

> With --ff-only, resolve the merge as a fast-forward when possible. When not possible, refuse to merge and exit with a non-zero status.