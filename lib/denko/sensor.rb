module Denko
  module Sensor
    autoload :Temperature, "#{__dir__}/sensor/virtual"
    autoload :Humidity,    "#{__dir__}/sensor/virtual"
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
  end
end
