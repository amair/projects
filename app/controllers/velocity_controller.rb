class VelocityController < PivotalManagement

  @showbugs = 0

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
    bugsHash = Hash.new

    if (!@@projects.nil?)
      @@projects.each do |p|
        logger.debug "Getting iterations for project #{p.id}"
        logger.debug "Project using point scheme #{p.point_scale}"

        begin
          iterations = PivotalTracker::Iteration.done(p)
        rescue => e
          logger.error e.response
        end

        unless iterations.nil?
          iterations.each do |i|
            stories = i.stories
            points = 0
            bugs = 0
            unless stories.nil?
              stories.each do |s|
                points += s.estimate unless s.estimate.nil?

                if s.story_type.eql?("bug") || s.story_type.eql?("chore")
                  bugs += 1
                end
              end
            end

            start_date = i.start.strftime("%Y-%m-%d")

            if pointsHash.member? start_date
              logger.debug "Updating #{start_date} with #{points} points"
              pointsHash[start_date] += (points.to_f)
            else
              logger.debug "Setting #{start_date} to #{points} points"
              pointsHash[start_date] = (points.to_f)
            end

            if bugsHash.member? start_date
              bugsHash[start_date] += bugs
            else
              bugsHash[start_date] = bugs
            end

          end
          @velocities = pointsHash.sort
          @bugs = bugsHash.sort

          calculateMovingAverages
        end
      end
    end

  end

  def includeBugs?
    !@showbugs.nil?
  end

  def bugsParams
    if includeBugs?
      logger.debug "Show bugs"
      "&showbugs=1"
    else
      logger.debug "Hide bugs"
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
