class VelocityController < ApplicationController

  def index

    @velocities = []
    if @token.nil?
      if cookies[:token].nil?
        if params[:token].nil?
          logger.fatal "Cannot figure out tracker token - giving up"
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

    respond_to do |format|
      format.html
      format.xml {
        retrieveProjects unless @token.nil?
        render :action => "velocity.rxml", :layout => false
      }
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
            pointsHash[start_date] += (points.to_f / divisor )
          else
            logger.debug "Setting #{start_date} to #{points} points"
            pointsHash[start_date] = (points.to_f / divisor)
          end
          @velocities = pointsHash.sort

          calculateMovingAverages
        end
      end
    end
  end

  def calculateMovingAverages
    j=0
    @movingAverage = []
    length = @velocities.length
    while j<= (length -3)
      @movingAverage[j] = (@velocities[j][1] + @velocities[j+1][1] + @velocities[j+2][1]).to_f / 3
      j+=1
    end
  end
end
