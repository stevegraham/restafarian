require 'spec_helper'

describe 'JavaScript Validators:' do
  let(:renderer) { Restafarian::JavascriptRenderer.new Widget.new }
  let(:context)  { V8::Context.new.tap { |c| c.eval(renderer.render) } }
  let(:resource) { context[:Resource] }
  let(:errors)   { resource[:validate].methodcall(resource,representation) }

  describe 'presence' do
    context 'with valid input' do
      let(:representation) { { password: 'crappy_password_bro' } }

      specify { expect(errors[:password].to_a).to be_empty }
    end

    context 'with invalid input' do
      let(:representation) { { password: '' } }

      specify { expect(errors[:password].to_a).to include("can't be blank") }
    end
  end

  describe 'absence' do
    context 'with valid input' do
      let(:representation) { { doo_dad: '' } }

      specify { expect(errors[:doo_dad].to_a).to be_empty }
    end

    context 'with invalid input' do
      let(:representation) { { doo_dad: 'hello' } }

      specify { expect(errors[:doo_dad].to_a).to include('must be blank') }
    end
  end
end
