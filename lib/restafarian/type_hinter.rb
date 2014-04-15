module Restafarian
  class TypeHinter < Struct.new(:klass)
    def hint(property)
      infer_from_column(property) ||
      infer_from_validators(property)
    end

    private

    def infer_from_column(property)
      case mapping[property]
      when :decimal, :float, :integer then :number
      when :datetime then :datetime
      end
    end

    def infer_from_validators(property)
      validators = klass.validators_on(property)

      :checkbox if validators.any? { |v| v.kind == :acceptance }
    end

    def mapping
      Hash[klass.column_types.map { |k,v| [k, v.type] }].with_indifferent_access
    end
  end
end
