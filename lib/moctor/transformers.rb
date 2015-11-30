class ObjcTypeTransformer
  attr_reader :prefix

  def initialize(prefix: '')
    @prefix = prefix
  end

  TYPES_MAPPING = {
    int:    :NSInteger,
    bool:   :BOOL,
    float:  :float,
    string: :NSString,
  }

  def transform(types)
    transformed_types = types.values.map do |type|
      new_name = TYPES_MAPPING[type.name] || type.name

      new_type = type.clone.tap do |t|
        t.name = "#{prefix}#{new_name}"
      end

      [new_name, new_type]
    end

    transformed_types.to_h
  end
end
