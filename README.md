# OSP_Newton
OpenStack Newton and CEPH Storage TripleO Installation guide
-------------------------------------------------------------

```
Installing the UnderCloud
===================================

Create non-root user.

sudo useradd stack
sudo passwd stack  # specify a password

echo "stack ALL=(root) NOPASSWD:ALL" | sudo tee -a /etc/sudoers.d/stack
sudo chmod 0440 /etc/sudoers.d/stack

su - stack


SETTING THE HOSTNAME FOR THE SYSTEM.

ENABLE NEW Delorean REPOSITORIES:

sudo yum install -y https://trunk.rdoproject.org/centos7/current/python2-tripleo-repos-<version>.el7.centos.noarch.rpm
sudo -E tripleo-repos -b newton current
sudo -E tripleo-repos -b newton current ceph
sudo yum clean all
sudo rm -rf /var/cache/yum
sudo yum update -y
sudo reboot

INSTALLING THE UNDERCLOUD DIRECTOR PACKAGES

sudo yum install python-tripleoclient
cp /usr/share/instack-undercloud/undercloud.conf.sample ~/undercloud.conf
openstack undercloud install
source stackrc
sudo systemctl list-units openstack-*
sudo yum install openstack-utils
openstack-status

OBTAINING IMAGES FOR OVERCLOUD NODES

mkdir ~/images
mkdir ~/templates

run image build script to build your images & upload
openstack image list


SETTING A NAMESERVER ON THE UNDERCLOUD’S NEUTRON SUBNET

openstack subnet list
openstack subnet set --dns-nameserver [nameserver1-ip] --dns-nameserver [nameserver2-ip] [subnet-uuid]


REGISTERING NODES FOR THE OVERCLOUD

openstack overcloud node import ~/instackenv.json
openstack overcloud node import ~/instackenv-ceph.json
openstack baremetal node list

INSPECTING THE HARDWARE OF NODES

for node in $(openstack baremetal node list -c UUID -f value) ; do openstack baremetal node manage $node ; done
openstack overcloud node introspect --all-manageable --provide

Monitor Log:
sudo journalctl -l -u openstack-ironic-inspector -u openstack-ironic-inspector-dnsmasq -u openstack-ironic-conductor -f


TAGGING NODES INTO PROFILES

openstack baremetal node set –property capabilities=’profile:control, boot_option:local’  <control-node-id>
openstack baremetal node set –property capabilities=’profile:compute, boot_option:local’  <compute-node-id>
openstack baremetal node set –property capabilities=’profile:ceph, boot_option:local’  <ceph-node-id>
openstack overcloud profiles list


DEFINING THE ROOT DISK FOR NODES

openstack baremetal introspection data save < node id > |jq “.inventory.disks”
openstack baremetal node set –property root_device=”{“serial”:”<root-disk-of-the-system>” }’ <node id>


ENVIRONMENT FILES IN OVERCLOUD CREATION

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


MONITORING THE OVERCLOUD CREATION

source ~/stackrc
openstack stack list
openstack stack list --nested
source ~/overcloudrc
nova list
ssh heat-admin@node-hostname


ACCESSING THE UNDERCLOUD

source ~/stackrc
nova list


CREATING THE OVERCLOUD EXTERNAL NETWORK

source ~/overcloudrc
openstack network create public --external --provider-network-type vlan --provider-physical-network datacentre --provider-segment 104
openstack subnet create public --network public --dhcp --allocation-pool start=10.1.1.51,end=10.1.1.250 --gateway 10.1.1.1 --subnet-range 10.1.1.0/24

openstack network list
openstack subnet list


Note: In this scenario CEPH storage server come up with different type of NIC cards, where NIC card name is different. So we did NIC mapping in network-environment file.
```
