array = [1, 2, 3, 4, 5]

hash_res = array.reduce({}) do |hash, element|
  # 没有默认值，使用 Hash 战战兢兢，随时担心出现 NoMethodError
  # 使用防御式编程： hash[element] ||= 0 来获得安全感
  hash[element] ||= 0
  hash[element] += 1
  hash
end
p hash_res

# 如果构建 Hash 的时候初始化默认值，那么使用 Hash 就会放心很多，代码如下：
hash_res = array.reduce(Hash.new(0)) do |hash, element|
  # 因为有默认值，不会担心出现 NoMethodError
  hash[element] += 1
  hash
end
p hash_res

# 使用 fetch 来解决找不到键和初始化默认值的情况
hash_res = array.reduce({}) do |hash, element|
  # 因为有默认值，不会担心出现 NoMethodError
  hash[element] = hash.fetch(element, 0) + 1
  hash
end
p hash_res