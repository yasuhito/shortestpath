require 'yaml'


class SPConfig
  PATH = File.expand_path( './config.yaml' )


  def self.[] key
    config = YAML::load( IO.read( PATH ) )
    case key
    when 'working_dir'
      File.expand_path config[ key ]
    else
      config[ key ]
    end
  end
end
