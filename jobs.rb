class Jobs
  @@assigned = []


  def self.init
    @@assigned = []
  end


  def self.list
    @@assigned
  end


  def self.assign job
    @@assigned << job
  end


  def self.assigned? job
    @@assigned.include? job
  end


  def self.unassign job
    @@assigned.delete job
  end
end
