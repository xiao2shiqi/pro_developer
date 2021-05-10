require('forwardable')

class RaisingHash

  extend(Forwardable)
  include(Enumerable)

  # 定义实例，转发目标
  def_delegators(:@hash, :[], :[]=, :delete, :each,
   :keys, :values, :length,
   :empty?, :has_key?
   )

   # 将 RasisingHash#erase! 方法转发 @hash.delete 可以这样使用 def_delegator:
   # forward self.erase! to @hash.delete
   def_delegator(:@hash, :delete, :erase!)

   def initialize
    @hash = Hash.new do |hash, key|
      raise(KeyError, "invalid key '#{key}'! ")
    end
   end

   def invert
    other = self.class.new
    other.replace!(@hash.invert)
    other
   end

   protected
   def replace! (hash)
    hash.default_proc = @hash.default_proc
    @hash = hash
   end

end

# raising_hash = RaisingHash.new
# raising_hash[:name] = "phoenix"
# raising_hash[:age] = 31
# p raising_hash