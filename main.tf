terraform {
  required_providers {
    g42cloud = {
      source = "g42cloud-terraform/g42cloud"
      version = "1.3.0"
    }
  }
}

data "g42cloud_compute_flavors" "myvm" {
  availability_zone = "ae-ad-1a"
  performance_type  = "normal"
  cpu_core_count    = 4
  memory_size       = 8
}


data "g42cloud_images_image" "ubuntu" {
  name        = "Ubuntu 20.04 server 64bit"
  most_recent = true
}


resource "g42cloud_vpc" "vpc_v1" {
  name = "vpc01"
  cidr = "10.0.0.0/16"
}

#  default primary dns is 100.125.3.250, secondary dns is 100.125.2.14"
resource "g42cloud_vpc_subnet" "subnet_v1" {
  name       = "subnet01"
  cidr       = "10.0.1.0/24"
  gateway_ip = "10.0.1.1"
  vpc_id     = g42cloud_vpc.vpc_v1.id
  primary_dns = "100.125.3.250"
  secondary_dns = "100.125.2.14"
}

resource "g42cloud_vpc_eip" "eip" {
  publicip {
    type = "5_bgp"
  }
  bandwidth {
    share_type = "PER"
    name = "eip-ecs"
    size        = 20
    charge_mode = "traffic"
  }
}

resource "g42cloud_networking_secgroup" "sg-ssh" {
  name        = "sg-sample-ssh"
  description = "ssh ingress "
}

resource "g42cloud_networking_secgroup_rule" "sg-ssh-rule1" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = g42cloud_networking_secgroup.sg-ssh.id
}

# generate a local key pair and copy a public key from your keypair in public_key field
resource "g42cloud_compute_keypair" "keypair-one" {
  name       = "keypair"
  public_key = ""
}

resource "g42cloud_compute_instance" "ecs01" {
  name              = "ecs01"
  image_id          = data.g42cloud_images_image.ubuntu.id
  flavor_id         = data.g42cloud_compute_flavors.myvm.ids[0]
  security_groups   = ["sg-sample-ssh"]
  availability_zone = "ae-ad-1a"
  key_pair          = "keypair"
  system_disk_type = "SAS"
  system_disk_size = 40
  network {
    uuid = g42cloud_vpc_subnet.subnet_v1.id
  }
}

resource "g42cloud_compute_eip_associate" "eip_assocaited" {
  public_ip   = g42cloud_vpc_eip.eip.address
  instance_id = g42cloud_compute_instance.ecs01.id
}
