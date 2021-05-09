# 使用 reduce 实现合计数组：sum

sum = 0
(0..5).each do |e|
  sum += e
end
p sum


def sum(enum)
  enum.reduce(0) do |accumlator, element|
    accumlator + element
  end
end

array = (0..5)
p "method sum: #{sum(array)}"

# reduce 简便的写法
def sum_simple(enum)
  enum.reduce(0, :+)
end
p "method sum_simple: #{sum_simple(array)}"


p "array #{(0..5).to_a}"
# Array 使用 map 构建一个自定义 Hash
ary_hash = Hash[
  array.map do |x| 
    [x, true] 
  end
]
p "array map build hash: #{ary_hash}"

# Array 使用 reduce 构建一个自定义 Hash
# {} 声明 hash 的初始值，否则 update 没有 update 方法
ary_hash = array.reduce({}) do |hash, element|
  hash.update(element => true)
end
p "array reduce build hash: #{ary_hash}"

# 使用 reduce 实现 select 
# 构建 user 对象
user = Struct.new(:name, :age)
users = [user.new("phoenix", 19), user.new("jack", 21), user.new("tom", 23)]
# 选择 age > 21 的对象
names = users.select {|u| u.age >= 21}.map{|u| u.name}
p names
# out: ["jack", "tom"]

names = users.reduce([]) do |names, user|
  names << user.name if user.age >= 21
  names
end
p names