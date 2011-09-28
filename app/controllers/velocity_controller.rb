class VelocityController < PivotalManagement

  def index

    @velocities = []

    respond_to do |format|
      format.html
      format.xml {
        getVelocities unless retrieveProjects.nil?
        render :action => "velocity.rxml", :layout => false
      }
     end
  end

  def getVelocities
    pointsHash = Hash.new
    logger.debug "**** Creating new Hash ****"
    @@projects.each do |p|
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
