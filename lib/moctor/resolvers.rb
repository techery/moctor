module Moctor
  class TypeResolver
    class TypeResolvingError < RuntimeError; end

    attr_accessor :types

    def initialize(types)
      @types = types
    end

    def resolve
      Hash[self.types.map do |type, definition|
        [type, resolve_definition(definition)]
      end]
    end

    def resolve_definition(definition)
      if definition.is_a?(TypeDefinition)
        resolve_model_types(definition)
      elsif definition.is_a?(ActorDefinition)
        resolve_actor_types(definition)
      else
        definition
      end
    end

    def resolve_model_types(model)
      model.props = model.props.map do |prop|
        if self.types[prop.type]
          PropDefinition.new(prop.name, self.types[prop.type])
        elsif prop.type.is_a? Symbol
          raise TypeResolvingError.new("Can't resolve prop type '#{prop.type}' for prop #{prop.name} in #{model.name} #{model.entity_type} definition")
        else
          prop
        end
      end
      model
    end

    def resolve_actor_types(actor)
      actor = actor.clone

      actor.usages = actor.usages.map do |actor_link|
        if self.types[actor_link]
          resolve_definition(self.types[actor_link])
        elsif actor_link.is_a? Symbol
          raise TypeResolvingError.new("Can't resolve actor '#{actor_link}'")
        else
          actor_link
        end
      end

      actor.actions = actor.actions.map do |action|
        if self.types[action.name]
          action_type = resolve_definition(self.types[action.name])
          result_type = resolve_definition(self.types[action.type])
          ActionDefinition.new(action_type, result_type)
        elsif action.type.is_a? Symbol
          raise TypeResolvingError.new("Can't resolve action '#{action}'")
        else
          action
        end
      end

      actor
    end
  end
end
