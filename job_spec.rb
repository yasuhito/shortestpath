require 'job'


describe Job do
  it 'should know commandline string' do
    job = Job.new( './USA-t.m-gr', [ 957498 ], [ 957498, 19200797, 13006257, 4314559, 17261435, 8077810, 3048748, 21869636, 13446936, 18549540 ] )

    job.command.should match( /sp\.heap \.\/USA\-t\.m\-gr \S+ \S+\.out\-p/ )
  end


  it 'should know merge command line string' do
    job = Job.new( './USA-t.m-gr', [ 957498 ], [ 957498, 19200797, 13006257, 4314559, 17261435, 8077810, 3048748, 21869636, 13446936, 18549540 ] )

    job.merge_command.should match( /merge_ssout \.\/USA\-t\.m\-gr \.\/USA\.m\-co \S+ \S+\.out\-p \S+\.eps/ )
  end
end
