class VelocityController < ApplicationController

  def index

    @velocities = []

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
      @projects = PivotalTracker::Project.all
      logger.debug "Found #{@projects.length} Projects"
    rescue => e
      logger.error e.response
    end

    getVelocities unless @projects.nil?
  end

  def getVelocities
    pointsHash = Hash.new
    logger.debug "**** Creating new Hash ****"
    @projects.each do |p| 
      logger.debug "Getting iterations for project #{p.id}"
      logger.debug "Project using point scheme #{p.point_scale}"

      if (p.point_scale=="0,1,2,3,4,5,6")
        logger.debug "halving all points for this project"
        divisor = 2
      else
        # TODO We are only dealing with 1-6 and 1-3 point scales ATM
        logger.debug "Not changing points base - this MAY be a problem for SOME projects"
        divisor = 1
      end

      begin
        iterations = PivotalTracker::Iteration.done(p)
      rescue => e
        logger.error e.response
      end

      unless iterations.nil?
        iterations.each do |i|
          stories = i.stories
          points = 0
          unless stories.nil?
            stories.each do |s|
              points += s.estimate unless s.estimate.nil?
            end
          end
          start_date = i.start.strftime("%Y-%m-%d")
          if pointsHash.member? start_date
            logger.debug "Updating #{start_date} with #{points} points"
            pointsHash[start_date] += (points / divisor )
          else
            logger.debug "Setting #{start_date} to #{points} points"
            pointsHash[start_date] = (points / divisor)  
          end
          @velocities = pointsHash.sort
        end
      end
    end
  end


end
