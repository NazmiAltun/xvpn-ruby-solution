require 'rails_helper'

RSpec.describe DnsService do
  describe '#get_all' do
    subject(:dns_service) { described_class.new(external_dns_client) }

    let(:external_dns_client) { instance_double('Route53 Client') }

    context 'when external dns service does not return any records' do
      before do
        allow(external_dns_client).to receive(:get_hosted_zones_records).and_return([])
      end

      it 'returns empty result' do
        expect(dns_service.get_all).to be_empty
      end
    end

    context 'when external dns service returns records' do
      let(:hosted_zone_records) { random_hosted_zone_records }
      let(:dns_entries) { dns_service.get_all }

      before do
        allow(external_dns_client).to receive(:get_hosted_zones_records).and_return(hosted_zone_records)
      end

      it 'returns dns entries' do
        expected_entry_count = hosted_zone_records.values.sum(&:length)
        expect(dns_entries.count).to eq(expected_entry_count)
      end

      context 'when ip addresses have no matching server records' do
        it 'dns entries has no mapped server/cluster info' do
          expect(dns_entries.reject { |x| x[:server_name].nil? }).to be_empty
        end
      end

      context 'when ip addresses have matching server records' do
        let!(:server) { create(:server, ip_string: hosted_zone_records.values.first.first) }

        it 'dns entries have mapped server/cluster info' do
          expect(dns_entries.reject { |x| x[:server_name].nil? }).not_to be_empty
        end
      end
    end
  end
end
