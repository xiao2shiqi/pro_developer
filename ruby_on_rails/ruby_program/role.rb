require 'set'

class Role
  def initialize(name, permissions)
      @name, @permissions = name, Set.new(permissions)
  end

  def can?(permission)
    # 使用 哈希查询，时间复杂度 O(1)
    @permissions.include?(permission)
  end
end


admin = Role.new("admin", ["add", "edit", "delete", "query"])
p admin.can?("add")