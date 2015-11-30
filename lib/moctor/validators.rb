class TypeValidator
  def self.validate(types)
    types.values.each do |type|
      if type.respond_to?(:props)
        type.props.each do |prop, |
          unless types.has_key? prop.type
            raise TypeError.new("Unknown type '#{prop.type}' for prop #{prop.name} in #{type.name} #{type.entity_type} definition")
          end
        end
      end
    end
  end
end

class ActorValidator
  def self.validate(actors)
    actors.values.each do |actor|
      actor.usages.each do |another_actor|
        unless actors.has_key? another_actor
          raise TypeError.new("Unknown actor '#{another_actor}' usage in #{actor} definition")
        end
      end
    end
  end
end
