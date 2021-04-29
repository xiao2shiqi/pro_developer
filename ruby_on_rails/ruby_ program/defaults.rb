module Defaults
    NETWORKS = ["192.168.1", "192.168.2"]
    # NETWORKS = ["192.168.1", "192.168.2"].freeze       # 增加 freeze 后，常量 NETWORKS 无法再修改
end

# 尝试修改常量
def purge_unreachable (networks = Defaults::NETWORKS) 
    networks.delete_if do |net|
        net == "192.168.2"
    end
end
# purge_unreachable(Defaults::NETWORKS)   # 常量被改变，输出 ["192.168.1"]


def host_addresses (host, networks = Defaults::NETWORKS)
    networks.map {|net| net << ".#{host}" }
end
host_addresses("1")
p Defaults::NETWORKS