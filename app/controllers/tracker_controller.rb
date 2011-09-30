#Open story class to add an element
module PivotalTracker
  class Story
    element :div_class, String
  end
end


class TrackerController < PivotalManagement
  def index

    getStories unless retrieveProjects.nil?

  end

  def getStories
    stories = []
    @all_development = []
    @all_testing = []
    @all_completed = []

    if (!@@projects.nil?)
      @@projects.each do |p|
        logger.debug "Getting Stories for project #{p.id}"

        begin
          iteration = PivotalTracker::Iteration.current(p)
        rescue => e
          logger.error e.response
        end

        stories = iteration.stories
        logger.debug "Retrieved #{stories.length} stories"

        subset = stories.select { |s| s.current_state == 'started' && s.story_type != 'release' }
        logger.debug "There are #{subset.length} started stories"
        @all_development += subset unless subset.empty?

        @all_development.each { |s| s.div_class  = lookupProject s.project_id}

        # TODO Need to decide if we should include 'not yet started' stories #
        subset = stories.select { |s| s.current_state == 'delivered' && s.story_type != 'release' }
        logger.debug "There are #{subset.length} delivered stories"
        @all_testing += subset unless subset.empty?

        @all_testing.each { |s| s.div_class  = lookupProject s.project_id}

        subset = stories.select { |s| s.current_state == 'accepted' && s.story_type != 'release' }
        logger.debug "There are #{subset.length} accepted stories"
        @all_completed += subset unless subset.empty?

        @all_completed.each { |s| s.div_class  = lookupProject s.project_id}
      end
      logger.debug "Got all stories!"
    end
  end


end
