module Denko
  module Sensor
    autoload :DHT,         "#{__dir__}/sensor/dht"
    autoload :DS18B20,     "#{__dir__}/sensor/ds18b20"
    autoload :BMP180,      "#{__dir__}/sensor/bmp180"
    autoload :BME280,      "#{__dir__}/sensor/bme280"
    autoload :BMP280,      "#{__dir__}/sensor/bme280"
    autoload :HTU21D,      "#{__dir__}/sensor/htu21d"
    autoload :HTU31D,      "#{__dir__}/sensor/htu31d"
    autoload :AHT10,       "#{__dir__}/sensor/aht"
    autoload :AHT20,       "#{__dir__}/sensor/aht"
    autoload :SHT3X,       "#{__dir__}/sensor/sht3x"
    autoload :QMP6988,     "#{__dir__}/sensor/qmp6988"
    autoload :RCWL9620,    "#{__dir__}/sensor/rcwl9620"
    autoload :HCSR04,      "#{__dir__}/sensor/hcsr04"
    autoload :GenericPIR,  "#{__dir__}/sensor/generic_pir"
  end
end
