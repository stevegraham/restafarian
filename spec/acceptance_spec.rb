require 'spec_helper'

describe Restafarian do
  describe 'HATEOAS' do
    describe 'entering the API at the root' do
      before do
        header 'Accept', 'application/vnd.restafarian+json; version=1; charset=utf-8'
      end

      context 'when the client makes a request with a Restafarian media type' do
        before { get '/' }

        it 'returns a 200 status code' do
          expect(last_response.status).to eq(200)
        end

        it 'returns the correct media type' do
          expect(last_response.headers['Content-Type']).
            to eq('application/vnd.restafarian+json; charset=utf-8')
        end

        it 'returns JSON' do
          expect { JSON.parse(last_response.body) }.to_not raise_error
        end

        it 'lists permitted HTTP methods' do
          expect(last_response.headers['Allow']).
            to eq('GET')
        end

        it 'returns links to available resources corresponding to child resoures in the application routeset' do
          body = JSON.parse(last_response.body)

          children = {
            "widget"   => "/widget",
            "user"     => "/user",
            "signup"   => "/signup",
            "document" => "/documents"
          }

          expect(body['_links']).to eq(children)
        end
      end

      describe 'requesting a collection resource' do
        describe '_properties' do
          it 'is a list of properties corresponding to that of the resource' do
            pending
            expect(resource.properties.keys).to eq(properties)
          end

          it 'has humanized versions of the property names' do
            pending
            resource.properties.each do |key, obj|
              expect(obj.label.to_s).to eq(key.humanize)
            end
          end

          it 'annotates each property with a type hint' do
            pending
            annotated_props = Hash[(properties - ['favourite_colour']).
              map { |p| [p, hinter.hint(p).to_s] }]

            annotated_props.each do |key, type|
              expect(resource.properties[key].type).to eq(type)
            end
          end

          describe 'for a "struct" type' do
            it 'annotates each property with a type hint' do
              pending
              values = %w<red green blue>
              struct = resource.properties.favourite_colour.type

              struct.each_with_index do |(key, value), index|
                expect(key).to eq(values[index].humanize)
                expect(value).to eq(values[index])
              end
            end
          end
        end

        it 'has a humanized name' do
          pending
          expect(resource.label).to eq('Widget')
        end
      end

      describe 'requesting a resource instance'
    end
  end
end
