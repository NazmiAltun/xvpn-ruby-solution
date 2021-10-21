class DnsService
  def initialize(external_dns_client)
    @external_dns_client = external_dns_client || Client.new
  end

  def get_all
    dns_entries = []
    hosted_zone_records = @external_dns_client.get_hosted_zones_records
    servers = get_servers_from_db

    hosted_zone_records.each do |domain, ip_addresses|
      dns_entries += map_ip_addresses(domain, ip_addresses, servers)
    end

    dns_entries
  end

  private

  def map_ip_addresses(domain, ip_addresses, servers)
    ip_addresses.map do |ip|
      {
        domain: domain,
        ip: ip,
        server_name: servers[ip]&.friendly_name,
        cluster_name: servers[ip]&.cluster&.name
      }
    end
  end

  def get_servers_from_db
    Server
      .eager_load(:cluster)
      .select('*')
      .all.to_h { |server| [server.ip_string, server] }
  end
end
