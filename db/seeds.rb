puts 'Seeding Clusters and Servers'

la_cluster = Cluster.create(name: 'Los Angeles', subdomain: 'la')
la_cluster.servers.create(friendly_name: 'ubiq-1', ip_string: '1.1.1.1')
la_cluster.servers.create(friendly_name: 'ubiq-2', ip_string: '2.2.2.2')

Cluster.create(name: 'New York', subdomain: 'nyc')
fra_cluster = Cluster.create(name: 'Frankfurt', subdomain: 'fra')
fra_cluster.servers.create(friendly_name: 'leaseweb-de-1', ip_string: '3.3.3.3')

hk_cluster = Cluster.create(name: 'Hong Kong', subdomain: 'hk')
hk_cluster.servers.create(friendly_name: 'rackspace-1', ip_string: '4.4.4.4')
hk_cluster.servers.create(friendly_name: 'rackspace-2', ip_string: '5.5.5.5')

tr_cluster = Cluster.create(name: 'Turkey', subdomain: 'tr')
tr_cluster.servers.create(friendly_name: 'tr-1', ip_string: '8.7.5.4')
