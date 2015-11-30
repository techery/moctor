require 'singleton'

module Moctor
  class TypeSystem
    include ::Singleton

    TypeError          = Class.new(RuntimeError)
    RedefinitionError  = Class.new(TypeError)

    attr_accessor :types, :interfaces, :validations, :actors

    def initialize
      @types = {
        bool:   TypeDefinition.new(:bool),
        float:  TypeDefinition.new(:float),
        int:    TypeDefinition.new(:int),
        string: TypeDefinition.new(:string)
      }

      @interfaces  = {}
      @actors      = {}
      @validations = {}

      # @validations = {
      #   not_empty:   NotEmptyValidation.new,
      #   length_in:   LengthValidation.new(minimal: range.begin, maximal: range.end),
      #   min_length:  LengthValidation.new(minimal: number),
      #   max_length:  LengthValidation.new(maximal: number),
      #   match_regex: RegexValidation.new(regex),
      # }
    end

    def register_type(name, type_definition)
      if types.has_key? name
        raise RedefinitionError.new("Type '#{name}' is already defined")
      end

      types[name] = type_definition
    end

    def register_validation(name, definition)
      if validations.has_key? name
        raise RedefinitionError.new("Validation '#{name}' is already defined")
      end

      validations[name] = definition
    end

    def register_actor(name, definition)
      register_type(name, definition)

      actors[name] = definition
    end

    def register_interface(name, definition)
      register_type(name, definition)

      interfaces[name] = definition
    end
  end

  PropDefinition       = Struct.new(:name, :type, :validations)
  ValidationDefinition = Struct.new(:name, :args)

  class Lang
    def interface(name, &block)
      raise TypeError, 'Interface name must be a symbol' unless name.is_a? Symbol

      definition = InterfaceDefinition.new(name, &block)
      TypeSystem.instance.register_interface(name, definition)
    end

    def enum(name, &block)
      raise TypeError, 'Enum name must be a symbol' unless name.is_a? Symbol

      definition = EnumDefinition.new(name, &block)
      TypeSystem.instance.register_type(name, definition)
    end

    def type(signature, &block)
      case signature
        when Hash
          name, base = signature.first
        when Symbol
          name = signature
          base = nil
        else
          raise TypeError, "Unknown type signature: #{signature}"
      end

      definition = TypeDefinition.new(name, base, &block)
      TypeSystem.instance.register_type(name, definition)
    end

    def actor(name, &block)
      unless name.is_a? Symbol
        raise TypeError, 'Actor name must be a symbol'
      end

      definition = ActorDefinition.new(name, &block)
      TypeSystem.instance.register_actor(name, definition)
    end

    def validation(name, &block)
      unless name.is_a? Symbol
        raise TypeError, 'Validation group name must be a symbol'
      end

      definition = ValidationGroupDefinition.new(name, &block)
      ::Moctor::TypeSystem.instance.register_validation(name, definition)
    end
  end

  class EnumDefinition
    attr_reader :name, :cases

    def initialize(name, &block)
      @name  = name
      @cases = []
      instance_eval(&block)
    end

    def opt(name, value = nil)
      unless name.is_a? Symbol
        raise TypeError, 'Enum attribute name must be a symbol'
      end

      @cases << {
        name: name,
        value: value
      }
    end

    def entity_type
      'enum'
    end
  end

  class ActorDefinition
    attr_reader :name, :usages, :actions

    def initialize(name, &block)
      @name    = name
      @usages  = []
      @actions = []
      instance_eval(&block)
    end

    def use(another_actor_name)
      unless another_actor_name.is_a? Symbol
        raise TypeError, 'Actor name must be a symbol'
      end

      @usages << another_actor_name
    end

    def action(signature, &block)
      case signature
        when Hash
          action_name, action_type = signature.first
        when Symbol
          action_name = signature
          action_type = nil
        else
          raise "Unknown action signature: #{signature}"
      end

      @actions << ActionPropDefinition.new(action_name, action_type, &block)
    end
  end

  class ActionPropDefinition
    attr_reader :name, :type, :props

    def initialize(name, type, &block)
      @name = name
      @type = type
      @props = []
      instance_eval(&block)
    end

    def prop(prop_name, prop_type)
      unless prop_name.is_a? Symbol
        raise TypeError, 'Prop name must be a symbol'
      end

      unless prop_type.is_a? Symbol
        raise TypeError, 'Prop type must be a symbol'
      end

      @props << PropDefinition.new(prop_name, prop_type, [])
    end
  end

  class InterfaceDefinition
    attr_reader :name, :props

    def initialize(name, &block)
      @name = name
      @props = []
      instance_eval(&block)
    end

    def prop(prop_name, type)
      raise 'Prop name must be a symbol' unless prop_name.is_a? Symbol
      raise 'Prop type must be a symbol' unless type.is_a?      Symbol

      @props << PropDefinition.new(name, type, [])
    end

    def entity_type
      'interface'
    end
  end

  class TypeDefinition
    attr_reader :name, :base, :props, :interfaces

    def initialize(name, base = nil, &block)
      @name       = name
      @base       = base
      @props      = []
      @interfaces = []
      instance_eval(&block) if block_given?
    end

    def implements(name)
      unless name.is_a? Symbol
        raise TypeError, 'Interface name must be a symbol'
      end

      @interfaces << name
    end

    def prop(name, type, options = {})
      unless name.is_a? Symbol
        raise TypeError, 'Prop name must be a symbol'
      end

      unless type.is_a? Symbol
        raise TypeError, 'Prop type must be a symbol'
      end

      validations = options.fetch(:validate, [])
      validations = [validations] unless validations.is_a?(Array)
      @props << PropDefinition.new(name, type, validations)
    end

    def method_missing(validation_name, *args)
      {
        name: validation_name,
        args: args
      }
    end

    def entity_type
      'type'
    end
  end

  class ValidationGroupDefinition
    attr_reader :name, :validations

    def initialize(name, &block)
      @name = name
      @validations = []
      instance_eval(&block)
    end

    def method_missing(validation_name, *args)
      @validations << {
        name: validation_name,
        args: args
      }
    end
  end
end
