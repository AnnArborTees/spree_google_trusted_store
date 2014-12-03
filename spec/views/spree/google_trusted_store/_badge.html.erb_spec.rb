require 'spec_helper'

describe 'spree/google_trusted_store/_badge.html.erb', badge_spec: true, story_159: true do
  def render!(locals = {})
    render partial: 'spree/google_trusted_store/badge', locals: locals
  end

  it 'initializes a "gts"' do
    render!
    expect(rendered).to include 'var gts = gts || [];'
  end

  it 'only inserts the query js in production' do
    rendered = render!
    expect(rendered).to include '// s.parentNode.insertBefore(gts, s);'
    expect(Rails.env).to receive(:production?).and_return true
    rendered = render!
    expect(rendered).to_not include '// s.parentNode.insertBefore(gts, s);'
    expect(rendered).to include 's.parentNode.insertBefore(gts, s);'
  end

  context 'given an id' do
    it 'pushes the id to the gts' do
      render! id: '242985'
      expect(rendered).to include 'gts.push(["id", "242985"]);'
    end
  end

  context 'given a locale' do
    it 'pushes the locale to the gts' do
      render! locale: 'en_US'
      expect(rendered).to include 'gts.push(["locale", "en_US"]);'
    end
  end

  context 'google shopping', pending: 'TODO implement google shopping'
end
