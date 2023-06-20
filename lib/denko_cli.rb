module DenkoCLI
  require "denko_cli/parser"
  require "denko_cli/generator"

  TASKS    = ["sketch"]
  SKETCHES = ["serial", "ethernet", "wifi"]

  def self.start(options={})
    options = DenkoCLI::Parser.run(options)
    method = options[:task]
    self.send method, options
  end

  def self.sketch(options)
    result = DenkoCLI::Generator.run!(options)
    $stdout.puts result[:sketch_folder]
  end
end
