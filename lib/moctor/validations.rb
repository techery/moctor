module Moctor
  class BaseValidation
    attr_reader :errors

    def initialize(*args)
      @errors = []
    end
  end

  class NotEmptyValidation < BaseValidation
  end

  class LengthValidation < BaseValidation
    def initialize(options)
      super
    end
  end

  class RegexValidation < BaseValidation
    def initialize(regex)
      super
    end
  end
end
