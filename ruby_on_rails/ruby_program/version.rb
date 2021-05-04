class Version
    attr_reader(:major, :minor, :patch)

    def initialize(version)
        @major, @minor, @patch = 
        version.split('.').map(&:to_i)
    end

    def <=> (other)
        return nil unless other.is_a?(Version)

        [ major <=> other.major,
          minor <=> other.minor,
          patch <=> other.patch,
        ].detect { |n| !n.zero?} || 0
    end
end

vs = %w(1.0.0 1.11.1 1.9.0).map { |v| Version.new(v)}
p vs

# 尝试对对象进行排序，结果却报错了 `sort': comparison of Version with Version failed (ArgumentError)
vs.sort
p vs

overlapping