class PivotalManagement < ApplicationController

  @@token = nil
  @@projects = nil

  def retrieveProjects
    begin
      PivotalTracker::Client.token = get_token
      logger.debug "Using token #{get_token} to get Projects"
      @@projects = PivotalTracker::Project.all
      logger.debug "Found #{@@projects.length} Projects"
      @@projects
    rescue => e
      logger.error e.response
    end
  end

  private
  def get_token
    if @@token.nil?
      if cookies[:token].nil?
        if params[:token].nil?
          logger.fatal "Cannot figure out tracker token - giving up"
        else
          @@token = params[:token]
          cookies.permanent[:token] = @@token unless @@token.nil?
          logger.debug "Retrieve Pivotal token #{@@token} from page submission and store in cookie"
        end
      else
        @@token = cookies[:token]
        logger.debug "Retrieving token #{@@token} from cookie"
      end
    else
      logger.debug "Using session value for token"
    end
    @@token
  end

end