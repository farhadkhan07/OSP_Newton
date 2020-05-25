export OS_YAML="/usr/share/openstack-tripleo-common/image-yaml/overcloud-images-centos7.yaml"
export STABLE_RELEASE="newton"
export DIB_YUM_REPO_CONF="/etc/yum.repos.d/delorean*"
export DIB_YUM_REPO_CONF="$DIB_YUM_REPO_CONF /etc/yum.repos.d/tripleo-centos-ceph-jewel.repo"
openstack overcloud image build --all
openstack overcloud image upload