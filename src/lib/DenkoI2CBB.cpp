//
// Adds I2C bitbang functionality to the Denko class if DENKO_I2C_BB defined in DenkoDefines.h.
//
#include "Denko.h"

#ifdef DENKO_I2C_BB

void Denko::i2c_bb_delay_quarter_period() {
  #ifndef __AVR__
    microDelay(i2c_bb_quarter_period);
  #endif
}

// Delays for timing. Not sure how necessary this is.
void Denko::i2c_bb_delay_half_period() {
  #ifndef __AVR__
    microDelay(i2c_bb_quarter_period*2);
  #endif
}

// Can't use output mode for SDA. Toggle between input for HIGH, output for LOW.
void Denko::i2c_bb_sda_high() { pinMode(i2c_bb_sda_pin, INPUT);  }
void Denko::i2c_bb_sda_low()  { pinMode(i2c_bb_sda_pin, OUTPUT); }

// Matching SCL functions for readability.
void Denko::i2c_bb_scl_high() { digitalWrite(i2c_bb_scl_pin, HIGH); }
void Denko::i2c_bb_scl_low()  { digitalWrite(i2c_bb_scl_pin, LOW);  }

// Start condition is SDA then SCL going low, from both high.
void Denko::i2c_bb_start() {
  i2c_bb_delay_quarter_period();
  i2c_bb_sda_low();
  i2c_bb_delay_quarter_period();
  i2c_bb_scl_low();
}

// Stop condition is SDA going high, while SCL is also high.
void Denko::i2c_bb_stop() {
  i2c_bb_delay_quarter_period();
  i2c_bb_sda_low();
  i2c_bb_delay_quarter_period();
  i2c_bb_scl_high();
  i2c_bb_delay_quarter_period();
  i2c_bb_sda_high();
}

uint8_t Denko::i2c_bb_read_bit() {
  uint8_t bit;

  // Ensure SDA high before we pull SCL high.
  // i2c_bb_delay_quarter_period();
  i2c_bb_sda_high();
  i2c_bb_delay_quarter_period();

  // Pull SCL high.
  i2c_bb_scl_high();

  // Wait 1/4 period and sample SDA.
  i2c_bb_delay_quarter_period();
  bit = digitalRead(i2c_bb_sda_pin);

  // Leave SCL low.
  // i2c_bb_delay_quarter_period();
  i2c_bb_scl_low();

  return bit;
}

void Denko::i2c_bb_write_bit(uint8_t bit) {
  // i2c_bb_delay_quarter_period();
  // Set SDA while SCL is low.
  if (bit == 0) {
    i2c_bb_sda_low();
  } else {
    i2c_bb_sda_high();
  }
  // i2c_bb_delay_quarter_period();
  
  // Pull SCL high, wait (should be half cycle), then leave it low.
  i2c_bb_scl_high();
  i2c_bb_delay_quarter_period();
  // i2c_bb_delay_half_period();
  i2c_bb_scl_low();
}

uint8_t Denko::i2c_bb_read_byte(bool ack) {
  uint8_t b;

  // Receive MSB first.
  for (int i=7; i>=0; i--) bitWrite(b, i, i2c_bb_read_bit());

  // Send ACK or NACK and return byte.
  if (ack) {
    i2c_bb_write_bit(0);
  } else {
    i2c_bb_write_bit(1);
  }
  return b;
}

int Denko::i2c_bb_write_byte(uint8_t data) {
  // Send MSB first.
  for (int i=7; i>=0; i--) i2c_bb_write_bit(bitRead(data, i));

  // Return -1 for NACK, 0 for ACK.
  return (i2c_bb_read_bit() == 0) ? 0 : -1;
}

void Denko::i2c_bb_init(uint8_t scl, uint8_t sda) {
  // Set pins in state variables, to avoid passing them around.
  i2c_bb_scl_pin = scl;
  i2c_bb_sda_pin = sda;

  // Ensure SCL is output, and reset both pins to high.
  pinMode(i2c_bb_scl_pin, OUTPUT);
  i2c_bb_stop();
}

//
// cmd         = 31
// pin         = SCL pin
// val         = SDA pin
// auxMsg[0]   = I2C settings
//  Bits[7..0] = <reserved>
// auxMsg[1]   = Device address in bits [6..0] + repeated start in bit 7
// auxMsg[2]   = Data length to write
// auxMsg[3]+  = Data
//
void Denko::i2c_bb_write() {
  // Get parameters from message.
  uint8_t address      = auxMsg[1] & 0b01111111;
  uint8_t writeAddress = (address << 1) & 0b11111110;
  uint8_t sendStop     = auxMsg[1] >> 7;
  uint8_t dataLength   = auxMsg[2];

  // Switch our "bus" to the given pins.
  i2c_bb_init((uint8_t)pin, (uint8_t)val);

  i2c_bb_start();
  i2c_bb_write_byte(writeAddress);
  for (int i=0; i<dataLength; i++) i2c_bb_write_byte(auxMsg[3+i]);
  i2c_bb_stop();
}

//
// Read from an I2C device over a bit banged I2C interface.
//
// cmd         = 32
// pin         = SCL pin
// val         = SDA pin
// auxMsg[0]   = I2C settings
//  Bits[7..0] = <reserved>
// auxMsg[1]   = Device address in bits [6..0] + repeated start in bit 7
// auxMsg[2]   = Data length to read
// auxMsg[3]   = Register address length
// auxMsg[4]+  = Register address bytes if length > 0
//
void Denko::i2c_bb_read() {
  // Get parameters from message.
  uint8_t address      = auxMsg[1] & 0b01111111;
  uint8_t writeAddress = (address << 1) & 0b11111110;
  uint8_t readAddress  = (address << 1) | 0b00000001;
  uint8_t sendStop     = auxMsg[1] >> 7;
  uint8_t dataLength   = auxMsg[2];

  // Switch our "bus" to the given pins.
  i2c_bb_init((uint8_t)pin, (uint8_t)val);

  // Optionally write up to a 4 byte register address before reading.
  if ((auxMsg[3] > 0) && (auxMsg[3] < 5)) {
    i2c_bb_start();
    i2c_bb_write_byte(writeAddress);
    for(int i=0; i<auxMsg[3]; i++) i2c_bb_write_byte(auxMsg[4+i]);
    i2c_bb_stop(); 
  }

  // If no ACK from device, return without sending any data.
  i2c_bb_start();
  int ack = i2c_bb_write_byte(readAddress);
  if (ack < 0) return;

  // Start streaming data as if coming from the SDA pin.
  stream->print(i2c_bb_sda_pin); stream->print(':');
  stream->print(address); stream->print('-');

  // Read and ACK for all but the last byte.
  for(int i=0; i<dataLength-1; i++){
    stream->print(i2c_bb_read_byte(true));
    stream->print(',');
  }
  stream->print(i2c_bb_read_byte(false));

  // Finish stream and send stop condition.
  stream->print(',');
  stream->print('\n');
  i2c_bb_stop();  
}
#endif
