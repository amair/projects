class TrackerController < ApplicationController
  def index
    config = YAML.load_file("credentials.yml")

    PivotalTracker::Client.token = config["token"]
    @Projects = PivotalTracker::Project.all

    stories = []
    @all_development = []
    @all_testing = []
    @all_completed = []

    @Projects.each do |p|
      stories = p.stories.all(:story_type => ['bug','chore','feature'])
      subset = stories.select{|s| s.current_state == 'started'}
      @all_development += subset unless subset.empty?

      
      subset = stories.select{|s| s.current_state == 'delivered'}
      @all_testing += subset unless subset.empty?

      subset = stories.select{|s| s.current_state == 'accepted'}
      @all_completed += subset unless subset.empty?
    end
  end

end
