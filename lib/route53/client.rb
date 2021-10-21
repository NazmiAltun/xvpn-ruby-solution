require 'aws-sdk-route53'

class Client
  DEFAULT_MAX_ITEM = 100
  DEFAULT_TTL = 60
  DEFAULT_RECORD_TYPE = 'A'.freeze

  def initialize(hosted_zone_id, domain_name, client = nil)
    @hosted_zone_id = hosted_zone_id
    @domain_name = domain_name
    @client = client || Aws::Route53::Client.new
  end

  def get_hosted_zones_records
    record_type = DEFAULT_RECORD_TYPE
    record_name = @domain_name
    hosted_zone_records = {}
    has_records = true

    while has_records
      response = get_records_from_route53(record_name, record_type)
      hosted_zone_records = hosted_zone_records.merge(map_route53_response_to_hash(response))

      has_records = response[:is_truncated]
      record_type = response[:next_record_type]
      record_name = response[:next_record_name]
    end
    hosted_zone_records
  end

  def update_hosted_zone_records(subdomain, ip_addresses, delete = false)
    options = {
      change_batch: {
        changes: [
          {
            action: delete ? 'DELETE' : 'UPSERT',
            resource_record_set: {
              name: subdomain,
              resource_records: ip_addresses.map { |v| { value: v } },
              ttl: DEFAULT_TTL,
              type: DEFAULT_RECORD_TYPE
            }
          }
        ]
      },
      hosted_zone_id: @hosted_zone_id
    }
    @client.change_resource_record_sets(options)
  end

  private
  # Filters A records and maps route53 response to hash table( key => subdomain, value => ip address set)
  # Deletes dot(.) at the end of subdomain 
  def map_route53_response_to_hash(response)
    response[:resource_record_sets]
      .select { |record| record[:type] == DEFAULT_RECORD_TYPE }
      .to_h { |record| [record[:name].delete_suffix('.'), record[:resource_records].map { |r| r[:value] }.to_set] }
  end

  def get_records_from_route53(record_name, record_type)
    @client.list_resource_record_sets({
                                        hosted_zone_id: @hosted_zone_id,
                                        start_record_name: record_name,
                                        start_record_type: record_type,
                                        max_items: DEFAULT_MAX_ITEM
                                      })
  end
end
