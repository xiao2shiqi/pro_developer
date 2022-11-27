## 并发编程

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



#### 创建单个线程

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



#### 创建多个线程

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



#### 可变的共享变量

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



#### 使用 Callable

第一种方式，我们使用 `Callable` 让每个任务返回结果，并且我们最终合并结果，示例如下：

```java
public class CountingTask implements Callable<Integer> {

    final int id;

    public CountingTask(int id) {
        this.id = id;
    }

    @Override
    public Integer call() {
        // 每个任务执行的内容，避免可变的共享状态
        Integer val = 0;
        for (int i = 0; i < 100; i++) {
            val++;
        }
        System.out.println(id + " " + Thread.currentThread().getName() + " " + val);
        return val;
    }
}
```

然后创建线程池来并行执行任务：

```java
public class CachedThreadPool3 {

    public static Integer extractResult(Future<Integer> f) {
        try {
            // 这里的捕获只是为了避免 stream() 异常
            return f.get();
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }

    public static void main(String[] args) throws InterruptedException {
        ExecutorService exec = Executors.newCachedThreadPool();
        // 创建线程池，执行任务
        List<CountingTask> tasks = IntStream.range(0, 10)
                .mapToObj(CountingTask::new)
                .collect(Collectors.toList());

        // 阻塞：所有任务完成后，返回 Future 列表，包含所有任务运行结果
        List<Future<Integer>> futures = exec.invokeAll(tasks);
        
        // 汇总：计算所有任务的结果
        Integer sum = futures.stream()
                .map(CachedThreadPool3::extractResult)
                .reduce(0, Integer::sum);

        System.out.println("sum = " + sum);
        exec.shutdown();
    }
}
```

最终输出结果如下：

```sh
1 pool-1-thread-2 100
5 pool-1-thread-6 100
4 pool-1-thread-5 100
3 pool-1-thread-4 100
2 pool-1-thread-3 100
0 pool-1-thread-1 100
9 pool-1-thread-10 100
8 pool-1-thread-9 100
7 pool-1-thread-8 100
6 pool-1-thread-7 100
sum = 1000
```

关于示例有以下几点补充：

* 在未完成的任务调用 `Future` 上调用 `get()` 时，会阻塞到当前任务执行完成
* `invokeAll()` 甚至会在所有任务完成前都不会返回，会造成阻塞
* 这是无效的并发解决方案，本质还是同步，所以更推荐使用 Java 8 的 `CompletableFuture`



#### 使用 Stream Parallel

上面的示例有些繁琐，使用 `Stream` 可以更优雅的创建和汇总任务：

```java
public class CountingStream {

    public static void main(String[] args) {
        Integer result = IntStream.range(0, 10)
                .parallel()						// 创建并行流
                .mapToObj(CountingTask::new)	// 创建任务
                .map(ct -> ct.call())			// 执行任务
                .reduce(0, Integer::sum);		// 汇总结果

        System.out.println("result: " + result);
    }
}
```

输出结果：

```sh
9 ForkJoinPool.commonPool-worker-1 100
3 ForkJoinPool.commonPool-worker-8 100
0 ForkJoinPool.commonPool-worker-6 100
7 ForkJoinPool.commonPool-worker-4 100
5 ForkJoinPool.commonPool-worker-15 100
1 ForkJoinPool.commonPool-worker-11 100
6 main 100
8 ForkJoinPool.commonPool-worker-2 100
2 ForkJoinPool.commonPool-worker-9 100
4 ForkJoinPool.commonPool-worker-13 100
1000
```



#### 使用 Lambda 创建任务

在 Java 8 以后，使用 Lambdas 和方法引用，可以不受限制来定义自己的任务（只需要结构保持一致即可）：

```java
public class LambdasAndMethodReferences {
    
    public static void main(String[] args) {
        ExecutorService exec = Executors.newCachedThreadPool();
        // 提交自定义 Runnable 任务
        exec.submit(() -> System.out.println("Lambda1"));
        exec.submit(new NotRunnable()::go);
        // 提交自定义的 Callable 任务
        exec.submit(() -> {
            System.out.println("Lambda2");
            return 1;
        });
        exec.submit(new NotCallable()::get);    // submit callable task
        exec.shutdown();
    }
}
```

输出结果：

```sh
Lambda1
Not Runnable
Lambda2
Not Callable
```



#### 使用 Atomic 终止任务

关注中止 Runnable 和 Callable 任务的注意事项：

* Java 早期设计的任务中断机制既乱又复杂，还有可能导致数据丢失
* 任务中止的最佳方式是设置任务周期性检查标志，然后通过 `shutdown` 进程正常中止
* 中止任务使用 `boolean flag` 和 `volatile` 都存在并发和不确定性



Java 5 引入的 `Atomic` 可以帮助我们不用担心并发问题，进行任务中止：

先创建一个任务类，包含 `quit()` 函数：

```java
public class QuittableTask implements Runnable {

    final int id;

    public QuittableTask(int id) {
        this.id = id;
    }

    private AtomicBoolean running = new AtomicBoolean();

    // AtomicBoolean 可以防止多个任务同时修改 running，从而使 quit() 方法成为线程安全的
    public void quit() {
        running.set(false);
    }

    @Override
    public void run() {
        while (running.get()) {
            new Nap(0.1);
        }
        System.out.print(id + " ");
    }
}
```

然后创建多个线程执行它，看看结果：

```java
public class QuittableTasks {
    // 定义任务数量
    public static final int COUNT = 15000;

    public static void main(String[] args) {
        ExecutorService es = Executors.newCachedThreadPool();
        // 创建并且执行任务
        List<QuittableTask> tasks = IntStream.range(1, COUNT)
                .mapToObj(QuittableTask::new)
                .peek(qt -> es.execute(qt))
                .collect(Collectors.toList());
        // 主线程在这里执行
        new Nap(1);
        // 所有任务退出
        tasks.forEach(QuittableTask::quit);
        // 线程池关闭
        es.shutdown();
    }
}
```

输出结果如下：

```sh
1 5 4 2 3 6 11 7 10 8 9 13 19 18 16 23 12 17 15 14 21 32 27 26 28 24 29 22 20 39 40 33 37 34 38 36 35 51 25 48 31 30 50 59 56 57 55 58 67 53 62 70 43 52 49 77 47 44 45 46 42 41 84 79 85 86 82 80 76 90 81 73 78 102 68 74 75 65 108 109 72 71 69 66 64 63 61 117 54 60 119 125 121 118 120 131 122 112 114 115 136 113 140 107 104 110 139 111 142 100 106 105 97 101 103 93 98 99 95 94 96 92 87 83 91 89 88 148 146 149 147 135 144 145 143 141 132 138 137 127 134 133 130 128 123 129 126 116 124 
```

即使调用了退出方式，所有任务都基本运行了，所以初步观察诊断如下：

* 只要任务仍在运行，就会阻止程序退出
* 即使调用 `quit()` 方法，任务也不会按照它们创建的顺序关闭



### CompletableFuture 类

使用 `CompletableFuture` 代替 `ExecutorService` 执行任务：

```java
public class QuittingCompletable {

    public static void main(String[] args) {
        // 准备需要执行的任务
        List<QuittableTask> tasks = IntStream.range(1, QuittableTasks.COUNT)
                .mapToObj(QuittableTask::new)
                .collect(Collectors.toList());

        // 开始执行任务
        List<CompletableFuture<Void>> cfutures = tasks.stream()
                .map(CompletableFuture::runAsync)
                .collect(Collectors.toList());
        new Nap(1);

        // 开始退出任务
        tasks.forEach(QuittableTask::quit);
        // 等待所有任务运行完成
        cfutures.forEach(CompletableFuture::join);
    }
}
```

输出结果：

```sh
1 2 3 4 7 5 11 14 16 15 17 6 20 8 19 18 24 23 13 30 32 22 12 21 36 35 34 33 9 31 29 28 27 25 10 26 50 49 48 47 46 45 44 43 42 41 40 38 39 37 64 63 62 61 60 59 71 58 57 56 55 54 53 52 51 79 78 77 76 75 74 73 72 70 69 68 67 66 65 93 92 91 90 89 88 87 86 85 103 84 83 82 81 80 107 108 106 105 104 102 101 100 99 98 97 96 95 94 122 121 120 119 118 117 128 129 116 115 114 113 112 134 111 110 109 139 138 137 136 143 135 146 133 132 130 131 127 126 125 124 123 149 148 147 145 144 142 141 140 
```

关于 `CompletableFuture` 使用总结：

1. 每个任务交给 `runAsync()` 开始执行
2. 调用 `CompletableFuture.join()` 等待任务完成



#### 基本用法

首先定义一个任务类：

```java
public class Machina {

    public enum State {
        START, ONE, TWO, THREE, END;

        State step() {
            if(equals(END)) {
                return END;
            }
            return values()[ordinal() + 1];
        }
    }

    private State state = State.START;
    private final int id;

    public Machina(int id) {
        this.id = id;
    }

    // 工作就是改变状态
    public static Machina work(Machina m) {
        if(!m.state.equals(State.END)) {
            // 耗时 100ms
            new Nap(0.1);
            m.state = m.state.step();
        }
        System.out.println(m);
        return m;
    }

    @Override
    public String toString() {
        return "Machina" + id + ": " + (state.equals(State.END) ? "complete" : state);
    }
}
```

它是一个有限的状态机，从一个状态移动到下一个状态，工作耗时 100 毫秒

我们可以使用 `CompletableFuture` 处理任务，并且可以将已处理的状态转交给另一个 `CompletableFuture` 处理：

```java
public class CompletableApply {

    public static void main(String[] args) {
        CompletableFuture<Machina> cf = CompletableFuture.completedFuture(new Machina(0));
        CompletableFuture.completedFuture(new Machina(0));
        CompletableFuture<Machina> cf2 = cf.thenApply(Machina::work);
        CompletableFuture<Machina> cf3 = cf2.thenApply(Machina::work);
        CompletableFuture<Machina> cf4 = cf3.thenApply(Machina::work);
        CompletableFuture<Machina> cf5 = cf4.thenApply(Machina::work);
    }
}
```

输出结果：

```sh
Machina0: ONE
Machina0: TWO
Machina0: THREE
Machina0: complete
```

我们还可以将 `CompletableFuture` 结合 `Stream` 来使用，使编写和理解代码变的更加简单：

```java
public class CompletableApplyChained {

    public static void main(String[] args) {
        Timer timer = new Timer();
        CompletableFuture.completedFuture(new Machina(0))
                        .thenApply(Machina::work)
                        .thenApply(Machina::work)
                        .thenApply(Machina::work)
                        .thenApply(Machina::work);
        
        System.out.println(timer.duration());
    }
}
```

输出结果：

```sh
Machina0: ONE
Machina0: TWO
Machina0: THREE
Machina0: complete
460
```

上面示例展示的 `thenApply()` 同步调用，既当任务完成后才返回，所有耗时 400ms，

还有一种异步调用 `thenApplyAsync()` 可以立即返回任务列表：

```java
public class CompletableApplyAsync {

    public static void main(String[] args) {
        Timer timer = new Timer();
        CompletableFuture<Machina> cf = CompletableFuture.completedFuture(new Machina(0))
                .thenApplyAsync(Machina::work)
                .thenApplyAsync(Machina::work)
                .thenApplyAsync(Machina::work)
                .thenApplyAsync(Machina::work);

        System.out.println(timer.duration());   // 主线程并不会等待 CompletableFuture 任务
        System.out.println(cf.join());  //  在这里等待
        System.out.println(timer.duration());   // 任务真正的执行完成
    }
}
```

上面示例，如果没有调用 `join()` 函数，则主线程会提前结束任务



#### 结合 CompletableFuture

TODO 。。。。。 未完待续。。。。。
