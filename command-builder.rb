# -*- coding: utf-8 -*-
require 'job'


class CommandBuilder
  # ジョブ実行の前後に .ss のステージングと一時ファイルのゴミ掃除を追加
  # する。
  #
  # [???] out-p も掃除してよい？
  def self.build node, graph, source, destination
    job = Job.new( graph, source, destination )
    ss_staging = "scp #{ job.ss } #{ node }:#{ job.ss }"
    job_exec = "ssh #{ node } '#{ job.command }'"
    cleanup = "ssh #{ node } 'rm #{ job.ss } #{ job.eps } #{ job.out_p }'"

    [ ss_staging, job_exec, cleanup ].join( ' && ' )
  end
end
