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
      let(:representation) { { password: nil } }

      specify { expect(errors[:password].to_a).to include('must not be blank') }
    end
  end
end
