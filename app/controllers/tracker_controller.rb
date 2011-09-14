class TrackerController < ApplicationController
  def index
    config = YAML.load_file("credentials.yml")

    PivotalTracker::Client.token = config["token"]
    @Projects = PivotalTracker::Project.all

    @p1 = @Projects.first.name

    @Developments = []

    @Projects.each do |p|
      @Developments += p.stories.all(:current_state => 'started', :story_type => ['bug','chore','feature']) 
    end
  end

end
