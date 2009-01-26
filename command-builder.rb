require 'job'


class CommandBuilder
  def self.build node, graph, source, destination
    job = Job.new( graph, source, destination )
    "scp #{ job.ss } #{ node }:#{ job.ss } && ssh #{ node } '#{ job.command }' && ssh #{ node } 'rm #{ job.ss }; rm #{ job.eps }'"
  end
end
