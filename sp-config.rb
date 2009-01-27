require 'yaml'


class SPConfig
  PATH = File.expand_path( './config.yaml' )


  def self.[] key
    config = YAML::load( IO.read( PATH ) )
    config[ key ]
  end
end
