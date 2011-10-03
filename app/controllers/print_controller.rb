class PrintController < PivotalManagement

  @stories=[]

  def index

    get_stories unless retrieveProjects.nil?

  end

  def create
    print_stories = params[:story]

    retrieveProjects
    @stories=[]

    @ps=Hash.new

    print_stories.each do |s|
      str = s.split

      @ps[str[0]] = Array.new if !@ps.has_key? str[0]
      @ps[str[0]].push str[1]
    end

    @ps.each do |project_id, stories|
     stories.each do |s|
        @stories.concat get_story project_id, s
       print s
      end
    end

  end

  def filter_stories
    filtered_stories = yield

    filtered_stories.each { |s| s.div_class = lookupProject s.project_id } unless filtered_stories.empty?
  end

  def get_story (project_id, story_id)
    @@projects.each do |p|
      if p.id == project_id
        p.stories.find(story_id)
      end
    end
  end

  def get_stories

    @stories=[]
    if (!@@projects.nil?)
      @@projects.each do |p|
        logger.debug "Getting Stories for project #{p.id}"

        begin
          var = p.stories.all(:current_state => 'unstarted', :story_type => ['feature', 'bug', 'chore'])
        rescue => e
          logger.error e.response
        end

        @stories.concat(var) unless var.nil?

        logger.debug "Retrieved #{var.length} stories"

      end
      logger.debug "Got all stories!"
    end

  end
end
