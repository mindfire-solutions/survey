require 'nested_form'

module Survey
  class Engine < Rails::Engine
    isolate_namespace Survey
    config.autoload_paths << File.expand_path("../../common_functions.rb", __FILE__)
  end
end