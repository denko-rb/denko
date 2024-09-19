# denko 0.14.0 [![Test Status](https://github.com/denko-rb/denko/actions/workflows/ruby.yml/badge.svg)](https://github.com/denko-rb/denko/actions/workflows/ruby.yml)

Use connected microcontrollers and peripherals in Ruby, without writing microcontroller code. Work with LEDs, buttons, sensors, and more, just like any Ruby object:

```ruby
led.blink 0.5

lcd.print "Hello World!"

reading = sensor.read

button.down do
  puts "Button pressed!"
end
```

## How it Works

- The microcontroller runs a barebones Arduino firmware so it can be "remote controlled" over an IO stream. Ruby runs on any computer, exchanging messages with the MCU and doing all the higher level logic.
- The physical MCUs and peripherals all map to Ruby objects, so you can focus on hardware and appplication logic, not the layers in between.
- Peripheral drivers are easy to implement, since they're pure Ruby.
- Multitasking works out of the box, even on single core microcontrollers.
- Integrating multiple microcontrollers is seamless. You just get more Ruby objects.

## Supported Hardware

Full list of supported mircocontrollers, interfaces, and peripherals is [here](HARDWARE.md).

## Getting Started

**Note:** On Windows you can follow the Mac/Linux instructions in WSL, but it isn't recommended. Serial (COM port) forwarding isn't working on WSL2, which means you can't communicate with the board. There are workarounds, and it might work on WSL1, but the [RubyInstaller for Windows](https://rubyinstaller.org/) and Arduino IDE are recommended instead. A Linux virtual machine with USB passthrough works too.

#### 1. Install the Gem

```shell
gem install denko
```

#### 2. Install the Arduino IDE OR CLI

Get the Arduino IDE [here](http://arduino.cc/en/Main/Software) for a graphical interface (recommended for Windows), or use the command line interface from [here](https://github.com/arduino/arduino-cli/releases), or Homebrew.

**CLI Installation with Homebrew on Mac or Linux:**

```shell
brew update
brew install arduino-cli
```

#### 3. Install Arduino Dependencies

Denko uses Arduino cores, which support different microcontrollers, and a few libraries. Install only the ones for your microcontroller, or install everything. There are no conflcits. Instructions:

- [Install Dependencies in IDE](DEPS_IDE.md)
- [Install Dependencies in CLI](DEPS_CLI.md)

#### 4. Generate the Arduino Sketch

The `denko` command is included with the gem. It will make the Arduino sketch folder for you, and configure it.

**Example for ESP32 target on both serial and Wi-Fi:**

```shell
denko sketch serial --target esp32
denko sketch wifi --target esp32 --ssid YOUR_SSID --password YOUR_PASSWORD

# For more options
denko targets
```

**Note:** Boards flashed with a Wi-Fi or Ethernet sketch will [listen for a TCP connection](examples/connection/tcp.rb), but fall back to Serial when there is none active.

#### 5a. IDE Flashing

- Connect the board to your computer with a USB cable.
- Open the .ino file inside your sketch folder with the IDE.
- Open the dropdown menu at the top of the IDE window, and select your board.
- Press the Upload :arrow_right: button. This will compile the sketch, and flash it to the board.

**Troubleshooting:**

- If your serial port is in the list, but the board is wrong, select the serial port anyway, then you will be asked to manually select a board.
- If your board doesn't show up at all, make sure it is connected properly. Try disconnecting and reconnecting, use a different USB port or cable, or press the reset button after plugging it in.
- Some boards may be in a state where you have to hold their "boot" button while cycling power (reconnect or reset) for them to enter firmware update mode. Eg. Raspberry Pi Pico, ESP32-S2/S3.

#### 5b. CLI Flashing

- The path output by `denko sketch` earlier is your sketch folder. Keep it handy.
- Connect the board to your computer with a USB cable.
- Check if the CLI recognizes it:

```shell
arduino-cli board list
```
  
- Using the Port and FQBN (Fully Qualified Board Name) shown, compile and upload the sketch:

```shell
arduino-cli compile -b YOUR_FQBN YOUR_SKETCH_FOLDER
arduino-cli upload -v -p YOUR_PORT -b YOUR_FQBN YOUR_SKETCH_FOLDER
```

**Troubleshooting:**

- Follow the same steps as the IDE method above. List all FQBNs using:

```shell
arduino-cli board listall
```

#### 6. Test It

Most boards have a regular LED on-board. Test it with the [blink](examples/led/builtin_blink.rb) example. If you have an on-board WS2812 LED (Neopixel), use the [WS2812 blink](examples/led/ws2812_builtin_blink.rb) example instead. If it starts blinking, you're ready for Ruby!

## Examples and Tutorials

#### Tutorial

- [Here](tutorial) you will find a beginner-friendly tutorial, that goes through the basics, using commented examples and diagrams. Read the comments and try modifying the code. You will need the following:
  - 1 compatible microcontroller (see [supported hardware](HARDWARE.md))
  - 1 button or momentary switch
  - 1 potentiometer (any value)
  - 1 external RGB LED (4 legs common cathode, not a Neopixel or individually addressable)
  - 1 external LED (any color, or use one color from the RGB LED)
  - Current limiting resistors for LEDs
  - Breadboard
  - Jumper wires
  
  **Tip:** Kits are a good way to get started. They should include these parts and more, getting you beyond the tutorial.

#### Included Examples

- The [examples](examples) folder contains at least one example per supported peripheral, demonstrating its interface, and a few that use multiple peripherals together.
- Each example should incldue a wiring diagram alongside its code (still incomplete).

#### More Examples

**Note:** This gem was renamed from `dino` to `denko`. Some of these examples use the old name.

- Try [Getting Started with Arduino and Dino](http://tutorials.jumpstartlab.com/projects/arduino/introducing_arduino.html) from [Jumpstart Lab](http://jumpstartlab.com) (_ignore old install instructions_).
- An example [rails app](https://github.com/austinbv/dino_rails_example) using Dino and Pusher.
- For a Sinatra example, look at the [site](https://github.com/austinbv/dino_cannon) used to shoot the cannon at RubyConf2012.

## Explanatory Talks

- "Arduino the Ruby Way" at RubyConf 2012
  - [Video by ConFreaks](https://www.youtube.com/watch?v=oUIor6GK-qA)
  - [Slides on SpeakerDeck](https://speakerdeck.com/austinbv/arduino-the-ruby-way)

## Related Projects

### denko-piboard

[This gem](https://github.com/denko-rb/denko-piboard) adds a `Board`-compatible class for the built-in GPIO headers on single board computers (eg. Raspberry Pi). Connect peripherals directly to the SBC, and use classes from this gem.

### mruby-denko

A SBC (or computer + microcontroller combo) is great if you need the power anyway, but what if you don't? Why not run Ruby on the microcontroller itself?

That's the goal of [mruby-denko](https://github.com/denko-rb/mruby-denko): run mruby on the ESP32, using peripheral classes as close to this gem as practical. Still early in development (limited features), but already usable.
