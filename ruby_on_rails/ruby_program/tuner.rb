class Tuner
     def initialize (presets)
        @presets = presets.dup
        clean
     end

     private 
     def clean
        @presets.delete_if { |f|
            f[-1].to_i.even?
        }
     end
end

# 预设有效的频道
presets = %w(90.1, 106.2, 80.5)
presets.each {|p| p p.object_id}
copy_presets = Marshal.load(Marshal.dump(presets))
copy_presets.each {|c| c.sub!('0', '1')}
p presets
p copy_presets