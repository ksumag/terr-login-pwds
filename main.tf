terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
     aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
     random = {
      source = "hashicorp/random"
      version = "3.1.0"
    }
    local = {
      source = "hashicorp/local"
      version = "2.1.0"
    }
  }
}
provider "local" {
  # Configuration options
}

provider "digitalocean" {
   token = var.DO_token
}
provider "aws" {
  region     = var.region
  access_key = var.my-access-key
  secret_key = var.my-secret-key
}


resource "digitalocean_ssh_key" "my_key" {
  name       = "DOMYKEY"
  
   public_key = var.my_DO_rsa
}


data "digitalocean_ssh_key" "rebrain_key" {
  name = "REBRAIN.SSH.PUB.KEY"
}

resource "random_string" "randpwd" {
  length           = 16
  special          = true
  override_special = "_#"
  count = local.VPS_quantity
  
  }

resource "digitalocean_droplet" "ksumag" {
  image  = "ubuntu-18-04-x64"
  name   = "ksumag-${count.index}"
  region = "fra1"
  size   = "s-1vcpu-1gb"
  count = local.VPS_quantity
  tags   = ["devops", "dymon_ksu_at_gmail_com"]
  ssh_keys = [digitalocean_ssh_key.my_key.fingerprint,data.digitalocean_ssh_key.rebrain_key.id ]
   provisioner "remote-exec" {
    inline = [
     // "yes ${var.password} | passwd ${var.login}",
      "echo ${var.login}:${element(random_string.randpwd.*.result, count.index)} | chpasswd", 
        "sleep 30",     
      "sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config",
      "systemctl restart ssh || systemctl restart sshd",
     
          ]
   connection {
   host        = self.ipv4_address
   type        = "ssh"
   user        = var.login
   private_key = file(pathexpand("${var.my_private}"))
   
     }
  }
  
}

locals {
  
  VPS_quantity = "${length(var.devs)}"
  
  
}

data "aws_route53_zone" "primary" {
  name = "devops.rebrain.srwx.net"
  
}
resource "aws_route53_record" "myrecord" {
  zone_id = data.aws_route53_zone.primary.zone_id
  name    = "${element(var.devs, count.index)}.${data.aws_route53_zone.primary.name}"
  count = local.VPS_quantity
  type    = "A"
  ttl     = "300"
  records = [digitalocean_droplet.ksumag[count.index].ipv4_address]
}

resource "local_file" "machines" {
    content     = templatefile("${path.module}/output.tpl", { 
                           
                          dns = aws_route53_record.myrecord.*.name,
                          ip = digitalocean_droplet.ksumag.*.ipv4_address,
                          password = random_string.randpwd.*.result
      })
    filename = "${path.module}/machines.txt"
}


output "VPS_pwd" {
  value       = templatefile("${path.module}/output.tpl", { 
                           
                          dns = aws_route53_record.myrecord.*.name,
                          ip = digitalocean_droplet.ksumag.*.ipv4_address,
                          password = random_string.randpwd.*.result
  })
  description = "VPS password "
 
     }
     
    