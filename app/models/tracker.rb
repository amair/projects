require 'pivotal-tracker'

class Tracker 
  PivotalTracker::Client.token = '889cec270844e85c4d291a86a163fdb5'
    @Projects = PivotalTracker::Project.all 
end

