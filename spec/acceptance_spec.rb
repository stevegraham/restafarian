require 'spec_helper'

describe Restafarian do
  describe 'HATEOAS' do
    describe 'entering the API at the root' do
      before do
        header 'Content-Type', 'application/vnd.restafarian.resource+json; version=1'
      end

      context 'when the client makes a request with a Restarian media type' do
        before { get '/' }

        it 'returns a 200 status code' do
          expect(last_response.status).to eq(200)
        end

        it 'returns JSON' do
          expect { JSON.parse(last_response.body) }.to_not raise_error
        end

        it 'returns links to available resources corresponding to child resoures in the application routeset' do
          body = JSON.parse(last_response.body)

          children = {
            "users" => "http://example.org/user",
            "bank_accounts"=>"http://example.org/bank_accounts",
            "charges"=>"http://example.org/charges"
          }

          expect(body['child_resources']).to eq(children)
        end
      end
    end

    describe 'requesting a resource description' do
      context 'when the client makes a request with a Restarian media type' do
        it 'returns a 200 status code'
        it 'returns JavaScript'
        it 'lists permitted HTTP methods'

        describe 'the response body' do
          it 'has a localized name'

          describe 'the propery list' do
            it 'is a list of properties corresponding to that of the resource'
            it 'has a localized version of the name'
            it 'has a type hint'
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
