FROM ubuntu:18.04

# Silence debconf warnings caused by lack of interactive terminal during package installation
ENV DEBIAN_FRONTEND noninteractive

# Disabled one day when APT was taking forever...
RUN echo 'Acquire::ForceIPv4 "true";' | tee /etc/apt/apt.conf.d/99force-ipv4

# Install Docker
# See: https://docs.docker.com/install/linux/docker-ce/ubuntu/#install-docker-ce
RUN apt-get update && \
    apt-get remove docker docker-engine docker.io containerd runc && \
    apt-get install -y --no-install-recommends \
        apt-transport-https \
        ca-certificates \
        curl \
        gnupg-agent \
        software-properties-common
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
RUN add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
RUN apt-get update && \
    apt-get install -y \
        containerd.io \
        docker-ce \
        docker-ce-cli

# Install Docker Machine
# See: https://docs.docker.com/machine/install-machine/
RUN base=https://github.com/docker/machine/releases/download/v0.16.0 && \
    curl -L $base/docker-machine-$(uname -s)-$(uname -m) >/tmp/docker-machine && \
    install /tmp/docker-machine /usr/local/bin/docker-machine

# Install Hashicorp Terraform
# See: https://learn.hashicorp.com/terraform/getting-started/install.html#installing-terraform
RUN apt-get install -y unzip
RUN curl -L https://releases.hashicorp.com/terraform/0.11.13/terraform_0.11.13_linux_amd64.zip -o /tmp/temp.zip && \
    unzip -d /usr/bin /tmp/temp.zip && \
    rm /tmp/temp.zip

COPY requirements.txt /tmp/

# Install Ansible with Docker support
# See: https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html#latest-releases-via-apt-ubuntu
RUN apt-get install -y python3-pip && \
    pip3 install -r /tmp/requirements.txt

# Install Ansible Docker Machine support
# This will hopefully become part of Ansible core soon. See: https://github.com/ansible/ansible/pull/54946
WORKDIR /root/.ansible/plugins/inventory/
ADD https://raw.githubusercontent.com/ximon18/ansible-docker-machine-inventory-plugin/master/docker_machine.py .

# Install a patched vrnetlab branch
RUN apt-get install -y git
RUN git clone -b nlnetlabs/gantry https://github.com/ximon18/vrnetlab.git /opt/nlnetlabs/gantry/vrnetlab

# Install a Docker private registry CLI tool
# See: https://github.com/genuinetools/reg/releases/tag/v0.16.0
RUN REG_SHA256="0470b6707ac68fa89d0cd92c83df5932c9822df7176fcf02d131d75f74a36a19" && \
    curl -fSL "https://github.com/genuinetools/reg/releases/download/v0.16.0/reg-linux-amd64" -o "/usr/local/bin/reg" && \
    echo "${REG_SHA256}  /usr/local/bin/reg" | sha256sum -c - && \
    chmod a+x "/usr/local/bin/reg"

# Install our tools
COPY . /opt/nlnetlabs/gantry
RUN ln -s /usr/bin/python3 /usr/bin/python

# Patch Ansible 2.7.10 with fix #51055 (see: https://github.com/ansible/ansible/pull/51055)
WORKDIR /usr/local/lib/python3.6/dist-packages/ansible
RUN patch -p3 < /opt/nlnetlabs/gantry/ansible-51055.patch

# Pre-create CA cert and private key files for use by Docker Machine, to work around https://github.com/docker/machine/issues/3634
WORKDIR /root/.docker/machine/certs/
RUN openssl req -x509 -newkey rsa:4096 -keyout ca-key.pem -out ca.pem -days 365 -nodes -subj '/CN=localhost'

# Final touches
WORKDIR /opt/nlnetlabs/gantry
VOLUME /root/.docker/machine
ENV GANTRY_INSIDE_DOCKER=1
ENTRYPOINT ["/bin/bash", "/opt/nlnetlabs/gantry/cli"]
