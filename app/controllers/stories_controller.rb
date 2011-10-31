class StoriesController < PivotalManagement

  def index
    logger.debug "Story #{params[:id]}"
    unless params[:id].nil?
      retrieveProjects
      @story = lookupStory( params[:id] )

      @tasks =  @story.tasks.all

      @notes = @story.notes.all

    end
  end
end
