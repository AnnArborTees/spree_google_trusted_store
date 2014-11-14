require 'spec_helper'

describe Spree::Variant, shopping_spec: true, story_161: true do
  it { is_expected.to have_one(:google_product).through(:product) }
end