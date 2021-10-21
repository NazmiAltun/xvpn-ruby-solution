class DnsEntriesController < ApplicationController
  def initialize
    super
    zone_id = Rails.application.config.zone_id
    domain_name = Rails.application.config.domain_name
    @dns_service = DnsService.new(Client.new(zone_id, domain_name))
  end

  def list
    @dns_entries = @dns_service.get_all
  end
end
