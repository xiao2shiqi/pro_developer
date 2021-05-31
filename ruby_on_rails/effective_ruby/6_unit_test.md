### 熟悉单元测试工具 MiniTest

我的观点：

因为类似 Ruby 这样的动态语言，小小的改动都会引起想不到的问题

所以如果不写测试，**那么就是在简直是找死**




一个测试完整示例：
```ruby
# 引入测试依赖库
require('minitest/autorun')

# 测试类尽量使用 Test 结尾
class VersionTest < MiniTest::Unit::TestCase

  # 测试方法使用 test_ 开头，一般来说测试用例越小越好
  def test_major_number
    major = 2
    assert(major == 2, "major should be 2")
  end

end
```
以上展示最简单的 `assert` 方法，更多的断言方法可以参考 `MiniTest::Assertions` 模块 <br>
UT 跑完结果如下：
```
Finished in 0.000974s, 1026.6940 runs/s, 1026.6940 assertions/s.
1 runs, 1 assertions, 0 failures, 0 errors, 0 skips
```

在单元测试中消除重复的两个方法：
* 把重复的逻辑抽取到 Hel Methods 中，推荐设为 private 
* 在测试中定义 `setup` 方法，启动前加载

setup 使用方法如下：
```ruby
  def setup
    @v1 = 2
  end

  def test_major_number
    assert(@v1 == 2, "major should be 2")
  end
```

如果你有很多测试文件，而且想要经常反复运行来确保程序的正确性（这很常见），那么使用 Rake 提供一个配置文件来运行所有测试，是很常见的做法，配置如下：

```ruby
require('rake/testtask')
Rake::TestTask.new do |t|
  t.test_files = FileList['test/*_test.rb']
  t.warning = true
end
```

如果你的测试遵循命名规范，那么 Rake 会使用 FileList 自动匹配测试文件，最终在终端执行 `rake test` 所有测试就会被自动执行



几个简单的总结：

1. 测试类和测试函数要遵循 "test" 的命名规范
2. 每一个测试用例都尽可能的简单，足够简单才能成为单元，才叫单元测试
3. 使用断言 `Assert` 验证测试结果，更多断言方法可以参考模块：`MiniTest::Assertions`



### 熟悉 MiniTest 的需求测试

目前行业对于测试有两种常见的做法：

* 单元测试（unit testing）
* 需求说明测试（spec testing）



在前一章我们使用 MiniTest 讨论了单元测试，我们现在来尝试怎么使用 MiniTest 来写需求说明测试：

```ruby
require('minitest/autorun')

describe "Version Test" do
  describe("when parsing") do
    before do 
      @version = "10.8.9"
    end

    it("creates three integers") do 
      @version.must_equal("10.8.9")
    end
  end
end
```

具体使用哪种测试风格，没有好坏之分，更多取决于你的个人偏好，如果你更喜欢需求说明测试的风格 `RSpec` 对于行为驱动测试支持的更加完善



总结一下需求测试和单元测试的几点区别：

1. 需求测试使用 `describe` 描述一系列的测试行为
2. `before` 初始化也代替的 `setup` 在单元测试中加载的方式
3. 使用 `it` 定义一个测试用例
4. 更加推荐使用 `expectations` 验证结果，更多可以参考 `MiniTest::Expectations` 模块

### 力争代码被有效测试过

Ruby 作为解释型语言，只有在运行时候你才知道会发生什么，在没有运行前，甚至拼写错误都可能无法发现
例如：
```ruby
w = Widget.new
w.seed(:name)
```
你无法判 `Widget` 是否真的有 `seed` 方法

```ruby
def update (location)
  @status = location.description
end
```
阅读代码时，你会困惑 `location` 是什么？跟我们期望的类型不同怎么办 ？

所以对于 Ruby 程序员来说以上所有的问题都需要通过测试来解决，通过测试验证方法运行的逻辑正确，验证代码没有语法错误，没有拼接错误

测试总结：
* 尽可能提前写测试，测试拖的越晚，项目越难挽回
* 通过测试来寻找 bug 效率会高很多
* 尽可能的自动化测试
