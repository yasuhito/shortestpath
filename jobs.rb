class Jobs
  @@assigned = []


  def self.assign job
    @@assigned << job
  end


  def self.assigned? job
    @@assigned.include? job
  end
end
