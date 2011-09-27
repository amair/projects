class TokenManagement < ApplicationController

  @@token = nil

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