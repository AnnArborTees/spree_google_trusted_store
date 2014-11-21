require 'spec_helper'

describe 'spree/admin/google_product/edit.html.erb', story_161: true do
  let(:variant) { create :variant }
  let(:google_product) { variant.google_product = Spree::GoogleProduct.new }

  let(:test_errors) do
    [{
      domain: 'content.ContentErrorDomain',
      reason: 'validation',
      message: "[something] your product simply isn't good enough"
    },

    {
      domain: 'content.WhateverDomain',
      reason: 'bad',
      message: "[yo] dude you should really clear up these errors"
    }]
      .to_json
  end

  let(:test_warnings) do
    [{
      domain: 'content.ContentErrorDomain',
      reason: 'validation',
      message: '[description] your description sucks, please change it'
    },

    {
      domain: 'content.SomeWarningDomain',
      reason: 'whocares',
      message: '[hah] nobody really pays attention to these, amiright?'
    }]
     .to_json
  end


  def render!
    locals = {
      google_product: google_product,
      variant: variant
    }
    render template: 'spree/admin/google_product/edit', locals: locals
  end

  it 'renders all configurable fields' do
    render!

    expect(rendered).to have_css 'input[type="select"][name="google_product[google_product_category]"]'
    expect(rendered).to have_css 'input[type="text"][name="google_product[condition]"]'
    expect(rendered).to have_css 'input[type="checkbox"][name="google_product[adult]"]'
    expect(rendered).to have_css 'input[type="checkbox"][name="google_product[automatically_update]"]'
  end

  it 'displays the google product id' do
    allow(google_product).to receive(:product_id).and_return 'test:prod:id'
    render!

    expect(rendered).to have_content 'test:prod:id'
  end

  context 'when the product has errors' do
    it 'renders the messages for each error' do
      allow(google_product).to receive(:last_insertion_errors)
                           .and_return test_errors
      render!

      expect(rendered).to have_content "[something] your product simply isn't good enough" 
      expect(rendered).to have_content "[yo] dude you should really clear up these errors"
    end
  end

  context 'when the product has warnings' do
    it 'renders the messages for each error' do
      allow(google_product).to receive(:last_insertion_warnings)
                           .and_return test_warnings
      render!

      expect(rendered).to have_content '[description] your description sucks, please change it'
      expect(rendered).to have_content '[hah] nobody really pays attention to these, amiright?'
    end
  end
end

