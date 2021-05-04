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
presets = %w(90.1, 106.2, 88.5)
p "presets: #{presets}"
tuner = Tuner.new(presets)
p "#tuner: #{tuner}"
p "#presets: #{presets}"