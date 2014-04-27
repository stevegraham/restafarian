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
      specify { expect(errors[:password].to_a).to_not include("can't be blank") }
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

      specify { expect(errors[:password].to_a).
        to_not include('is too short (minimum is 8 characters)', 'is too long (maximum is 32 characters)') }
    end
  end

  describe 'acceptance' do
    context 'with valid input' do
      before  { representation['terms'] = true }
      specify { expect(errors[:terms].to_a).to_not include('must be accepted') }
    end

    context 'with invalid input' do
      specify { expect(errors[:terms].to_a).to include('must be accepted') }
    end
  end

  describe 'inclusion' do
    context 'with valid input' do
      before  { representation['favourite_colour'] = 'red' }
      specify { expect(errors[:favourite_colour].to_a).
        to_not include('is not included in the list') }
    end

    context 'with invalid input' do
      specify { expect(errors[:favourite_colour].to_a).
        to include('is not included in the list') }
    end
  end

  describe 'numericality' do
    context 'with valid input' do
      before  { representation['decimal'] = '1' }
      specify { expect(errors[:decimal].to_a).
        to_not include('is not a number') }
    end

    context 'with invalid input' do
      before  { representation['decimal'] = 'a' }
      specify { expect(errors[:decimal].to_a).
        to include('is not a number') }
    end

    context 'integer only' do
      context 'with valid input' do
        before  { representation['integer'] = '1' }
        specify { expect(errors[:integer].to_a).
          to_not include('is not a number', 'must be an integer') }
      end

      context 'with invalid input' do
        before  { representation['integer'] = '3.0' }
        specify { expect(errors[:integer].to_a).
          to include('must be an integer') }
      end
    end
  end

  describe 'exclusion' do
    context 'with valid input' do
      before  { representation['username'] = 'stevie' }
      specify { expect(errors[:username].to_a).
        to_not include('is reserved') }
    end

    context 'with invalid input' do
      before  { representation['username'] = 'admin' }
      specify { expect(errors[:username].to_a).
        to include('is reserved') }
    end
  end

  describe 'format' do
    context 'with valid input' do
      before  { representation['email'] = 'stevie@example.com' }
      specify { expect(errors[:email].to_a).
        to_not include('is invalid') }
    end


    context 'with invalid input' do
      before  { representation['email'] = 'stevie' }
      specify { expect(errors[:email].to_a).
        to include('is invalid') }
    end
  end
end
