class TrackerController < ApplicationController
  def index
    config = YAML.load_file("credentials.yml")

 begin
    PivotalTracker::Client.token = config["token"]
    @Projects = PivotalTracker::Project.all
  rescue => e
    e.response
  end

    stories = []
    @all_development = []
    @all_testing = []
    @all_completed = []

    @Projects.each do |p|
      begin
        stories = p.stories.all(:story_type => ['bug','chore','feature'])
      rescue => e
        e.response
      end
      subset = stories.select{|s| s.current_state == 'started'}
      @all_development += subset unless subset.empty?

      
      subset = stories.select{|s| s.current_state == 'delivered'}
      @all_testing += subset unless subset.empty?

      subset = stories.select{|s| s.current_state == 'accepted'}
      @all_completed += subset unless subset.empty?
    end
  end

end
