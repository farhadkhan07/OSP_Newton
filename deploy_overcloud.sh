#!/bin/bash
openstack overcloud deploy --templates \
-e /usr/share/openstack-tripleo-heat-templates/environments/network-isolation.yaml \
-e /home/stack/templates/01-ips-from-pool-all.yaml \
-e /home/stack/templates/02-network-environment.yaml \
-e /home/stack/templates/03-scheduler_hints_env.yaml \
-e /home/stack/templates/04-parameters.yaml \
-e /home/stack/templates/05-cinder-netapp-config.yaml \
-e /home/stack/templates/06-storage-environment.yaml \
-e /home/stack/templates/07-enable-tls.yaml \
-e /home/stack/templates/08-cloudname.yaml \
-e /home/stack/templates/09-inject-trust-anchor.yaml \
-e /usr/share/openstack-tripleo-heat-templates/environments/tls-endpoints-public-dns.yaml \
--control-scale 3 --compute-scale 3 --ceph-storage-scale 3 --block-storage-scale 0 --swift-storage-scale 0 \
--control-flavor baremetal --compute-flavor baremetal --ceph-storage-flavor baremetal \
--ntp-server 0.asia.pool.ntp.org \
--neutron-network-type vxlan --neutron-tunnel-types vxlan \
--neutron-bridge-mappings datacentre:br-ex \
--neutron-network-vlan-ranges datacentre:1:4094 \
--log-file overcloud_deployment.log

