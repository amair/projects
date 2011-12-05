require 'rubygems'
require 'prawn'
require 'rainbow'
require "prawn/measurement_extensions"
require 'tempfile'


#Open story class to add an element
module PivotalTracker
  class Story

    def label_text
      return "" if !self.respond_to?(:labels) || self.labels.nil? || self.labels.empty?
      labels.force_encoding("UTF-8")
    end

    def task_list
      all_tasks = self.tasks.all #Retrieve the tasks from the network
      return "" if !self.respond_to?(:tasks) || all_tasks.nil?
      task_string=""
      all_tasks.each do |task|
        if (!task.complete)
          task_string = task_string << "* " << task.description.force_encoding("UTF-8") << "\n"
        end
      end
      task_string
    end

    def points
      return nil unless self.story_type.eql?("feature")
      "Points: " + (self.respond_to?(:estimate) && !self.estimate.eql?(-1) ? self.estimate.to_s : "Not yet estimated")
    end

    def story_color
      return "0000FF" if self.div_class.eql? "project0"
      return "FFFF00" if self.div_class.eql? "project1"
      return "00FF00" if self.div_class.eql? "project2"
      return "00FFFF" if self.div_class.eql? "project3"
      return "FF0000" if self.div_class.eql? "project4"
      return "ffb500" if self.div_class.eql? "project5"
      return "000000" # For Unknown
    end

    private

    ["feature", "bug", "chore", "release"].each do |type_str|
      class_eval <<-EOS
      def #{type_str}?
      self.story_type == "#{type_str}"
    end
      EOS
    end

  end
end


module Pdf
  class Generator

    MARGIN = 5.mm

    def initialize(story_list)
      @filename = Tempfile.new(["Test", ".pdf"])
      @stories = story_list
    end

    def write_to

      Prawn::Document.new(:page_layout => :landscape,
                          :page_size => "A4",
                          :left_margin => 5.mm) do |pdf|

        pdf.font "#{Prawn::BASEDIR}/data/fonts/DejaVuSans.ttf"

        index = 0

        @stories.each do |story|

          bb = get_bounding_box(index %4)

          # --- Write content
          pdf.bounding_box [bb[:left], bb[:top]], :width => bb[:width], :height => bb[:height] do

            pdf.stroke_color = story.story_color
            pdf.line_width=6
            pdf.stroke_bounds

            # We want to inset the text from the border which has been painted
            pdf.bounding_box [MARGIN, pdf.bounds.top-MARGIN], :width => 120.mm, :height => bb[:height] - MARGIN*2 do

              pdf.text story.name.force_encoding("UTF-8"), :size => 14
              pdf.fill_color "52D017"
              pdf.text story.label_text, :size => 8
              pdf.text "\n", :size => 14
              pdf.fill_color "444444"
              pdf.text story.description.force_encoding("UTF-8") || "", :size => 10

              #pdf.fill_color ""
              pdf.text story.task_list, :size => 8

              pdf.fill_color "000000"
              pdf.text_box story.points, :size => 12, :align => :center, :valign => :bottom unless story.points.nil?

              #pdf.text_box "Owner: " + (story.respond_to?(:owned_by) ? story.owned_by : "None"), :size => 8, :valign => :bottom

              pdf.fill_color "999999"
              pdf.text_box story.story_type.force_encoding("UTF-8").capitalize, :size => 8, :align => :right, :valign => :bottom
              pdf.fill_color "000000"
            end
          end
          index = index + 1

          if (index % 4) == 0
            pdf.start_new_page unless index == @stories.size
          end

        end
        @filename.write (pdf.render().force_encoding("UTF-8"))
      end


    rescue Exception
      puts "[!] There was an error while generating the PDF file... What happened was:".foreground(:red)
      raise
    else
      @filename
    ensure
      @filename.close unless @filename.nil?
    end


    def get_bounding_box(position)
      case (position)
        when 0
          {:top => 185.mm, :left => 0.mm, :width => 140.mm, :height => 90.mm}
        when 1
          {:top => 185.mm, :left => 148.mm, :width => 140.mm, :height => 90.mm}
        when 2
          {:top => 80.mm, :left => 0.mm, :width => 140.mm, :height => 90.mm}
        when 3
          {:top => 80.mm, :left => 148.mm, :width => 140.mm, :height => 90.mm}
        else
          {:top => 0.mm, :left => 0.mm, :width => 140.mm, :height => 90.mm}
      end
    end
  end

end

