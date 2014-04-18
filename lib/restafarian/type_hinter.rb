module Restafarian
  class TypeHinter < Struct.new(:klass)
    def hint(property)
      infer_from_column(property) ||
      infer_from_validators(property) ||
      infer_from_property_name(property)
    end

    private

    def infer_from_property_name property
      case property.to_s.gsub('_', ' ')
      when /\bemail\b/ then :email
      when /\bphoto\b/, /\bimage\b/, /\bavatar\b/, /\bpicture\b/ then :image
      when /\bfile\b/ then :file
      when /\bpassword\b/ then :password
      when /\btelephone\b/, /\bphone\b/ then :tel
      when /\burl\b/ then :url
      when /\bnumber\b/ then :number
      else :text
      end
    end

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
