# set environment variable TF_VAR_docean_api_token to the Digital Ocean API token to use to authenticate with the Digital Ocean provider
variable "registry_admin_email" {
    description = "The email address that should receive emails from Lets Encrypt (e.g. concerning renewal, revocation or changes to the subscriber agreement). You accept the Lets Encrypt Subscriber Agreement by using this module. For more information see: https://letsencrypt.org/repository/."
}

variable "registry_admin_password" {}

variable "registry_fqdn" {}

variable "registry_do_droplet_name" {
  description = "A name used to identify the Droplet to Digital Ocean. May cause a DNS PTR record to be created. For more information see: https://www.digitalocean.com/docs/networking/dns/how-to/manage-records/#ptr-rdns-records."
}

variable "registry_do_space_name" {
    description = "(optional) The Digital Ocean Space in which to store Docker registry image files. Must be in the same region as the Droplet will be."
}

variable "registry_do_space_key" {
    description = "(required if do_space_name is non-empty) The Digital Ocean Space access key for read/write access to the Space."
}

variable "registry_do_space_secret" {
    description = "(required if do_space_name is non-empty) The Digital Ocean Space secret key for read/write access to the Space."
}

variable "registry_do_region" {
    description = "The Digital Ocean region name in which to deploy a Droplet to host the Docker registry, e.g. 'ams3'."
}

variable "registry_public_ssh_key_file_path" {
  default = "~/.ssh/id_rsa.pub"
}

provider "digitalocean" {
  version = "~> 1.1"
}

resource "digitalocean_ssh_key" "mykey" {
  name       = "Docker Registry SSH key (${terraform.env})"
  public_key = "${file("${var.registry_public_ssh_key_file_path}")}"
}

module "registry" {
  source              = "ximon18/docker-registry/digitalocean"
  version             = "0.0.1-beta"
  region              = "${var.registry_do_region}"
  ssh_key_fingerprint = "${digitalocean_ssh_key.mykey.fingerprint}"
  admin_password      = "${var.registry_admin_password}"
  admin_email         = "${var.registry_admin_email}"
  fqdn                = "${var.registry_fqdn}"
  droplet_name        = "${var.registry_do_droplet_name}"
  space_name          = "${var.registry_do_space_name}"
  space_key           = "${var.registry_do_space_key}"
  space_secret        = "${var.registry_do_space_secret}"
}

resource "null_resource" "post-check" {
  triggers = {
    registry_ip = "${module.registry.ip}"
  }

  provisioner "local-exec" {
    # Test by IP, not by FQDN, as the DNS record change may not yet be visible to your system.
    # It can take a few minutes for the necessary packages to install and for the Lets Encrypt
    # TLS certificate to be issued.
    command = "which wait-for-it && wait-for-it ${module.registry.ip}:443 -t 600"
  }
}
output "registry.ip" {
  value = "${module.registry.ip}"
}
