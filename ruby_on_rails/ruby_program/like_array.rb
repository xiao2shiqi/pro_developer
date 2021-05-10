# extend Array
class LikeArray < Array; end

x = LikeArray.new([1, 2, 3])
p x # [1, 2, 3]

y = x.reverse
p y # [3, 2, 1]

p y.class
#=> Array ？ 为什么不是 LikeArray ? 继承 Array 导致了类型混乱

p LikeArray.new([1, 2, 3]) == [1, 2, 3]
#=> true

