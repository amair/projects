class TrackerController < ApplicationController
  def index
    if @token.nil? && params[:token].nil?
      logger.debug "No token"
    else
      if @token.nil?
        @token = params[:token] 
        logger.debug "Set Token to #{@token}"
      end

      begin
        logger.debug "Using token #{@token}"
        PivotalTracker::Client.token = @token 
        logger.debug 'Getting Projects'
        @Projects = PivotalTracker::Project.all
        logger.debug "Found #{@Projects.length} Projects"
      rescue => e
        logger.error e.response
      end
      getStories unless @Projects.nil?
    end
  end

  def getStories
    stories = []
    @all_development = []
    @all_testing = []
    @all_completed = []

    @Projects.each do |p| 
      begin
        logger.debug "Getting Stories for project #{p.id}"
        stories = p.stories.all(:story_type => ['bug','chore','feature'])
        stories = p.stories.all()
        logger.debug "Retrieved #{stories.length} stories"
      rescue => e
        logger.error e.response
      end

      subset = stories.select{|s| s.current_state == 'started'}
      logger.debug "There are #{subset.length} started stories"
      @all_development += subset unless subset.empty?


      subset = stories.select{|s| s.current_state == 'delivered'}
      logger.debug "There are #{subset.length} delivered stories"
      @all_testing += subset unless subset.empty?

      subset = stories.select{|s| s.current_state == 'accepted'}
      logger.debug "There are #{subset.length} accepted stories"
      @all_completed += subset unless subset.empty?
    end
    logger.debug "Got all stories!"
  end


end
