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

      describe 'for a "struct" type from an inclusion validator' do
        type = {
          "Red"   => 'red',
          "Green" => 'green',
          "Blue"  => 'blue'
        }

        specify { expect(subject.hint :favourite_colour).to eq(type) }
      end

      describe 'from the property name' do
        types = { image:    ['cover_photo', 'main_image', 'chat_avatar', 'profile_picture'],
                  file:     ['resume_file'],
                  password: ['password', 'password_confirmation'],
                  tel:      ['telephone_number', 'phone_number'],
                  url:      ['blog_url'],
                  number:   ['lucky_number'] }

        types.each do |type, examples|
          examples.each do |example|
            specify { expect(subject.hint(example)).to eq(type) }
          end
        end
      end

      describe 'for an unknown type' do
        it 'falls back to :text' do
          expect(subject.hint('unknown_type')).to eq(:text)
        end
      end
    end
  end
end
