class ServersController < ApplicationController
  def initialize
    super
    zone_id = Rails.application.config.zone_id
    domain_name = Rails.application.config.domain_name
    @server_service = ServerService.new(Client.new(zone_id, domain_name))
  end

  def list
    @servers = @server_service.get_all
  end

  def remove_from_rotation
    @server_service.remove_from_rotation(params[:id])
    redirect_to action: :list
  end

  def add_to_rotation
    domain = "#{params[:cluster_subdomain]}.#{Rails.application.config.domain_name}"
    @server_service.add_server_to_rotation(domain, params[:ip])
    redirect_to action: :list
  end
end
