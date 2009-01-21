require 'rubygems'

require 'mocha'
require 'spec'


Spec::Runner.configure do | config |
  config.mock_with :mocha
end
