class VelocityController < ApplicationController

  def index

    @velocities = Hash.new

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
    @projects.each do |p| 
      logger.debug "Getting iterations for project #{p.id}"
      logger.debug "Project using point scheme #{p.point_scale}"

      if (p.point_scale=="0,1,2,3,4,5,6")
        logger.debug "halving all points for this project"
        divisor = 2
      else
        divisor = 1
      end

      begin
        # Get last 3 iterations for the project
        #iteration = PivotalTracker::Iteration.done(p, :offset => '-3')
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
          if @velocities[i.start.to_s].nil? 
            @velocities[i.start.to_s] = (points / divisor )
            logger.debug "Setting #{i.start.to_s} to #{points}"
          else
            @velocities[i.start.to_s] = (points / divisor) + @velocities[i.start.to_s]
            logger.debug "Updating #{i.start.to_s} with #{points}"
          end
        end
      end

    end
  end


end
