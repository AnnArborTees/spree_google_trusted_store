require 'spec_helper'

describe Spree::GoogleProduct::Config, shopping_spec: true, story_161: true do
  subject { Spree::GoogleProduct::Config.new }

  describe '#register_attribute' do
    describe '#assign' do
      it 'can remember and assign a block' do
        block = proc { 'new_value' }
        variant = double('variant', title: 'test_title')
        expect(block).to receive(:call)
          .with(variant, 'test_title')
        expect(variant).to receive(:title=).with('new_value')

        subject.register_attribute(:title, &block)
        subject.assign(variant, :title)
      end

      it 'can remember and assign a constant value' do
        variant = double('variant', title: 'test_title')
        expect(variant).to receive(:title=).with('const title')

        subject.register_attribute(:title, 'const title')
        subject.assign(variant, :title)
      end
    end

    it 'remembers all registered attributes in #registered_attributes' do
      subject.register_attribute(:title, 'const')
      expect(subject.registered_attributes[:title]).to eq 'const'
    end
  end

  describe '#define' do
    it 'delegates to register_attribute' do
      expect(subject).to receive(:register_attribute).with(:title, anything)
      subject.define.title { 'proc' }
    end
  end
end