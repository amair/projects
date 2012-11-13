class PointsController < PivotalManagement

  def index

    @start_dates = []
    @points = []


    respond_to do |format|
      getPoints unless retrieveProjects.nil?
      format.html {}
      format.xml {
        render :action => "points.rxml", :layout => false
      }
    end
  end

  def getPoints

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
          iterations.each_with_index do |i, i_num|
            @start_dates[i_num] = i.start.strftime("%Y-%m-%d")

            stories = i.stories
            unless stories.nil?
              estimates = Array.new(8,0)

              stories.each do |s|
                unless s.estimate.nil?
                  estimates[s.estimate] += 1
                end
              end
            end
            logger.debug estimates.inspect
            @points[i_num] = estimates
          end

        end
      end
    end

  end

end
