require 'fileutils'

require_relative 'header_template'
require_relative 'body_template'

module Moctor
  module Template
    class TemplateRenderer
      attr_reader :output_directory
      attr_reader :file_name

      def initialize(output_directory, file_name)
        @output_directory = output_directory
        @file_name = file_name
      end

      def render(types)
        FileUtils.mkdir_p(output_directory)

        build_head(types)
        build_body(types)
      end

      def build_body(types)
        body_template = BodyTemplate.new(types)
        body_content = body_template.render
        body_path = "#{output_directory}/#{file_name}.m"
        File.write(body_path, body_content)
      end

      def build_head(types)
        header_template = HeaderTemplate.new(types)
        header_content = header_template.render
        header_path = "#{output_directory}/#{file_name}.h"
        File.write(header_path, header_content)
      end
    end
  end
end
