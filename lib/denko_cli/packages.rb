class DenkoCLI::Generator

# File locations are defined relative to the src/lib directory. 
PACKAGES = {
  # The core package is always included.
  core: {
    description: "Core Denko Library",
    directive: nil,
    files: [
      "Denko.h",
      "DenkoDefines.h",
      "Denko.cpp",
      "DenkoCoreIO.cpp",
      "DenkoPulseInput.cpp",
      "../../vendor/board-maps/BoardMap.h",
    ]
  },
  eeprom: {
    description: "Built-in EEPROM support",
    directive: "DENKO_EEPROM",
    files: [
      "DenkoEEPROM.cpp",
    ]
  },
  one_wire: {
    description: "OneWire bus support",
    directive: "DENKO_ONE_WIRE",
    files: [
      "DenkoOneWire.cpp",
    ]
  },
  i2c_bb: {
    description: "Bit Bang I2C support",
    directive: "DENKO_I2C_BB",
    files: [
      "DenkoI2CBB.cpp",
    ]
  },
  spi_bb: {
    description: "Bit Bang SPI support",
    directive: "DENKO_SPI_BB",
    files: [
      "DenkoSPI.cpp",
      "DenkoSPIBB.cpp",
    ]
  },
  spi: {
    description: "SPI support",
    directive: "DENKO_SPI",
    files: [
      "DenkoSPI.cpp",
    ]
  },
  i2c: {
    description: "I2C device support",
    directive: "DENKO_I2C",
    files: [
      "DenkoI2C.cpp",
    ]
  },
  uart_bb: {
    description: "Bit bang serial output",
    directive: "DENKO_UART_BB",
    only: [:atmega, :atmega168],
    files: [
      "DenkoUARTBB.cpp",
    ]
  },
  uart: {
    description: "Hardware UART I/O",
    directive: "DENKO_UART",
    files: [
      "DenkoUART.cpp",
    ]
  },
  servo: {
    description: "Servo support",
    directive: "DENKO_SERVO",
    files: [
      "DenkoServo.cpp",
    ]
  },
  tone: {
    description: "Tone support",
    directive: "DENKO_TONE",
    files: [
      "DenkoTone.cpp",
    ]
  },
  ir_out: {
    description: "Transmit infrared signals",
    directive: "DENKO_IR_OUT",
    files: [
      "DenkoIROut.cpp",
    ]
  },
  led_array: {
    description: "Support for various protocols that control (RGB) LED arrays.",
    directive: "DENKO_LED_ARRAY",
    files: [
      "DenkoLEDArray.cpp",
    ]
  }
}
end
