packer {
  required_plugins {
    docker = {
      version = ">= 0.0.7"
      source  = "github.com/hashicorp/docker"
    }
    ansible = {
      version = "~> 1"
      source  = "github.com/hashicorp/ansible"
    }
  }
}

variable "docker_username" {
  type = string
  sensitive = true
  default = "to_replace"
}
variable "docker_pat" {
  type = string
  sensitive = true
  default = "to_replace"
}
variable "semantic_release_version" {
  type = string
  default = "to_replace"
}
variable "repository" {
  type = string
  default = "to_replace"
}

source "docker" "ubuntu" {
  image  = "ubuntu:latest"
  commit = true
     changes = [
      "ENTRYPOINT [\"/usr/bin/python3\", \"/app/azure-vote/main.py\"]",
      "EXPOSE 80"
    ]
}

build {
  name = "build-voting-app"
  sources = [
    "source.docker.ubuntu"
  ]

  provisioner "ansible" {
    playbook_file = "../Ansible/playbook.yml"
    extra_arguments = [ "--scp-extra-args", "'-O'" ]
  }

  post-processors {
    post-processor "docker-tag" {
      repository = "${var.docker_username}/${var.repository}"
      tags = ["${var.semantic_release_version}-packer"]
    }

    post-processor "docker-push" {
      login = true
      login_username = "${var.docker_username}"
      login_password = "${var.docker_pat}"
    }
  }
}