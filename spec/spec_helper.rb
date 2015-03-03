$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'rspec'
require 'sidamo'

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

def fixture(name)
  File.join(File.dirname(__FILE__), 'fixtures', name)
end

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = [:should, :expect]
  end
end
