module Helpers
  module Generator
    def random_ipv4s
      [
        Faker::Internet.ip_v4_address,
        Faker::Internet.ip_v4_address,
        Faker::Internet.ip_v4_address
      ].to_set
    end

    def random_hosted_zone_records
      {
        Faker::Internet.domain_name(subdomain: true) => random_ipv4s,
        Faker::Internet.domain_name(subdomain: true) => random_ipv4s,
        Faker::Internet.domain_name(subdomain: true) => random_ipv4s
      }
    end

    def random_hosted_zone_records_with_existing_subdomain_and_ip(subdomain, ip)
      {
        subdomain => random_ipv4s + [ip],
        Faker::Internet.domain_name(subdomain: true) => random_ipv4s,
        Faker::Internet.domain_name(subdomain: true) => random_ipv4s
      }
    end

    def random_hosted_zone_records_with_existing_subdomain(subdomain)
      {
        subdomain => random_ipv4s,
        Faker::Internet.domain_name(subdomain: true) => random_ipv4s,
        Faker::Internet.domain_name(subdomain: true) => random_ipv4s
      }
    end

    def random_hosted_zone_records_with_existing_ips(existing_ips)
      {
        Faker::Internet.domain_name(subdomain: true) => random_ipv4s + existing_ips
      }
    end
  end
end
