require_relative 'type_system'
require_relative 'validators'
require_relative 'transformers'
require_relative 'template/template_renderer'

module Moctor
  def self.define(&block)
    lang = Lang.new
    lang.instance_eval(&block)

    ts = TypeSystem.instance

    TypeValidator.validate(ts.types)
    ActorValidator.validate(ts.actors)

    type_transformer = ObjcTypeTransformer.new(prefix: 'DT')
    native_types = type_transformer.transform(ts.types)

    output_directory = './Gen'
    file_name = 'Result'

    renderer = Template::TemplateRenderer.new(output_directory, file_name)
    renderer.render(native_types)
  end
end
