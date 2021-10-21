require 'resolv'

class Server < ApplicationRecord
  belongs_to :cluster
  delegate :name, to: :cluster, prefix: :cluster
  delegate :subdomain, to: :cluster, prefix: :cluster

  validates :friendly_name, presence: true, uniqueness: true
  validates :ip_string, presence: true, uniqueness: true, format: { with: Resolv::IPv4::Regex }
end
