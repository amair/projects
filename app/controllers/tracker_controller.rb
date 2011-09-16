class TrackerController < ApplicationController
  def index

    retrieveProjects unless @token.nil?

    if params[:token].nil?
      logger.debug "No token"
    else
        @token = params[:token] 
        logger.debug "Set Token to #{@token}"
        retrieveProjects unless @token.nil?
    end
  end

  def retrieveProjects
    begin
      logger.debug "Using token #{@token} to get Projects"
      PivotalTracker::Client.token = @token 
      @Projects = PivotalTracker::Project.all
      logger.debug "Found #{@Projects.length} Projects"
    rescue => e
      logger.error e.response
    end

    getStories unless @Projects.nil?
  end


  def getStories
    stories = []
    @all_development = []
    @all_testing = []
    @all_completed = []

    @Projects.each do |p| 
      begin
        logger.debug "Getting Stories for project #{p.id}"
        
        iteration = PivotalTracker::Iteration.current(p)
        stories = iteration.stories
        logger.debug "Retrieved #{stories.length} stories"
      rescue => e
        logger.error e.response
      end

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
