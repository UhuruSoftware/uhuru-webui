
module Uhuru
  module  Webui
    class ClassWithFeedback

      attr_accessor :id

      def start_feedback(id = nil)
        @data_dir = File.join(Dir.tmpdir, "webui_messages")
        FileUtils.mkdir_p @data_dir

        @id = id || SecureRandom.uuid

        @data_file = File.join(@data_dir, @id)

        if id == nil
          FileUtils.touch(@data_file)
        end
      end


      def info(message)
        write_message message, 'info'
      end

      def ok(message)
        write_message message, 'ok'
      end

      def warning(message)
        write_message message, 'warning'
      end

      def error(message)
        write_message message, 'error'
      end

      def info_ln(message)
        write_message message, 'info', true
      end

      def ok_ln(message)
        write_message message, 'ok', true
      end

      def warning_ln(message)
        write_message message, 'warning', true
      end

      def error_ln(message)
        write_message message, 'error', true
      end

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

      def close_feedback
        FileUtils.touch "#{@data_file}.done"
      end

      def self.content(id)
        obj = ClassWithFeedback.new()
        obj.start_feedback(id)
        obj.content
      end

      def self.cleanup
        data_dir = File.join(Dir.tmpdir, "webui_messages")
        FileUtils.rm_rf data_dir
      end

      private

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