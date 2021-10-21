class Cluster < ApplicationRecord
  has_many :servers

  validates :name, presence: true, uniqueness: true
  validates :subdomain, presence: true, uniqueness: true
end
