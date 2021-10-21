require 'rails_helper'

RSpec.describe Cluster do
  describe 'associations' do
    it { is_expected.to have_many(:servers) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:name) }
    it { is_expected.to validate_presence_of(:subdomain) }
    it { is_expected.to validate_uniqueness_of(:subdomain) }
  end
end
