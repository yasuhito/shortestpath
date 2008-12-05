require 'rubygems'

require 'rake/clean'
require 'spec/rake/spectask'
require 'spec/rake/verify_rcov'


task :default => :verify_rcov
task :verify_rcov => :spec
RCov::VerifyTask.new do | t |
  t.threshold = 100
end


Spec::Rake::SpecTask.new do | t |
  t.spec_files = FileList[ '*_spec.rb' ]
  t.rcov = true
  t.rcov_opts = lambda do
    IO.readlines( './rcov.opts' ).map do | l |
      l.chomp.split ' '
    end.flatten
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
