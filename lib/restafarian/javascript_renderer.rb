module Restafarian
  class JavascriptRenderer < Struct.new(:object)
    TEMPLATE = File.read \
      File.join(Engine.root, 'lib/restafarian/erb/representation.js.erb')

    def render
      ERB.new(TEMPLATE, $SAFE, '>').result(binding)
    end

    private

    def object_name
      object.class.name.humanize
    end
  end
end

__END__
