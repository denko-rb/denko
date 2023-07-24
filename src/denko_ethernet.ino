#include "Denko.h"
#include <SPI.h>
#include <Ethernet.h>

// Configure your MAC address, IP address, and HTTP port here.
byte mac[] = { 0xDE, 0xAD, 0xBE, 0x30, 0x31, 0x32 };
IPAddress ip(192,168,0,77);
int port = 3466;

Denko denko;
EthernetServer server(port);
EthernetClient client;

void printEthernetStatus() {
  Serial.print("IP Address: ");
  Serial.println(Ethernet.localIP());
  Serial.print("Port: ");
  Serial.println(port);
}

void setup() {
  // Wait for serial ready.
  DENKO_SERIAL_IF.begin(115200);
  while(!DENKO_SERIAL_IF);

  // Explicitly disable the SD card.
  pinMode(4,OUTPUT);
  digitalWrite(4,HIGH);

  // Start up the network connection and server.
  Ethernet.begin(mac, ip);
  server.begin();
  #ifdef debug
    printEthernetStatus();
  #endif

  // Add listener callbacks for local logic.
  denko.digitalListenCallback = onDigitalListen;
  denko.analogListenCallback = onAnalogListen;
}

void loop() {
  // End connection if client disconnects.
  if (client && !client.connected()) {
    client.stop();
  }

  // Allow one client at a time to be connected. Set it as the denko IO stream.
  if (!client){
    client = server.available();
    if (client) {
      // TCP Client
      denko.stream = &client;
    } else {
      // Serial fallback
      denko.stream = &DENKO_SERIAL_IF;
    }
  }

  // Main loop of the denko library.
  denko.run();
}

// This runs every time a digital pin that denko is listening to changes value.
// p = pin number, v = current value
void onDigitalListen(byte p, byte v){
}

// This runs every time an analog pin that denko is listening to gets read.
// p = pin number, v = read value
void onAnalogListen(byte p, int v){
}
