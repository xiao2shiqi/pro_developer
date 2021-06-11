Ruby 线程跟 Java 差不多，稍微比 Java 要简单一些（不需要实现制定接口和继承指定类）

并发编程是高性能服务端程序的敲门砖，我们先看看 Ruby 中怎么玩编程编程的

PS：本文简单说一下 Ruby 多线程和同步锁的基本使用（但是并发编程的概念远远不止于此）



##### 多线程的使用



先看一段简单的代码，用常见串行的方式访问数组中的网站，我们使用 sleep 当前线程睡眠 1S ，来模拟复杂的业务逻辑处理，代码如下：

``` ruby
start = Time.now

pages = %w( www.rubychina.com www.google.com www.baidu.com www.163.com www.qq.com www.bing.com www.360.com )
threads = []
pages.each do |url|
	p "开始处理地址： #{url} "
	# 假设每个网址都需要 1S 的处理时长
	sleep 1
	p "地址 #{url} 处理完成"
end

threads.each {|thr| thr.join}

p "程序总耗时：#{Time.now - start} S"

result: "程序总耗时：7.017326"
```



这段代码很耗时，在 ruby 世界中可以使用 **Thread.new ** 创建多条线程来优化它，具体代码如下：

```ruby 
pages = %w( www.rubychina.com www.google.com www.baidu.com www.163.com www.qq.com www.bing.com www.360.com )
threads = []
pages.each do |page_to_fetch|
	threads << Thread.new(page_to_fetch) do |url|
		
		p "开始处理地址： #{url} "
		# 假设每个网址都需要 1S 的处理时长
		sleep 1
		p "地址 #{url} 处理完成"

	end
end

threads.each {|thr| thr.join}

p "程序总耗时：#{Time.now - start} S"

result: "程序总耗时：1.001011 S"
```

执行结果从 7S 提升到 1S，任务数越多，可提升的性能空间也就越大



##### 线程安全

在并发编程的场景中，可以保证共享资源在多线程环境下正常运行的方法函数，我们称为**线程安全**，不可预期结果的都称为线程不安全，我们先看看以下线程不安全的代码：

```ruby
#!/usr/bin/ruby
require 'thread'
 
class Counter 
	attr_reader :count

	def initialize
		@count = 0
	end

	def tick
		@count += 1
	end
end

c = Counter.new

t1 = Thread.new { 100000.times { c.tick } }
t2 = Thread.new { 100000.times { c.tick } }

t1.join 
t2.join

# count 因为没有锁的保护，在多线程场景下的结果不可预测，预期是 200000，很多场景仅仅只能返回 130082, 140082, 150092
# 备注：这里可能因为 ruby 版本的原因，未出现不可预期的结果，但是这种场景在大多数编程语言的多线程模型中是会出现结果错乱的，这里暂时不深究了。。
puts "count :  #{c.count}"
```



通常解决线程安全问题，我们需要引入锁的机制，在 Ruby 中通过继承 **Monitor** 类 或者引入 **MonitorMixin** 类的然后通过 **synchronize** 可以实现简单的同步锁，来保证并发模型下的线程安全，代码如下：

```ruby
require 'monitor'
 
class Counter < Monitor
	attr_reader :count

	def initialize
		@count = 0
		super
	end

	def tick
		synchronize do 
			@count += 1
		end
	end
end

c = Counter.new

t1 = Thread.new { 1000000.times { c.tick } }
t2 = Thread.new { 1000000.times { c.tick } }

t1.join 
t2.join

# 每次执行，都能得到预期结果：2000000
puts "count :  #{c.count}"
```



简单的多线程使用介绍到这里，只是一道开胃菜，并发编程的概念远远不止这么简单，更加高级的用法和特性期待大家自己的学习分享



另外一个经验分享：大多数生产场景不推荐直接使用 Thread new 创建线程，因为创建线程有内存上的开销，如果使用不当很容易发生 OOM （OutOfMemeryError），大多数场景推荐使用线程池工具，类似 java 语言在 JUC 工具包下的 Executor 线程池框架，下次有机会再分享一下线程池的设计与实现



另外抛出 2个问题，提供给大家发散思考和讨论：

1. ruby 中直接使用 Thread new 创建线程和使用  sidekiq 的区别是什么 ？sidekiq 内部是如何实现的 ？
2. 说说工作中哪些场景可以用多线程去解决并且优化 ？