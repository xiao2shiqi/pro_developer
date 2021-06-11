最近在 LeetCode 上刷题，对于 ``链表`` 类型的题目刷的比较多，所以打算写一篇文章，分享一下练习链表类型题目的思考和心得



众所周知，玩链表就是玩指针，所以找了一道比较典型也是非常热门的题目跟大家分享，**如何反转一个单向链表**  LeetCode #206 也是很热门的一道编程题 [LC#206 Reverse Linked List](https://leetcode-cn.com/problems/reverse-linked-list/)  ，题目描述如下：

![vJapet](https://pcloud-1258173945.cos.ap-guangzhou.myqcloud.com/uPic/vJapet.png)



##### 解题理论：

想要反转一个单向链表，除了当前的 head 指针外，我们还另外需要两个辅助指针：

* preNode 用于保存上一个引用的指针
* nextNode 用于保存下一个引用的指针



不管你使用什么编程语言，反转链表的公式都是一样的，主要分为以下四步：

1. 将当前 head 引用的 next 引用传递给 nextNode 
2. 将当前 preNode 引用赋值给 head.next 实现反转（重要）
3. 移动 preNode 指针，准备进行下一次反转
4. 移动 head 指针，准备进行下一次反转



##### 图解数据结构

上面代码和文字描述看上去可能不太直观，我们下面通过图文的形式展示一个单向链表是如何被反转的

单向链表的初始状态：

![step 0](https://pcloud-1258173945.cos.ap-guangzhou.myqcloud.com/uPic/9Op3SJ.png)



然后我们第一步，开始初始化指针，

```java
ListNode next, pre = null
```

然后，执行第一步切换指引的代码：

```java
next = head.next;
```

这时候链表和指针的位置改变如下图：

![step 1](https://pcloud-1258173945.cos.ap-guangzhou.myqcloud.com/uPic/MpVVX8.png)



当执行第二步代码：

```java
head.next = pre;
```

这时候链表内的指针发生了如下的变化：

![step 2](https://pcloud-1258173945.cos.ap-guangzhou.myqcloud.com/uPic/yib8gf.png)



这里可以看到 **head 引用的 next 指向已经发生的反转变化** ，这一步也是反转链表最重要的一步

后面第三步，第四步就是移动 preNode，head 指针，准备为下一次元素反转做准备了

第三步代码：

```java
pre = head;
```

如图：

![step 3](https://pcloud-1258173945.cos.ap-guangzhou.myqcloud.com/uPic/d2hXyW.png)

这时候 preNode 已经跟 head 头指针指向同一个节点，准备为下一次反转做准备



第四步代码：

```java
head = next;
```

看到这里大家发现 nextNode 指针其实作用不大，就是帮助 head 同学临时占一个位置的，反转指针主要依靠 preNode 和 head，反转完成后如何：

![step 4](https://pcloud-1258173945.cos.ap-guangzhou.myqcloud.com/uPic/2eIW9c.png)





##### 写代码

理论讲完了，对代码有兴趣的同学可能会觉得很枯燥，我们直接上代码：

使用 Java 语言表示的代码如下：

```java
public static ListNode reverseList(ListNode head) {
    ListNode next, pre = null;
    while (head != null) {
        next = head.next;
        head.next = pre;
        pre = head;
        head = next;
    }
    return pre;
}
```



因为动态语言允许交叉赋值，所以使用动态语言反转链表就更加的简单，代码如下：

```ruby
def reverse_list(head)
    while(head != nil) 
        cur_next, head.next, pre = head.next, pre, head
        head = cur_next
    end
    pre
end
```



执行到这里，元素 1 已经被反转过来的，只需要将以上四步执行 N 次，就可以将一个长度为 N 的链表全部反转，所以这套解法的时间复杂度就是 O（n），最后只要提交代码，你就能打败全国 90%的对手，不信的话可以打开 [LeetCode](https://leetcode-cn.com/problems/reverse-linked-list/submissions/) 把代码复制过去试试提交一下代码看看  (●—●)



![打败 96% 的用户](https://pcloud-1258173945.cos.ap-guangzhou.myqcloud.com/uPic/5uTYuX.png)



##### 总结

这道题非常简单，如果你是老手的话就当帮你回顾一下反转链表的解题思路，如果你是新手的话说不定能帮忙打开算法世界的大门，觉得文章不错的话，可以分享给朋友，最后再留一个问题，可以思考一下：

* 为什么最终返回的指针是 preNode， 而不是 head ？

