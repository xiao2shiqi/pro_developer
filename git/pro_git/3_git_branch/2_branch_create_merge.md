# git merge 的两种模式： Fast-forward 和 no-Fast-forward

### 前言
`git merge` 应该是开发者最常用的 git 指令之一，
默认情况下你直接使用 `git merge` 命令，没有附加任何选项命令的话，那么应该是交给 git 来判断使用哪种 merge 模式，实际上 git 默认执行的指令是 `git merge -ff` 指令（默认值）

对于专业的开发者来说，你可能无须每次合并都指定合并模式（如果需要的话还是要指定的），但是你可能需要知道 git 在背后为你默认做了什么事情，这样才能保证你的代码万无一失。

### 先说说什么是 Fast-forward

我们从一个正常开发流程来看看：

开发者小王接到需求任务，从 master 分支中创建功能分支，git 指令如下：
```console
git checkout -b feature556
Switched to a new branch 'feature556'
```

小王在 feature556 分支上完成的功能开发工作，然后产生1次 commit，
```console
git commit -am 'Create pop up effects'
```


关于 --ff, --no-ff, --ff-only 三种模式的官方说明：
> Specifies how a merge is handled when the merged-in history is already a descendant of the current history.  --ff is the default unless merging an annotated (and possibly signed) tag that is not stored in its natural place in the refs/tags/ hierarchy, in which case --no-ff is assumed. 

> With --ff, when possible resolve the merge as a fast-forward (only update the branch pointer to match the merged branch; do not create a merge commit). When not possible (when the merged-in history is not a descendant of the current history), create a merge commit.

> With --no-ff, create a merge commit in all cases, even when the merge could instead be resolved as a fast-forward.

> With --ff-only, resolve the merge as a fast-forward when possible. When not possible, refuse to merge and exit with a non-zero status.