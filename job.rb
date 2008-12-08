require 'popen3/shell'


class Job
  def initialize coord1, coord2
    @coord1 = coord1
    @coord2 = coord2
  end

  
  def run
    Popen3::Shell.open do | shell |
      shell.on_failure do
        raise %{Command "#{ command }" failed.}
      end

      shell.exec command
    end
  end


  ################################################################################
  private
  ################################################################################


  def command
    "sp #{ @coord1 } #{ @coord2 }"
  end
end
