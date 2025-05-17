module Denko
  def self.gil?
    ["mruby", "ruby"].include? RUBY_ENGINE
  end

  def self.mruby?
    RUBY_ENGINE == "mruby"
  end
end
