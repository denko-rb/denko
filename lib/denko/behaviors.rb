# Represent files to be autoloaded in CRuby as an Array.
# This allows Mruby::Build to parse and preload them instead.
BEHAVIORS_FILES = [
  # Pin and component setup stuff
  [:Lifecycle,  "lifecycle"],
  [:State,      "state"],
  [:Component,  "component"],
  [:SinglePin,  "single_pin"],
  [:InputPin,   "input_pin"],
  [:OutputPin,  "output_pin"],
  [:MultiPin,   "multi_pin"],

  # Subcomponent stuff
  [:Subcomponents,          "subcomponents"],
  [:BusController,          "bus_controller"],
  [:BusControllerAddressed, "bus_controller_addressed"],
  [:BusPeripheral,          "bus_peripheral"],
  [:BusPeripheralAddressed, "bus_peripheral_addressed"],
  [:BoardProxy,             "board_proxy"],
  [:Register,               "register"],
  [:InputRegister,          "input_register"],
  [:OutputRegister,         "output_register"],

  # Async stuff
  [:Threaded,   "threaded"],
  [:Callbacks,  "callbacks"],
  [:Reader,     "reader"],
  [:Poller,     "poller"],
  [:Listener,   "listener"],
]

module Denko
  module Behaviors
    BEHAVIORS_FILES.each do |file|
      file_path = "#{__dir__}/behaviors/#{file[1]}"
      if file[0]
        autoload file[0], file_path
      else
        require file_path
      end
    end
  end
end
