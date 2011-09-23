class TrackerController < ApplicationController
  def index

    if @token.nil?
      if cookies[:token].nil?
        if params[:token].nil?
          logger.fatal "Cannot figure out tracker token - giving up"
          #redirect_to self,  :notice => "You need to supply your Pivotal Tracker access token"
        else
          @token = params[:token]
          cookies.permanent[:token] = @token unless @token.nil?
          logger.debug "Retrieve Pivotal token #{@token} from page submission and store in cookie"
        end
      else
        @token = cookies[:token]
        logger.debug "Retrieving token #{@token} from cookie"
      end
    end

    retrieveProjects unless @token.nil?

  end

  def retrieveProjects
    begin
      logger.debug "Using token #{@token} to get Projects"
      PivotalTracker::Client.token = @token
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
