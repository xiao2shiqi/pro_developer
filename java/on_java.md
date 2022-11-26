## 二十四：并发编程

本章节仅仅作为入门学习，如果需要深入理解并发编程，推荐书籍：

1. 深入理解并发编程需要阅读 《Java concurrency in Parctice》 Brian Goetz  （该书已经有十多年的历史了）
2. 学习 JVM 推荐书籍《Inside the Java Virtual Machine》 Bill Venner



术语问题：

1. 并发：同时完成多任务，无需等待当前任务完成即可执行其他任务，**解决 I/O 密集型任务**
2. 并行：同时在多个位置完成多任务，**解决 CPU 密集型任务**



作者对于 Java 8 并发的忠告：

> 尽管 Java 8 在并发方面做出很大的改进，但仍然没有像编译时验证（compile-time verifcation）或受检查的异常（checked exceptions）那样的安全网告诉你何时出现错误。
>
> 通过并发，你只能依靠自己，只有知识渊博，保持怀疑和积极进取的人，才能用 Java 编写可靠的并发代码

总结：你应该谨慎的使用这些强大的力量（来自阿尔萨斯的父亲）



### 并发为速度而生

重点摘要：

1. 不要随意使用并发编程，除非你的程序不够快，使用前要仔细思考，只有在没有选择的时候，再使用它（它并不是解决问题的首选）
2. 并发会带来成本，包括复杂性成本，但可以通过程序设计，资源平衡和用户便利性的改进来抵消 （使用复杂度来抵消复杂度）



### 四句格言

一：不要这样做

1. 如无必要，尽量不要用并发
2. 如果速度不够快，先分析它的原因，再针对性的进行优化
3. 如果逼不得已使用并发，请使用最简单和最安全的方式来解决问题（使用现有的库，而不是自己去创造）



二：没有确定性，一切可能有问题

1. 没有并发编程的世界，一切都是有序和准确的
2. 在并发的领域，一切都不会按照你期望的工作，会有很多的不确定性
3. 使用并发，你需要处理很多额外的复杂型问题，例如：处理器缓存和本地缓存的一致性，需要深入理解对象的构造，等等
4. 深入并发领域太复杂，通过《Java concurrency in Parctice》书籍可以为你提供更多专业知识



三：它起作用，并不意味着它没有问题

1. 你不能证明它是正确的，你只能证明它是不正确的
2. 如果它有问题，大多数情况下，你可能无法检测到它
3. 你不能为并发编写有效的测试，只能依靠代码检查和渊博的并发知识来发现错误
4. 进入并发编程领域容易遇到 [Dunning-Kruger 效应](https://wiki.mbalib.com/wiki/邓宁-克鲁格效应) 认知偏差，就是不熟练的人拥有着虚幻的优越感
5. 在并发领域，最糟糕的表现就是 “自信”



![邓宁-克鲁格效应](./assets/500px-邓宁-克鲁格效应.jpg)



四：你必须仍然理解

1. 你不能逃脱使用并发，因为它无处不在，例如：Swing 界面库，Spring 框架，Tomcat 容器，或者像 Timer 那样简单的东西，
2. 在你接触的东西里，都存在并发编程，所以你必须要理解它



### 残酷的真相

1. 在互联网的竞速比赛中，Java 的体系充斥着糟糕的决策，例如 Vector，Thread 类等等（并且只能通过建议，告诉别人不要使用这些）
2. Java 不再是为并发而设计的语言，而是一种允许并发的语言
3. Java 8 中的并行流和 CompletableFutures 是惊人的史诗级变化



### 并行流

Java 8 流的显著优先，就是很容易的进行并行化，只要使用 `.parallel()` 就会产生魔法般的结果

看看以下的示例，感受并行的威力：

```java
public class ParallelPrime {
    
    static final int COUNT = 100_000;
    
    public static boolean isPrime(long n) {
        return LongStream.rangeClosed(2, (long) Math.sqrt(n)).noneMatch(i -> n % i == 0);
    }

    public static void main(String[] args) throws IOException {
        long start = System.currentTimeMillis();
        LongStream.iterate(2, i -> i + 1)
                .parallel()			// open parallel	
                .filter(ParallelPrime::isPrime)
                .limit(COUNT)
                .mapToObj(Long::toString)
                .collect(Collectors.toList());
        
        System.out.println("time consuming:" + (System.currentTimeMillis() - start));
    }
}
```

以上代码输出结果如下：

```sh
time consuming: 220			// use parallel
time consuming: 317			// not use parallel
```

`paraller()` 并行确实有效，明显了加快的程序的运行速度。



再来看一个使用不同的方式进行求和的示例代码：

```java
public class Summing {

    static void timeTest(String id, long checkValue, LongSupplier operation) {
        System.out.print(id + ": ");
        Timer timer = new Timer();
        long result = operation.getAsLong();
        if (result == checkValue) {
            System.out.println(timer.duration() + "ms");
        } else {
            System.out.format("result : %d%ncheckValue: %d%n", result, checkValue);
        }
    }

    public static final int SZ = 100_000_000;
    public static final long CHECK = (long)SZ * ((long)SZ + 1)/2;       // gauss's formula  高斯公式

    public static void main(String[] args) {
        System.out.println(CHECK);
        // 非并行计算性能也不错 Sum Stream: 33ms
        timeTest("Sum Stream", CHECK, () ->
                LongStream.rangeClosed(0, SZ).sum()
        );
        // 使用并行计算速度则更快 Sum Stream Parallel: 14ms
        timeTest("Sum Stream Parallel", CHECK, () ->
                LongStream.rangeClosed(0, SZ).parallel().sum()
        );
        // 使用 iterate 减速则很明显 Sum Iterated: 81ms
        timeTest("Sum Iterated", CHECK, () ->
                LongStream.iterate(0, i -> i + 1).limit(SZ + 1).sum()
        );
    }
}
```

程序运行的结果如下：

```sh
5000000050000000
Sum Stream: 33ms
Sum Stream Parallel: 14ms
Sum Iterated: 81ms
```

通过以上示例，可以对使用并行流有一个初步的总结：

* 并行流将输入数据分成多个部分，然后进行单独计算
* 数组的分割成本低，并且分割均匀
* 并行流只看起来很容易，但在使用前，你必须了解并行性如何帮助或损害你的操作
* 流的出现并不意味着你可以不用理解并行的原理

TODO。。。



### 创建和运行任务

Java 线程的发展历：

1. 早期版本的 Java 中，你可以直接创建自己的 Thread 对象来使用线程，并且手动启动（现在不鼓励这种方式）
2. 在 Java 5 中，更推荐使用线程池 ExecutorService 来运行和管理你的任务



关于 `ExecutorService` 一个简单的示例，如下：

```java
public class SingleThreadExecutor {

    public static void main(String[] args) {
        ExecutorService exec = Executors.newSingleThreadExecutor();

        // 创建 10 个 NapTask 交给 ExecutorService 执行
        IntStream.range(0, 10)
                .mapToObj(NapTask::new)
                .forEach(exec::execute);

        System.out.println("All tasks submitted");
        
        // 等待所有任务完成
        exec.shutdown();
//        while (!exec.isTerminated()) {
//            System.out.println(Thread.currentThread().getName() + " awaiting termination");
//            new Nap(0.1);
//        }
    }
}
```

程序的输出结果：

```sh
All tasks submitted
NapTask[0] pool-1-thread-1
NapTask[1] pool-1-thread-1
NapTask[2] pool-1-thread-1
NapTask[3] pool-1-thread-1
NapTask[4] pool-1-thread-1
NapTask[5] pool-1-thread-1
NapTask[6] pool-1-thread-1
NapTask[7] pool-1-thread-1
NapTask[8] pool-1-thread-1
NapTask[9] pool-1-thread-1
```

通过以上示例，我们可以对线程池有一个初步的使用总结：

1. `ExecutorService` 创建子线程执行任务，并不会影响主线程 `main` 的工作
2. 线程池调用 `shutdown()` 将不再接受任何新任务，否则抛出 `RejectedExecutionException` 异常
3. `pool-1-thread-1` 是子线程的名字，因为使用 `newSingleThreadExecutor()` 函数，所以只会创建 1 个线程



如果想要使用更多的线程，把线程池函数改为 `newCachedThreadPool()` 即可，重新执行以上代码，输出如下：

```sh
All tasks submitted
NapTask[9] pool-1-thread-10
NapTask[7] pool-1-thread-8
NapTask[8] pool-1-thread-9
NapTask[6] pool-1-thread-7
NapTask[0] pool-1-thread-1
NapTask[5] pool-1-thread-6
NapTask[2] pool-1-thread-3
NapTask[1] pool-1-thread-2
NapTask[4] pool-1-thread-5
NapTask[3] pool-1-thread-4
```

PS：它似乎运行的更快了



既然多线程更快，那什么场景下需要使用 `newSingleThreadExecutor()` 呢 ？

先看一个示例，`InterferingTask` 类定义我们要执行的任务：

```java
public class InterferingTask implements Runnable{

    final int id;
    private static Integer val = 0;     // 多个线程会竞争这个变量

    public InterferingTask(int id) {
        this.id = id;
    }

    @Override
    public void run() {
        for (int i = 0; i < 100; i++) {
            val++;      // 每个线程为它 + 100
        }
        System.out.println(id + " " + Thread.currentThread().getName() + " " + val);
    }
}
```

然后使用多线程来执行这个任务：

```java
public class CachedThreadPool2 {

    public static void main(String[] args) {
        ExecutorService exec = Executors.newCachedThreadPool();
        IntStream.range(0, 10)
                .mapToObj(InterferingTask::new)
                .forEach(exec::execute);
        exec.shutdown();
    }
}
```

最后输出的乱七八糟的结果，如下：

```sh
0 pool-1-thread-1 131
4 pool-1-thread-5 431
2 pool-1-thread-3 231
3 pool-1-thread-4 331
1 pool-1-thread-2 131
8 pool-1-thread-9 831
7 pool-1-thread-8 731
6 pool-1-thread-7 631
5 pool-1-thread-6 531
9 pool-1-thread-10 931
```

正确结果应该是 1000，上面的程序明显算错了。

当我们把线程池函数改为 `newCachedThreadPool()` 后，再看看输出：

```sh
0 pool-1-thread-1 100
1 pool-1-thread-1 200
2 pool-1-thread-1 300
3 pool-1-thread-1 400
4 pool-1-thread-1 500
5 pool-1-thread-1 600
6 pool-1-thread-1 700
7 pool-1-thread-1 800
8 pool-1-thread-1 900
9 pool-1-thread-1 1000
```

通过以上示例，我们可以总结：

* 如果任务本身不是线程安全的，那么使用 `newSingleThreadExecutor` 函数执行任务会更安全



其他的解决思路 ？：

示例 `CachedThreadPool2` 中错误的主要原因因为变量 `val` 存在可变的共享状态。

想避免该问题，就要想办法避免可变的共享状态。



