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
      inclusion_validator = validators.detect { |v| v.kind == :inclusion }

      case
      when validators.any? { |v| v.kind == :acceptance }
        :checkbox
      when inclusion_validator.present?
        infer_from_inclusion_validator \
          inclusion_validator
      end
    end

    def infer_from_inclusion_validator(validator)
      type = validator.options[:in].map do |i|
        [i.humanize, i]
      end

      Hash[type]
    end

    def mapping
      Hash[klass.column_types.map { |k,v| [k, v.type] }].with_indifferent_access
    end
  end
end
