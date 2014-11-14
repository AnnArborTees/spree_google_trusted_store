require 'spec_helper'

describe Spree::GoogleProduct::Attributes, shopping_spec: true, story_161: true do
  subject { Spree::GoogleProduct::Attributes.instance }

  describe '#register_attribute' do
    describe '#value_of' do
      it 'can remember and assign a block' do
        block = proc { 'new_value' }
        variant = double('variant', title: 'test_title')
        expect(block).to receive(:call).with(variant).and_call_original

        subject.register_attribute(:title, &block)
        expect(subject.value_of(variant, :title))
          .to eq 'new_value'
      end

      it 'can remember and value_of a constant value' do
        variant = double('variant', title: 'test_title')

        subject.register_attribute(:title, 'const title')
        expect(subject.value_of(variant, :title))
          .to eq 'const title'
      end

      it 'issues a warning when a required field failed to be assigned'
    end

    it 'remembers all registered attributes in #registered_attributes' do
      subject.register_attribute(:title, 'const')
      expect(subject.registered_attributes[:title]).to eq 'const'
    end
  end

  describe '#required?' do
    it 'returns true if the given field is required for the given product type',
      pending: 'maybe not...'
  end

  describe '#register_db_field' do
    it 'stores the value in #db_fields' do
      subject.register_db_field(:title, :title)
      expect(subject.db_fields[:title]).to eq :title
    end
  end

  describe '#check_db_fields' do
    context 'when #db_fields contains fields that are not in the model' do
      it 'issues a warning' do
        allow(subject).to receive(:db_fields).and_return [:one, :two]
        expect(Rails.logger).to receive(:warn).with(
          "Spree::GoogleProduct does not have db columns for: one, two. "\
          "Please create migrations to add them to spree_google_products"
        )

        subject.check_db_fields
      end

      it 'does not issue a warning if #ignore_db_mismatch is true' do
        allow(subject).to receive(:db_fields).and_return [:one, :two]
        subject.ignore_db_mismatch = true
        expect(Rails.logger).to_not receive(:warn)

        subject.check_db_fields
      end
    end

    context 'when #db_fields does not contain fields that are defined in the model' do
      it 'issues a warning' do
        allow(subject).to receive(:db_fields).and_return [:one]
        allow(Spree::GoogleProduct).to receive(:column_names).and_return [:one, :two]
        expect(Rails.logger).to receive(:warn).with(
          "Spree::GoogleProduct has db columns for unmapped options: two. Run "\
          "'rails generate spree_google_trusted_store:migrations' to generate "\
          "migrations to have them removed."
        )

        subject.check_db_fields
      end
    end
  end

  describe '#define' do
    it 'delegates to register_attribute' do
      expect(subject).to receive(:register_attribute).with(:title)
      subject.define.title { 'proc' }
    end

    describe '#as_db_column' do
      context 'with no argument' do
        it 'calls register_db_field on the field called' do
          expect(subject).to receive(:register_db_field).with(:title, nil)
          subject.define.title.as_db_column
        end
      end

      context 'with a name argument' do
        it 'calls register_db_field on the field called with the given argument' do
          expect(subject).to receive(:register_db_field).with(:title, :title_field)
          subject.define.title.as_db_column(:title_field)
        end
      end
    end
  end
end