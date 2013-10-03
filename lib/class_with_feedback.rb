
module Uhuru
  module  Webui
    class ClassWithFeedback

      attr_accessor :id

      def initialize(id = nil)
        @data_dir = File.join(Dir.tmpdir, "webui_messages")
        FileUtils.mkdir_p @data_dir

        @id = id || SecureRandom.uuid

        @data_file = File.join(@data_dir, @id)

        if id == nil
          FileUtils.touch(@data_file)

          ObjectSpace.define_finalizer(self, proc do
            if File.exist?(@data_file)
              File.delete @data_file
            end
          end)
        end
      end


      def info(message)
        File.open(@data_file, 'a') do |file|
          file.write("<div class='feedback info'>#{message}</div>")
        end
      end

      def warning(message)
        File.open(@data_file, 'a') do |file|
          file.write("<div class='feedback warning'>#{message}</div>")
        end
      end

      def error(message)
        File.open(@data_file, 'a') do |file|
          file.write("<div class='feedback error'>#{message}</div>")
        end
      end

      def content
        if File.exist?(@data_file)
          File.read(@data_file)
        else
          [ :STOP ]
        end
      end

      def close
        if File.exist?(@data_file)
          File.delete @data_file
        end
      end

      def self.content(id)
        ClassWithFeedback.new(id).content
      end
    end
  end
end