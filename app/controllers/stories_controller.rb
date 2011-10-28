class StoriesController < PivotalManagement

  def index
    logger.debug "Story #{params[:id]}"
    unless params[:id].nil?
      logger.debug "Retrieve story"
      retrieveProjects
      @story = lookupStory( params[:id] )
    end
  end
end
