require 'spec_helper'

describe Restafarian::TypeHinter do
  describe '#hint' do
    subject { Restafarian::TypeHinter.new Widget }

    describe 'inferring the type from the underlying database column' do
      mapping = {
        decimal:  :number,
        float:    :number,
        integer:  :number,
        datetime: :datetime
      }

      mapping.each do |property_name, inferred_type|
        specify { expect(subject.hint property_name).to eq(inferred_type) }
      end
    end

    describe 'inferring the type using model validators' do
      describe 'for acceptance' do
        specify { expect(subject.hint :terms).to eq(:checkbox) }
      end
    end
  end
end
