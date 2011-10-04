require 'generator'

class PrintController < PivotalManagement

  @stories=[]

  def index

    get_filtered_stories unless retrieveProjects.nil?

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

    @ps.each do |project_id, story_ids|
      story_ids.each do |s_id|
        @stories.push get_story project_id, s_id
      end
    end

    pdf = Pdf::Generator.new(@stories)
    file = pdf.write_to

    send_file file.path, :type=>"application/pdf" unless file.nil?

    file.unlink  # deletes the temp file

  end


  def get_story (project_id, story_id)
    story = []
    @@projects.each do |p|
      print p
      if p.id.to_s == project_id
        story = p.stories.find(story_id)
      end
    end
    story
  end

  def filter_stories
    filtered_stories = yield

    filtered_stories.each { |s| s.div_class = lookupProject s.project_id } unless filtered_stories.empty?
  end


  def get_filtered_stories
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
