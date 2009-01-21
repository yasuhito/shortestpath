require 'job'


class CommandBuilder
  def self.build node, graph, source, destination
    job = Job.new( graph, source, destination )
    "ssh #{ node } #{ job.command }"
  end
end

