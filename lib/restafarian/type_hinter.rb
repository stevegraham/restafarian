module Restafarian
  class TypeHinter < Struct.new(:object)
    def hint(property)
      infer_from_column(property)
    end

    private

    def infer_from_column(property)
      case mapping[property]
      when :decimal, :float, :integer then :number
      when :datetime then :datetime
      end
    end

    def mapping
      Hash[object.class.column_types.map { |k,v| [k, v.type] }].
        with_indifferent_access
    end
  end
end
