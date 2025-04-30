module Denko
  module Sensor
    require "#{__dir__}/sensor/helper"
    autoload :DHT,         "#{__dir__}/sensor/dht"
    autoload :DS18B20,     "#{__dir__}/sensor/ds18b20"
    autoload :BMP180,      "#{__dir__}/sensor/bmp180"
    autoload :BME280,      "#{__dir__}/sensor/bme280"
    autoload :BMP280,      "#{__dir__}/sensor/bme280"
    autoload :HDC1080,     "#{__dir__}/sensor/hdc1080"
    autoload :HTU21D,      "#{__dir__}/sensor/htu21d"
    autoload :HTU31D,      "#{__dir__}/sensor/htu31d"
    autoload :AHT1X,       "#{__dir__}/sensor/aht"
    autoload :AHT2X,       "#{__dir__}/sensor/aht"
    autoload :AHT3X,       "#{__dir__}/sensor/aht"
    autoload :SHT3X,       "#{__dir__}/sensor/sht3x"
    autoload :SHT4X,       "#{__dir__}/sensor/sht4x"
    autoload :QMP6988,     "#{__dir__}/sensor/qmp6988"
    autoload :RCWL9620,    "#{__dir__}/sensor/rcwl9620"
    autoload :HCSR04,      "#{__dir__}/sensor/hcsr04"
    autoload :JSNSR04T,    "#{__dir__}/sensor/jsnsr04t"
    autoload :GenericPIR,  "#{__dir__}/sensor/generic_pir"
    autoload :VL53L0X,     "#{__dir__}/sensor/vl53l0x"
  end
end
