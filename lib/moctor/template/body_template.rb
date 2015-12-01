require_relative 'base_template'

module Moctor
  module Template
    class BodyTemplate < BaseTemplate
      attr_reader :types

      def initialize(types)
        @types = types
        @template_file = File.expand_path("#{__dir__}/../../../templates/body_template.hbs")
      end

      def render
        models = self.types.values.select do |type|
          type.is_a? TypeDefinition
        end

        actors = self.types.values.select do |type|
          type.is_a? ActorDefinition
        end

        template.call(models: models, actors: actors, name: 'Result')
      end
    end
  end
end
