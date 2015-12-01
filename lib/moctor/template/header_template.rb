require_relative 'base_template'

module Moctor
  module Template
    class HeaderTemplate < BaseTemplate
      attr_reader :types

      def initialize(types)
        @types = types
        @template_file = File.expand_path("#{__dir__}/../../../templates/header_template.hbs")

        helper(:uncapitalize) do |context, arg, block|
          arg[0, 1].downcase + arg[1..-1]
        end

        helper(:linked_actors_consumers) do |context, arg, block|
          if arg.usages.empty?
            ''
          else
            '<' + arg.usages.map { |actor|
              "#{actor}Consumer"
            }.join("\n") + '>'
          end
        end
      end

      def render
        models = self.types.values.select do |type|
          type.is_a? TypeDefinition
        end

        enums = self.types.values.select do |type|
          type.is_a? EnumDefinition
        end

        actors = self.types.values.select do |type|
          type.is_a? ActorDefinition
        end

        template.call(models: models, enums: enums, actors: actors)
      end
    end
  end
end
