module Restafarian
  class JavascriptRenderer < Struct.new(:object)
    TEMPLATE_PATH = Engine.root + 'lib/restafarian/templates'
    JS_TEMPLATE   = File.read(TEMPLATE_PATH + 'representation.js.erb')
    VALIDATORS    = YAML.load(File.read(TEMPLATE_PATH + 'validators.yml'))

    def render
      ERB.new(JS_TEMPLATE, $SAFE, '>').result(binding).each_line.map(&:strip).join
    end

    private

    def typed_properties
      ActiveSupport::JSON.encode(object_typed_properties)
    end

    def error_messages
      ActiveSupport::JSON.encode(I18n.t('errors.messages'))
    end

    def validators
      VALIDATORS.slice(*pertinent_validators).
        map { |k,v| "#{k}:#{v.chomp}" }.join ","
    end

    def pertinent_validators
      names = object_as_json.keys.inject([]) do |memo, key|
        validators = object.class.validators_on(key).reject do |validator|
          validator.options[:on] == (object.new_record? ? :create : :update)
        end

        memo.push *validators.map(&:kind)
      end

      names.uniq
    end

    def type_hinter
      @type_hinter ||= TypeHinter.new(object.class)
    end

    def object_validators_on(property)
      object.class.validators_on(property).reduce({}) do |memo, validator|
        options = process_options(validator.options)
        memo.merge validator.kind => options
      end
    end

    def object_as_json
      object.as_json
    end

    def object_name
      object.class.name.humanize
    end

    def object_typed_properties
      object_as_json.reduce({}) do |memo, (property, value)|
        memo.merge property => {
          label:      property.humanize,
          type:       type_hinter.hint(property),
          validators: object_validators_on(property)
        }
      end
    end

    def process_options(options)
      opts = options.map do |k,v|
        case v
        when Regexp
          v = v.source
        end

        [k, v]
      end

      Hash[opts]
    end
  end
end
