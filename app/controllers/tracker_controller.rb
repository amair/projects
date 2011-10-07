

class TrackerController < PivotalManagement
  def index

    get_stories unless retrieveProjects.nil?

  end

  def create

  end

  def filter_stories
    filtered_stories = yield

    filtered_stories.each  { |s| s.div_class  = lookupProject s.project_id} unless filtered_stories.empty?
  end

  def get_stories
    stories = []
    @all_development = []
    @all_testing = []
    @all_completed = []

    if (!@@projects.nil?)
      @@projects.each do |p|
        logger.debug "Getting Stories for project #{p.id}"

        begin
          iteration = PivotalTracker::Iteration.current(p)
        rescue => e
          logger.error e.response
        end

        stories = iteration.stories
        logger.debug "Retrieved #{stories.length} stories"

        filtered = filter_stories {stories.select { |s| s.current_state == 'started' && s.story_type != 'release' }}
        @all_development.concat(filtered) unless filtered.nil?

        ## TODO Need to decide if we should include 'not yet started' stories #
        filtered = filter_stories {stories.select { |s| s.current_state == 'delivered' && s.story_type != 'release' }}
        @all_testing.concat (filtered) unless filtered.nil?

        filtered =  filter_stories {stories.select { |s| s.current_state == 'accepted' && s.story_type != 'release' }}
        @all_completed.concat (filtered) unless filtered.nil?

      end
      logger.debug "Got all stories!"
    end

  end


end
