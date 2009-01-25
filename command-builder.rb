require 'job'


class Command
  attr_accessor :command
  attr_accessor :ss


  def initialize
    yield self
  end


  def to_str
    @command
  end
end


class CommandBuilder
  def self.build node, graph, source, destination
    job = Job.new( graph, source, destination )
    Command.new do | command |
      command.command = "scp #{ job.ss } #{ node }:#{ job.ss } && ssh #{ node } '#{ job.command }' && ssh #{ node } 'rm #{ job.ss }'"
      command.ss = job.ss
    end
  end
end
