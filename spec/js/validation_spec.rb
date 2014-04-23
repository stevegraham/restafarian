require 'spec_helper'

describe 'JavaScript Validators:' do
  let(:renderer)       { Restafarian::JavascriptRenderer.new Widget.new }
  let(:context)        { V8::Context.new.tap { |c| c.eval(renderer.render) } }
  let(:resource)       { context[:Resource] }
  let(:errors)         { resource[:validate].methodcall(resource,representation) }
  let(:representation) { Hash[Widget.new.as_json.map { |k,v| [k, ''] }] }

  describe 'presence' do
    context 'with valid input' do
      before  { representation['password'] = 'crappy_password_bro' }
      specify { expect(errors[:password].to_a).to be_empty }
    end

    context 'with invalid input' do
      specify { expect(errors[:password].to_a).to include("can't be blank") }
    end
  end

  describe 'absence' do
    context 'with valid input' do
      specify { expect(errors[:doo_dad].to_a).to be_empty }
    end

    context 'with invalid input' do
      before  { representation['doo_dad'] = 'hello' }
      specify { expect(errors[:doo_dad].to_a).to include('must be blank') }
    end
  end

  describe 'length' do
    context 'too long' do
      before  { representation['password'] =  'qwertyuiopasdfghjklzxcvbnm1234567' }

      specify { expect(errors[:password].to_a).
        to include('is too long (maximum is 32 characters)') }
    end

    context 'too short' do
      before  { representation['password'] =  'hello' }

      specify { expect(errors[:password].to_a).
        to include('is too short (minimum is 8 characters)') }
    end

    context 'with valid input' do
      before  { representation['password'] = 'hello_world' }

      specify { expect(errors[:password].to_a).to be_empty }
    end
  end
end
