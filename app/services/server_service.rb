class ServerService
  def initialize(external_dns_client)
    @external_dns_client = external_dns_client || Client.new
  end

  def get_all
    servers_in_db = get_servers_from_db.sort_by(&:friendly_name)
    hosted_zone_ip_subdomain_table = get_hosted_zone_ip_subdomain_table

    servers_in_db.map do |server|
      {
        id: server.id,
        name: server.friendly_name,
        cluster_name: server.cluster_name,
        ip: server.ip_string,
        cluster_subdomain: server.cluster_subdomain,
        subdomain: hosted_zone_ip_subdomain_table[server.ip_string]
      }
    end
  end

  def add_server_to_rotation(subdomain, server_ip)
    hosted_zone_records = @external_dns_client.get_hosted_zones_records
    hosted_zone_ip_subdomain_table = convert_to_ip_hosted_zone_hash_table(hosted_zone_records)
    return if hosted_zone_ip_subdomain_table.key?(server_ip)

    hosted_zone_records[subdomain] ||= Set.new
    hosted_zone_records[subdomain].add(server_ip)
    @external_dns_client.update_hosted_zone_records(subdomain, hosted_zone_records[subdomain])
  end
  
  def remove_from_rotation(server_id)
    server = get_server_by_id(server_id)
    return if server.nil?
    
    hosted_zone_records = @external_dns_client.get_hosted_zones_records
    hosted_zone_ip_subdomain_table = convert_to_ip_hosted_zone_hash_table(hosted_zone_records)
    subdomain = hosted_zone_ip_subdomain_table[server&.ip_string]
    return if subdomain.nil?

    if hosted_zone_records[subdomain].length == 1 # A dirty workaround for badly designed AWS API
      @external_dns_client.update_hosted_zone_records(subdomain, hosted_zone_records[subdomain], true)
    else
      hosted_zone_records[subdomain].delete(server.ip_string)
      @external_dns_client.update_hosted_zone_records(subdomain, hosted_zone_records[subdomain])
    end
  end

  private

  def get_hosted_zone_ip_subdomain_table
    hosted_zone_records = @external_dns_client.get_hosted_zones_records
    convert_to_ip_hosted_zone_hash_table(hosted_zone_records)
  end

  def convert_to_ip_hosted_zone_hash_table(hosted_zone_records)
    ip_domain_hash_table = {}

    hosted_zone_records.each do |subdomain, ip_addresses|
      ip_domain_hash_table = ip_domain_hash_table.merge(ip_addresses.to_h { |ip| [ip, subdomain] })
    end

    ip_domain_hash_table
  end

  def get_server_by_id(server_id)
    Server
      .eager_load(:cluster)
      .select('*')
      .find_by_id(server_id)
  end

  def get_servers_from_db
    Server
      .eager_load(:cluster)
      .select('*')
  end
end
