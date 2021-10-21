require 'rails_helper'

RSpec.describe Server do
  subject(:server) { described_class.new }

  describe 'associations' do
    it { is_expected.to belong_to(:cluster) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:friendly_name) }
    it { is_expected.to validate_uniqueness_of(:friendly_name) }
    it { is_expected.to validate_presence_of(:ip_string) }
    it { is_expected.to validate_uniqueness_of(:ip_string) }

    it 'ipv6 should not be allows' do
      expect(server).not_to allow_value('2404:6800:4005:807::200e').for(:ip_string)
    end

    it 'ipv4 should be allowed' do
      expect(server).to allow_value('88.121.46.11').for(:ip_string)
    end
  end
end
