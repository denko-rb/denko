HELPER_FILES = [
  [nil, "engine_check"],
  [nil, "mutex_stub"],
]

HELPER_FILES.each { |f| require_relative "helpers/#{f[1]}"}
