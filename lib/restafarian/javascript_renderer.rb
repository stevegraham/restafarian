module Restafarian
  class JavascriptRenderer < Struct.new(:object)
    TEMPLATE = File.read \
      File.join(Engine.root, 'lib/restafarian/templates/representation.js.erb')
    VALIDATORS = YAML.load \
      File.read(File.join(Engine.root, 'lib/restafarian/templates/validators.yml'))

    def render
      ERB.new(TEMPLATE, $SAFE, '>').result(binding).
        each_line.map(&:strip).join
    end

    private

    def validators
      VALIDATORS.map { |k,v| "#{k}: #{v.chomp}" }.join ","
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
