class TrackerController < TokenManagement
  def index

    retrieveProjects unless get_token.nil?

  end

  def retrieveProjects
    begin
      logger.debug "Using token #{get_token} to get Projects"
      PivotalTracker::Client.token = get_token
      @projects = PivotalTracker::Project.all
      logger.debug "Found #{@projects.length} Projects"
    rescue => e
      logger.error e.response
    end

    getStories unless @projects.nil?
  end

  def getStories
    stories = []
    @all_development = []
    @all_testing = []
    @all_completed = []

    @projects.each do |p|
      logger.debug "Getting Stories for project #{p.id}"

      begin
        iteration = PivotalTracker::Iteration.current(p)
      rescue => e
        logger.error e.response
      end

      stories = iteration.stories
      logger.debug "Retrieved #{stories.length} stories"

      subset = stories.select{|s| s.current_state == 'started' && s.story_type != 'release'}
      logger.debug "There are #{subset.length} started stories"
      @all_development += subset unless subset.empty?

      # TODO Need to decide if we should include 'not yet started' stories #
      subset = stories.select{|s| s.current_state == 'delivered' && s.story_type != 'release'}
      logger.debug "There are #{subset.length} delivered stories"
      @all_testing += subset unless subset.empty?

      subset = stories.select{|s| s.current_state == 'accepted' && s.story_type != 'release'}
      logger.debug "There are #{subset.length} accepted stories"
      @all_completed += subset unless subset.empty?
    end
    logger.debug "Got all stories!"
  end

end
