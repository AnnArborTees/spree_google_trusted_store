require 'spec_helper'

describe 'spree/google_trusted_store/_order_confirmation.html.erb', order_spec: true, story_159: true do
  def render!(locals = {})
    render partial: 'spree/google_trusted_store/badge', locals: locals
  end

  it 'displays START and END Google Trusted Stores Order' do
    render!
    expect(rendered).to start_with '<!-- START Google Trusted Stores Order -->'
    expect(rendered).to start_with "<!-- END Google Trusted Stores Order -->\n"
  end

  %w(id domain email country currency total discounts shipping-total 
    tax-total est-ship-date est-delivery-date has-preorder has-digital
  ).each do |field|
    instance_eval <<-RUBY, __FILE__, __LINE__ + 1
      context 'when passed #{field.underscore}' do
        it 'renders a span with the gts-o-#{field} that contains the #{field}' do
          render! #{field.underscore}: 'test-val'
          expect(rendered).to have_css 'span##{field}', text: 'test-val'
        end
      end
    RUBY
  end

  context 'line items' do
    it 'renders a .gts-item span for each entry' do
      render! items: [{}, {}]
      expect(rendered).to have_css 'span.gts-item', count: 2
    end

    %w(item_name item_price item_quantity).each do |field|
      instance_eval <<-RUBY, __FILE__, __LINE__ + 1
        context 'given #{field.underscore}' do
          it 'renders #{field} for the item' do
            render! items: [{#{field.underscore}: 'test-val'}]
            expect(rendered).to have_css 'span.gts-item > span.gts-i-#{field}', text: 'test-val'
          end
        end
      RUBY
    end
  end
end
