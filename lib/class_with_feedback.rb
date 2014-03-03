
module Uhuru
  module  Webui
    # Class used to display in a modal app create steps and their outcome
    class ClassWithFeedback

      attr_accessor :id

      # Creates a new file in the temp folder where the outcome steps is written
      # id = app id
      #
      def start_feedback(id = nil)
        @data_dir = File.join(Dir.tmpdir, "webui_messages")
        FileUtils.mkdir_p @data_dir

        @id = id || SecureRandom.uuid

        @data_file = File.join(@data_dir, @id)

        if id == nil
          FileUtils.touch(@data_file)
        end
      end

      # Writes a info message with no new line after
      #
      def info(message)
        write_message message, 'info'
      end

      # Writes a ok message with no new line after
      #
      def ok(message)
        write_message message, 'ok'
      end

      # Writes a warning message with no new line after
      #
      def warning(message)
        write_message message, 'warning'
      end

      # Writes a error message with no new line after
      #
      def error(message)
        write_message message, 'error'
      end

      # Writes a info message with a new line after
      #
      def info_ln(message)
        write_message message, 'info', true
      end

      # Writes a ok message with a new line after
      #
      def ok_ln(message)
        write_message message, 'ok', true
      end

      # Writes a warning message with a new line after
      #
      def warning_ln(message)
        write_message message, 'warning', true
      end

      # Writes a error message with a new line after
      #
      def error_ln(message)
        write_message message, 'error', true
      end

      # Display content of the feedback file until all the app create steps are processed
      #
      def content
        if File.exist?(@data_file)
          if File.exist?("#{@data_file}.done")
            [:done, File.read(@data_file)]
          else
            [:continue, File.read(@data_file)]
          end
        else
          [:stop, nil]
        end
      end

      # Closes feedback file
      #
      def close_feedback
        FileUtils.touch "#{@data_file}.done"
      end

      # Starts a new feedback file for an app
      # id = app id
      #
      def self.content(id)
        obj = ClassWithFeedback.new()
        obj.start_feedback(id)
        obj.content
      end

      # Removes all content in the temp directory for apps feedback
      #
      def self.cleanup
        data_dir = File.join(Dir.tmpdir, "webui_messages")
        FileUtils.rm_rf data_dir
      end

      private

      # Writes the messages in a html format for the modal window into feedback file
      # message = message to be written
      # type = type of message - info, ok, error, etc.
      # with_break = parameter saying to write a new line after message or not
      #
      def write_message(message, type, with_break = false)
        File.open(@data_file, 'a') do |file|
          no_indent = message.gsub(/\A\s+/, '')

          indent_px = (message.size - no_indent.size) * 12

          file.sync = true
          file.write("<div style='margin-left:#{indent_px}px' class='feedback #{type}'>#{no_indent}</div>#{with_break ? '<br />' : ''}")
        end
      end

    end
  end
end