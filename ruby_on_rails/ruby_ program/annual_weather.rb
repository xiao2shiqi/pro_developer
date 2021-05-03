class AnnualWeather
  # 模拟外部文件
  Csv = [{date: '2020-01', high: 31.3, low: 25.1}, {date: '2020-02', high: 32.3, low: 26.1}, {date: '2020-03', high: 33.3, low: 27.1}]

  # 定义 strcut 存储结构化对象
  Reading = Struct.new(:date, :high, :low) do
    # 对象方法 mean
    def mean 
      (high + low) / 2.0
    end
  end

  def initialize  
    @readings = []
    Csv.each { |e| 
      # 将 Csv 数据构造为 struct 对象
      reading = Reading.new(e[:date], e[:high], e[:low])
      @readings.append(reading) 
    }
  end

  # 计算平均温度
  def mean
    return 0.0 if @readings.size.zero?
    # 调用对象方法获取 total 
    total = @readings.reduce(0.0) {|sum, reading| sum + reading.mean }
    total / @readings.size.to_f
  end
end

annual = AnnualWeather.new
p "平均温度 #{annual.mean}"