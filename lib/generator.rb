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
      return "" if !self.respond_to?(:tasks) || self.tasks.nil? || self.tasks.empty?
      task_string=""
      tasks.each do |task|
        if (!task.complete)
          task_string = task_string << "* " << task.description << "\n"
        end
      end
      task_string
    end

    def points
      return nil unless :story_type == "feature"
      "Points: " + (self.respond_to?(:estimate) && !self.estimate.eql?(-1) ? self.estimate.to_s : "Not yet estimated")
    end
  end

  def story_color
    return "52D017" if feature?
    return "FF0000" if bug?
    return "FFFF00" if chore?
    return "000000" # For Releases or Unknown type
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
                          :margin => [12.mm, 12.mm, 10.mm, 10.mm]) do |pdf|

        pdf.font "#{Prawn::BASEDIR}/data/fonts/DejaVuSans.ttf"

        index = 0

        @stories.each do |story|

          # We only want to print stories which aren't release milestones and
          # that still have work to be done (aren't accepted)
          if story.story_type != "release" && story.current_state != "accepted"

            bb = Hash.new
            bb = get_bounding_box(index %4)

            # --- Write content
            pdf.bounding_box [bb[:left], bb[:top]], :width => bb[:width], :height => bb[:height] do

              pdf.stroke_color = "000000"
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
                #pdf.text story.tasks, :size => 8

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

          else
            puts "Skipping story (" << story.id.to_s << ") "<< story.name

          end
        end
        #      pdf.number_pages "<page>/<total>", {:at => [pdf.bounds.right - 16.mm, 2.mm]}

        #file_data = pdf.render()
        @filename.write (pdf.render().force_encoding("UTF-8"))

        @filename.close

        #@filename.unlink  deletes the temp file

        puts ">>> Generated PDF file in '#{@filename}'".foreground(:green)
      end
    rescue Exception
      puts "[!] There was an error while generating the PDF file... What happened was:".foreground(:red)
      raise
    end

    def get_bounding_box(position)
      case (position)
        when 0
          {:top => 190.mm, :left => 0.mm, :width => 130.mm, :height => 90.mm}
        when 1
          {:top => 190.mm, :left => 143.mm, :width => 130.mm, :height => 90.mm}
        when 2
          {:top => 90.mm, :left => 0.mm, :width => 130.mm, :height => 90.mm}
        when 3
          {:top => 90.mm, :left => 143.mm, :width => 130.mm, :height => 90.mm}
        else
          {:top => 0.mm, :left => 0.mm, :width => 130.mm, :height => 90.mm}
      end
    end
  end
end

