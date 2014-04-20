module Restafarian
  class JavascriptRenderer < Struct.new(:object)
    TEMPLATE = File.read \
      File.join(Engine.root, 'lib/restafarian/erb/representation.js.erb')

    def render
      ERB.new(TEMPLATE, $SAFE, '>').result(binding)
    end

    private

    def type_hinter
      @type_hinter ||= TypeHinter.new(object.class)
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
          type:       type_hinter.hint(property)
        }
      end
    end
  end
end
