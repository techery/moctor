require_relative 'type_system'
require_relative 'validators'

module Moctor
  def self.define(&block)
    lang = Lang.new
    lang.instance_eval(&block)

    ts = TypeSystem.instance

    TypeValidator.validate(ts.types)
    ActorValidator.validate(ts.actors)
  end
end
