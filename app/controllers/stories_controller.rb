class StoriesController < PivotalManagement

  def index
    logger.debug "Story #{params[:id]}"
    unless params[:id].nil?
      retrieveProjects
      @story = lookupStory( params[:id] )

      @tasks =  @story.tasks.all
      #unless @story.tasks.nil? || @story.tasks.empty?
      #  @story.tasks.each do |task|
      #    if (!task.complete)
      #    end
      #  end
      #end

    end
  end
end
