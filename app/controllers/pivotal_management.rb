module PivotalTracker
  class Project
       element :div_class, String
  end
end

#Open story class to add an element
module PivotalTracker
  class Story
    element :div_class, String
  end

end



class PivotalManagement < ApplicationController

  #@token = nil
  @@projects = nil

  def retrieveProjects
    begin
      PivotalTracker::Client.token = get_token
      logger.debug "Using token #{get_token} to get Projects"
      @@projects = PivotalTracker::Project.all
      logger.debug "Found #{@@projects.length} Projects"

      @@projects.each_with_index {|p, x| p.div_class = "project#{(x % 5).to_s}"
      }

      @@projects
    rescue => e
      logger.debug e.class
      logger.error e.message
    end
  end

  def lookupProject p_id
    div_class="project"
    proj = @@projects.find{|p| p.id == p_id}

    div_class = proj.div_class unless proj.nil?

    div_class
  end

  def get_params
    param_string = ""

    if (!get_token.nil?)
      param_string = "?token=" + get_token.to_s
    end

    param_string
  end

  def lookupStory (id)
    logger.debug "Searching for story #{id}"
    @@projects.each do |p|
      @story = p.stories.find(id)
      logger.debug "Found story #{@story.name}" unless @story.nil?
      break unless @story.nil?
    end
    @story
  end

  private

  def get_token
    logger.debug "#{params}"
    if @token.nil?
      if params[:token]
        @token = params[:token]
        cookies.permanent[:token] = @token unless @token.nil?
        logger.debug "Retrieve Pivotal token #{@token} from page submission and store in cookie"
      else
        if cookies[:token].nil?
          logger.fatal "Cannot figure out tracker token - giving up"
        else
          @token = cookies[:token]
          logger.debug "Retrieving token #{@token} from cookie"
        end
      end
    end
    @token
  end

end
