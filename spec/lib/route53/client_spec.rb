require 'rails_helper'

RSpec.describe Client do
  subject(:client) { described_class.new(hosted_zone_id, domain_name, route53_client) }

  let(:hosted_zone_id) { Faker::Internet.password }
  let(:domain_name) { Faker::Internet.domain_name }
  let(:route53_client) { instance_double('AWS Route53 Client') }

  describe '#update_hosted_zone_records' do
    before do
      allow(route53_client).to receive(:change_resource_record_sets)
    end

    it 'calls route53 to update subdomain details' do
      expect(route53_client).to receive(:change_resource_record_sets).with(
        hash_including(hosted_zone_id: hosted_zone_id)
      )

      client.update_hosted_zone_records("hk.#{domain_name}", random_ipv4s)
    end
  end

  describe '#get_hosted_zones_records' do
    let(:ip_addresses) { random_ipv4s }

    before do
      allow(route53_client).to receive(:list_resource_record_sets).and_return(
        {
          resource_record_sets: [{
            name: "hk.#{domain_name}",
            type: 'A',
            resource_records: ip_addresses.map { |ip| { value: ip } }
          }],
          is_truncated: false,
          next_record_name: nil,
          next_record_type: nil
        }
      )
    end

    it 'fetches hosted zone records from route53' do
      expect(route53_client).to receive(:list_resource_record_sets).with(
        hash_including(hosted_zone_id: hosted_zone_id, start_record_name: domain_name)
      )
      client.get_hosted_zones_records
    end

    it 'maps route53 response to hash table(key => subdomain, value => ip set)' do
      hosted_zone_records = client.get_hosted_zones_records
      expect(hosted_zone_records["hk.#{domain_name}"]).to match_array(ip_addresses)
    end
  end
end
