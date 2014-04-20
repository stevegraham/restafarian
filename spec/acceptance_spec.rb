require 'spec_helper'

describe Restafarian do
  describe 'HATEOAS' do
    describe 'entering the API at the root' do
      before do
        header 'Accept', 'application/vnd.restafarian.resource+json; version=1; charset=utf-8'
      end

      context 'when the client makes a request with a Restafarian media type' do
        before { get '/' }

        it 'returns a 200 status code' do
          expect(last_response.status).to eq(200)
        end

        it 'returns the correct media type' do
          expect(last_response.headers['Content-Type']).
            to eq('application/vnd.restafarian.resource+json; version=1; charset=utf-8')
        end

        it 'returns JSON' do
          expect { JSON.parse(last_response.body) }.to_not raise_error
        end

        it 'returns links to available resources corresponding to child resoures in the application routeset' do
          body = JSON.parse(last_response.body)

          children = {
            "widget" => "http://example.org/widget",
            "bank_accounts"=>"http://example.org/bank_accounts",
            "charges"=>"http://example.org/charges"
          }

          expect(body['child_resources']).to eq(children)
        end
      end
    end

    describe 'requesting a resource specification' do
      context 'when the client makes a request with a Restafarian media type' do
        before do
          header 'Accept', 'application/vnd.restafarian.resource+js; version=1'
          get    '/widget'

          jsctx.eval(last_response.body)
        end

        let(:jsctx)      { V8::Context.new }
        let(:hinter)     { Restafarian::TypeHinter.new Widget }
        let(:properties) { Widget.new.as_json.keys }

        it 'returns a 200 status code' do
          expect(last_response.status).to eq(200)
        end

        it 'lists permitted HTTP methods' do
          expect(last_response.headers['Allow']).
            to eq('POST, GET, PATCH, PUT, DELETE')
        end

        describe 'the response body' do
          it 'has a humanized name' do
            expect(jsctx[:Resource].label).to eq('Widget')
          end

          describe 'the property list' do
            it 'is a list of properties corresponding to that of the resource' do
              expect(jsctx[:Resource].properties.keys).to eq(properties)
            end
            it 'has humanized versions of the property names' do
              jsctx[:Resource].properties.each do |key, obj|
                expect(obj.label.to_s).to eq(key.humanize)
              end
            end

            it 'annotates each property with a type hint' do
              annotated_props = Hash[(properties - ['favourite_colour']).
                map { |p| [p, hinter.hint(p).to_s] }]

              annotated_props.each do |key, type|
                expect(jsctx[:Resource].properties[key].type).to eq(type)
              end
            end
          end

          describe 'for a "struct" type' do
            it 'annotates each property with a type hint' do
              values = %w<red green blue>
              struct = jsctx[:Resource].properties.favourite_colour.type

              struct.each_with_index do |(key, value), index|
                expect(key).to eq(values[index].humanize)
                expect(value).to eq(values[index])
              end
            end
          end

          describe 'the validation function' do
            context 'when called with a valid representation' do
              it 'returns an empty object'
            end

            context 'when called with an invalid representation' do
              it 'returns an object containing pertinent error messages'
            end
          end
        end
      end
    end
  end
end
