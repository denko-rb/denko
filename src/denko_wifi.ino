#include "Denko.h"
#if defined(ESP8266)
  #include <ESP8266WiFi.h>
  #include <ESP8266mDNS.h>
  #include <WiFiUdp.h>
  #include <ArduinoOTA.h>
  #define WIFI_STATUS_LED 2
#elif defined(ESP32)
  #include <WiFi.h>
  #include <ESPmDNS.h>
  // #include <WiFiUdp.h>
  // #include <ArduinoOTA.h>
  #define WIFI_STATUS_LED 2
#else
  #include <SPI.h>
  #include <WiFi.h>
  #define WIFI_STATUS_LED 13
#endif


// Define 'serial' as the serial interface to use.
// Uses SerialUSB (left port), which is native USB, on Arduino Due and Zero, or Serial otherwise.
// On many boards, eg. Arduino Due, RP2040, Serial may be native USB anyway.
#if defined(__SAM3X8E__) || defined(__SAMD21G18A__)
  #define serial SerialUSB
  // Use this for Programming USB port (right) on Due and Zero.
  // #define serial Serial
#else
  #define serial Serial
#endif

// Configure your WiFi options here. IP address is not configurable. Uses DHCP.
int port = 3466;
char* ssid = "yourNetwork";
char* pass = "yourPassword";
boolean connected = false;

Denko denko;
WiFiServer server(port);
WiFiClient client;

// Use the built in LED to indicate WiFi status.
void indicateWiFi(byte value) {
  pinMode(WIFI_STATUS_LED, OUTPUT);
  #if defined(ESP8266)
    digitalWrite(WIFI_STATUS_LED, !value);
  #else
    digitalWrite(WIFI_STATUS_LED, value);
  #endif
}

void printWifiStatus() {
  serial.println("WiFi Connected");
  serial.print("SSID: ");
  serial.println(WiFi.SSID());
  serial.print("Signal Strength (RSSI):");
  serial.print(WiFi.RSSI());
  serial.println(" dBm");
  serial.print("IP Address: ");
  serial.println(WiFi.localIP());
  serial.print("Denko TCP Port: ");
  serial.println(port);
  indicateWiFi(true);
}

void connect(){
  // Make sure we're in STA mode on ESP boards, which can also be AP.
  #if defined(ESP8266) || defined(ESP32)
    WiFi.mode(WIFI_STA);
  #endif

  // Try to connect.
  serial.print("Connecting to WiFi ");
  WiFi.begin(ssid, pass);

  // Delay until connected.
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    serial.print(".");
  }
  connected = true;
}

void maintainWiFi(){
  if (connected == true){
    if (WiFi.status() == WL_CONNECTED) return;
    connected = false;
    connect();
  }
  if (connected == false){
    if (WiFi.status() != WL_CONNECTED) {
      connect();
      return;
    }
    connected = true;
    printWifiStatus();
  }
}

void setup() {
  // Wait for serial ready.
  serial.begin(115200);
  while(!serial);

  // Enable over the air updates on the ESP8266.
  #if defined(ESP8266)
    ArduinoOTA.begin();
  #endif

  // Attempt initial WiFi connection.
  connect();
  
  // Start the denko TCP server.
  server.begin();

  // Add listener callbacks for local logic.
  denko.digitalListenCallback = onDigitalListen;
  denko.analogListenCallback = onAnalogListen;

  // Use serial as the denko IO stream until we get a TCP connection.
  denko.stream = &serial;
}

void loop() {
  // Reconnect if we've lost WiFi.
  maintainWiFi();

  // Allow one client at a time to be connected. Set it as the denko IO stream.
  if (!client){
    client = server.available();
    if (client) denko.stream = &client;
  }

  // Main loop of the denko library.
  denko.run();

  // End the connection when client disconnects and revert to serial IO.
  if (client && !client.connected()){
    client.stop();
    denko.stream = &serial;
  }

  // Handle OTA updates.
  #if defined(ESP8266)
    ArduinoOTA.handle();
  #endif
}

// This runs every time a digital pin that denko is listening to changes value.
// p = pin number, v = current value
void onDigitalListen(byte p, byte v){
}

// This runs every time an analog pin that denko is listening to gets read.
// p = pin number, v = read value
void onAnalogListen(byte p, int v){
}