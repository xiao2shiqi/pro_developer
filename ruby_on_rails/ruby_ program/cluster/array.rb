module Cluster
    class Array
        def initialize (n)
            # stack level too deep (SystemStackError)
            @disks = Array.new(n) {|i| "disk#{i}" }
        end
    end
end

p Cluster::Array.new(5)