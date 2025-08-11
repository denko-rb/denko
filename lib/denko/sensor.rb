# Represent files to be autoloaded in CRuby as an Array.
# This allows Mruby::Build to parse and preload them instead.
SENSOR_FILES = [
  [nil,          "helper"],
  [:DHT,         "dht"],
  [:DS18B20,     "ds18b20"],
  [:BMP180,      "bmp180"],
  [:BME280,      "bme280"],
  [:BMP280,      "bme280"],
  [:HDC1080,     "hdc1080"],
  [:HTU21D,      "htu21d"],
  [:HTU31D,      "htu31d"],
  [:AHT1X,       "aht"],
  [:AHT2X,       "aht"],
  [:AHT3X,       "aht"],
  [:SHT3X,       "sht3x"],
  [:SHT4X,       "sht4x"],
  [:QMP6988,     "qmp6988"],
  [:RCWL9620,    "rcwl9620"],
  [:HCSR04,      "hcsr04"],
  [:JSNSR04T,    "jsnsr04t"],
  [:GenericPIR,  "generic_pir"],
  [:VL53L0X,     "vl53l0x"],
  [:ALSPT19,     "alspt19"],
  [:TEMT6000,    "temt6000"],
  [:TSL2561,     "tsl2561"],
]

module Denko
  module Sensor
    SENSOR_FILES.each do |file|
      file_path = "#{__dir__}/sensor/#{file[1]}"
      if file[0]
        autoload file[0], file_path
      else
        require file_path
      end
    end
  end
end
