require 'rails_helper'

RSpec.describe ServerService do
  subject(:server_service) { described_class.new(external_dns_client) }

  let(:external_dns_client) { instance_double('Route53 Client') }

  describe '#get_all' do
    context 'when there are no server records' do
      before do
        allow(external_dns_client).to receive(:get_hosted_zones_records).and_return([])
      end

      it 'returns empty result' do
        expect(server_service.get_all).to be_empty
      end
    end

    context 'when there are server records' do
      let!(:servers_in_db) { create_list(:server, 3) }
      let(:servers) { server_service.get_all }

      before do
        allow(external_dns_client).to receive(:get_hosted_zones_records).and_return([])
      end

      it 'returns servers' do
        expect(servers).not_to be_empty
      end

      context 'when server ip address does not match any A record from external dns service' do
        it 'returns server without mapped subdomain' do
          expect(servers.reject { |x| x[:subdomain].nil? }).to be_empty
        end
      end

      context 'when server ip address matches ip address linked to A record from external dns service' do
        before do
          allow(external_dns_client).to receive(:get_hosted_zones_records).and_return(
            random_hosted_zone_records_with_existing_ips(servers_in_db.map(&:ip_string))
          )
        end

        let(:servers) { server_service.get_all }

        it 'returns servers with mapped subdomain' do
          expect(servers.reject { |x| x[:subdomain].nil? }).not_to be_empty
        end

        it 'sorts servers by their name in ascending order' do
          servers.each_with_index do |_s, i|
            next if i == 0

            expect(servers[i - 1][:name]).to be <= servers[i][:name]
          end
        end
      end
    end
  end

  describe '#remove_from_rotation' do
    context 'when server is not in the rotation' do
      let(:hosted_zone_records) { random_hosted_zone_records }

      before do
        allow(external_dns_client).to receive(:get_hosted_zones_records).and_return(hosted_zone_records)
      end

      context 'when server does not exist' do
        it 'does not fetch hosted zone records from external dns service' do
          expect(external_dns_client).not_to receive(:get_hosted_zones_records)
          server_service.remove_from_rotation(rand(1000))
        end
      end

      context 'when server exists' do
        let!(:server_not_in_rtation) { create(:server) }

        it 'fetches hosted zone records from external dns service' do
          expect(external_dns_client).to receive(:get_hosted_zones_records)
          server_service.remove_from_rotation(server_not_in_rtation.id)
        end
        it 'does not call external dns service to update hosted zone record' do
          expect(external_dns_client).not_to receive(:update_hosted_zone_records)
          server_service.remove_from_rotation(server_not_in_rtation.id)
        end
      end
    end

    context 'when server is in rotation' do
      let(:subdomain) { Faker::Internet.domain_name(subdomain: true) }
      let!(:server_in_rotation) { create(:server) }
      let(:hosted_zone_records) do
        random_hosted_zone_records_with_existing_subdomain_and_ip(subdomain, server_in_rotation.ip_string)
      end

      before do
        allow(external_dns_client).to receive(:get_hosted_zones_records).and_return(hosted_zone_records)
        allow(external_dns_client).to receive(:update_hosted_zone_records)
      end

      it 'removes server from rotation' do
        expect(external_dns_client).to receive(:update_hosted_zone_records)
          .with(subdomain, hosted_zone_records[subdomain] - [server_in_rotation.ip_string])
        server_service.remove_from_rotation(server_in_rotation.id)
      end
    end
  end

  describe '#add_to_rotation' do
    context 'when server is not in the rotation' do
      let(:subdomain) { Faker::Internet.domain_name(subdomain: true) }
      let(:server_ip_not_in_rotation) { Faker::Internet.ip_v4_address }
      let(:hosted_zone_records) { random_hosted_zone_records_with_existing_subdomain(subdomain) }

      before do
        allow(external_dns_client).to receive(:get_hosted_zones_records).and_return(hosted_zone_records)
        allow(external_dns_client).to receive(:update_hosted_zone_records)
      end

      it 'adds server to rotation' do
        expect(external_dns_client).to receive(:update_hosted_zone_records)
          .with(subdomain, hosted_zone_records[subdomain] + [server_ip_not_in_rotation])
        server_service.add_server_to_rotation(subdomain, server_ip_not_in_rotation)
      end
    end

    context 'when server is already in the rotation' do
      let(:existing_subdomain) { Faker::Internet.domain_name(subdomain: true) }
      let(:existing_ip) { Faker::Internet.ip_v4_address }
      let(:hosted_zone_records) { { existing_subdomain => [existing_ip] } }

      before do
        allow(external_dns_client).to receive(:get_hosted_zones_records).and_return(hosted_zone_records)
        allow(external_dns_client).to receive(:update_hosted_zone_records)
      end

      it 'fetches hosted zone records' do
        expect(external_dns_client).to receive(:get_hosted_zones_records)
        server_service.add_server_to_rotation(existing_subdomain, existing_ip)
      end

      it 'does not update hosted zone records on external dns client' do
        expect(external_dns_client).not_to receive(:update_hosted_zone_records)
        server_service.add_server_to_rotation(existing_subdomain, existing_ip)
      end
    end
  end
end
