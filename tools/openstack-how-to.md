glance image-create --name ubuntu-docker \
                    --os-distro ubuntu \
                    --visibility public \
                    --disk-format=qcow2 \
                    --container-format=bare \
                    --file=ubuntu-xenial-docker-ec2-noclouds.qcow2

nova flavor-create k2.master k2m 2048 20 1
nova flavor-create k2.worker k2w 2048 20 1

openstack keypair create k8s-key \
  --public-key ~/.ssh/id_rsa.pub

openstack network create k8s-net
openstack subnet create k8s-subnet \
  --network k8s-net \
  --subnet-range 172.16.2.0/24 \
  --allocation-pool start=172.16.2.120,end=172.16.2.254
openstack router create k8s-router
openstack router set k8s-router --external-gateway public
openstack router add subnet k8s-router k8s-subnet

sudo ip route add 172.16.2.0/24 via 172.16.12.X dev br-ex

openstack security group create k8s-sg
openstack security group rule create k8s-sg \
  --protocol tcp --dst-port 1:65535
openstack security group rule create k8s-sg \
  --protocol udp --dst-port 1:65535
openstack security group rule create k8s-sg \
  --protocol icmp

openstack port create master01-port \
  --network k8s-net \
  --security-group k8s-sg \
  --allowed-address ip-address=10.244.0.0/16 \
  --allowed-address ip-address=10.254.0.0/24 \
  --fixed-ip subnet=k8s-subnet,ip-address=172.16.2.121

openstack port create worker01-port \
  --network k8s-net \
  --security-group k8s-sg \
  --allowed-address ip-address=10.244.0.0/16 \
  --allowed-address ip-address=10.254.0.0/24 \
  --fixed-ip subnet=k8s-subnet,ip-address=172.16.2.131

openstack port create worker02-port \
  --network k8s-net \
  --security-group k8s-sg \
  --allowed-address ip-address=10.244.0.0/16 \
  --allowed-address ip-address=10.254.0.0/24 \
  --fixed-ip subnet=k8s-subnet,ip-address=172.16.2.132

openstack port create worker03-port \
  --network k8s-net \
  --security-group k8s-sg \
  --allowed-address ip-address=10.244.0.0/16 \
  --allowed-address ip-address=10.254.0.0/24 \
  --fixed-ip subnet=k8s-subnet,ip-address=172.16.2.133

openstack server create master01 \
  --image ubuntu-docker \
  --flavor k2.master \
  --key-name k8s-key \
  --nic port-id=$(openstack port show master01-port -f value -c id)

openstack server create worker01 \
  --image ubuntu-docker \
  --flavor k2.worker \
  --key-name k8s-key \
  --nic port-id=$(openstack port show worker01-port -f value -c id)

openstack server create worker02 \
  --image ubuntu-docker \
  --flavor k2.worker \
  --key-name k8s-key \
  --nic port-id=$(openstack port show worker02-port -f value -c id)

openstack server create worker03 \
  --image ubuntu-docker \
  --flavor k2.worker \
  --key-name k8s-key \
  --nic port-id=$(openstack port show worker03-port -f value -c id)
