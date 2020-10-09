[![Travis CI status badge](https://travis-ci.com/NLnetLabs/gantry.svg?branch=master)](https://travis-ci.com/NLnetLabs/gantry)

# Gantry

> _a structure built on a rocket launch pad to facilitate assembly and servicing_

NLnet Labs Gantry is a tool for deploying and testing network routers in the cloud, built to support the [NLnet Labs Routinator](https://www.nlnetlabs.nl/projects/rpki/routinator/) project.

This project exists to answer the question "Does the Routinator work with real routers?" and to make it easy to keep checking that answer as the Routinator grows and the set of test routers and router versions increases.

## Here be dragons!

Warning: This is very definitely an early work-in-progress, it has bugs, it's incomplete, and running and hacking on it will require effort. This is not yet for the faint of heart.

## Quick Start

Assuming you are running on Ubuntu 18.10 and have Docker, a DigitalOcean account, and a private Docker registry containing one or more supported virtual router images with any necessary licenses, then:

```
$ cp gantry.cfg.example gantry.cfg
$ vi gantry.cfg                    # edit the values to match your setup
$ ./gantry deploy routinator
$ ./gantry logs routinator
...
RTR: Listening on 0.0.0.0:3323.
$ ./gantry deploy vr-sros:16.0.R6  # or the router that you wish to deploy
```

Sit back and drink a coffee while the rocket launches!

```
...
TASK [ON ROUTER vr-sros-16.0.R6 @ 134.209.202.139 : WAIT FOR CONNECTION ESTABLISHED ...
ok: [134.209.202.139 ]

TASK [debug] *********************************************************************************
ok: [134.209.202.139 ] => {
    "result.stdout_lines": [
        [
            "===============================================================================",
            "Rpki Session Information",
            "===============================================================================",
            "IP Address         : 134.209.198.136",
            "-------------------------------------------------------------------------------",
            "Port               : 3323               Oper State         : established",
            "UpTime             : 0d 00:00:02        Flaps              : 0",
            "Active IPv4 records: 6986               Active IPv6 records: 1258",
            "===============================================================================",
            "No. of Rpki-Sessions : 1",
            "==============================================================================="
        ]
    ]
}
```

## Configuring and testing with data directory Ansible fragments

Gantry can execute Ansible based router post-deployment configuration steps, and optional test suites,  using Ansible fragments that you supply in the Gantry data directory.

Test execution takes place inside the Gantry Docker container and so only Ansible playbooks accessible to the container via the Gantry data directory can be executed. By default the host directory `/tmp/gantry` is mapped into the container. You can override this location using the `--data-dir <path>` command line option.

- Any `config-*.yml` files in the Gantry data directory will be included as task sets to be executed post deployment.
- All `test-*.yml` files will be executed by `./gantry test all`.
- Individual playbooks in the Gantry data directory can be executed using `./gantry test <filename>`, .e.g `./gantry test test-compare-vrps`.

## Upgrading

When using the `./gantry` wrapper script the Gantry Docker image is fetched the first time you use it. To upgrade it after that, assuming that a newer version of Gantry has been built over on [Docker Hub](https://hub.docker.com/r/nlnetlabs/gantry/builds), you can issue the following command:

```
$ ./gantry upgrade
latest: Pulling from nlnetlabs/gantry
Digest: sha256:16c8559eed1543a4cbc8e3324aae131cb0e6246df0668b41bb13dbd8a99c6c40
Status: Downloaded newer image for nlnetlabs/gantry:latest
```

## Preparing router images

Gantry contains support for building and publishing router images to a private Docker registry. Assuming that you have in your possession the router image file and any required license file you can use Gantry to build and publish it.

Below is an example of how to build and publish a Nokia SROS 16.0.R6 router image:

```
$ mkdir /tmp/gantry
$ cp /path/to/your/19.0.R6/sros-vm.qcow2 /tmp/gantry/sros-19.0.R6.qcow2
$ cp /path/to/your/19.0.R6/license.txt /tmp/gantry/sros-19.0.R6.qcow2.license
$ ./gantry registry publish
2019-12-09 11:05:21 +0000: Publishing builds a vrnetlab router image and publishes it to your private Docker registry.
2019-12-09 11:05:21 +0000: The router images and licenses must be supplied by you.
2019-12-09 11:05:21 +0000: Do you wish to proceed? [y/N] y
2019-12-09 11:05:22 +0000:
2019-12-09 11:05:22 +0000: Which of the following router image types do you want to publish?
    csr
    nxos
    openwrt
    routeros
    sros
    veos
    vmx
    vqfx
    vrp
    vsr1000
    xrv
    xrv9k
2019-12-09 11:05:22 +0000: Router type, e.g. sros: sros
2019-12-09 11:05:23 +0000:
2019-12-09 11:05:23 +0000: Please copy or sym link your .qcow2 router image, and optionally a .qcow2.license file, into:
2019-12-09 11:05:23 +0000: /tmp/gantry
2019-12-09 11:05:23 +0000:
2019-12-09 11:05:23 +0000: Please read CAREFULLY the instructions that will be printed next on your screen.
2019-12-09 11:05:23 +0000: If you do not name the copied/linked files correctly the build will FAIL.
2019-12-09 11:05:23 +0000: Do you wish to proceed? [y/N] y
2019-12-09 11:05:24 +0000:
vrnetlab / Nokia VSR SROS
=========================
This is the vrnetlab docker image for Nokia VSR / SROS.
...
... skip vrnetlab router specific README ...
...
2019-12-09 11:05:24 +0000: Do you wish to proceed? [y/N] y
...
... skip make and Docker build process output ...
...
2019-12-09 11:05:28 +0000:
2019-12-09 11:05:29 +0000: The image build has finished. Does the following identify the image that was built?
2019-12-09 11:05:29 +0000: vrnetlab/vr-sros:19.10.R1
2019-12-09 11:05:29 +0000: Do you wish to proceed? [y/N] y
...
... skip Docker push output ...
...
2019-12-09 11:06:07 +0000: Done.
```

## Status
Deployment of components to test:
- [ ] NLnet Labs Krill
- [x] NLnet Labs Routinator
- [x] Nokia/Alcatel SROS 16.0.R6 virtual router
- [x] Juniper VMX 18.2R1.9 virtual router
- [ ] Cisco IOS XRv 9000 virtual router
- [ ] Cisco CSR 1000 virtual router
- [ ] Other RPKI caches (TBD)

Configure virtual routers to populate their RPKI VRP database from the Routinator:
- [x] Nokia/Alcatel SROS 16.0.R6
- [x] Juniper VMX 18.2R1.9
- [ ] Cisco IOS XRv 9000 virtual router
- [ ] Cisco CSR 1000 virtual router
- [ ] Configure virtual routers to populate their RPKI VRP database from other RPKI caches (TBD)
- [ ] Configure RPKI caches to use Krill as their data source

Test scenarios:
- [x] Symmetric diff of virtual router VRP database to that of the VRP source (done with Routinator)
- [ ] Others (TBD)

## Architecture

Gantry depends heavily on the [vrnetlab](https://github.com/plajjan/vrnetlab) project which is used to build the virtual router Docker images that are deployed and tested. Currently the vr-sros image build is slightly patched to enable outbound connectivity to the Routinator. With a better understanding of vrnetlab and routers the patch might turn out to be unnecessary, otherwise I would like to see if it is something that makes sense to somehow contribute pack to the vrnetlab project.

Infrastructure is spun up using Docker Machine and DigitalOcean.

Router images are provisioned using Docker Machine, Docker and Ansible.

Terraform is used to deploy a private Docker registry to store the router images. The [reg](https://github.com/genuinetools/reg) tool is used to work with the registry.

Docker, Docker Hub and Bash are used to wrap the project up and make it easy to use. The "simple" Bash wrapper script has already grown beyond the initial expectation and is overdue for a rewrite in Python.

The manner in which different routers with different VM size requirements and post-deployment setup commands is supported will likely evolve, at present it's a bit of an Ansible/Docker/Bash hack.

## Help

For questions, suggestions, and contributions please use GitHub issues and pull requests.

Consulting the Gantry `--help` output is a good way to get a feel for what Gantry can do and how to do it:

```
$ ./gantry --help
Gantry: "a structure built on a rocket launch pad to facilitate assembly and servicing"

NLnet Labs Gantry is a tool for deploying and testing network routers in the cloud, built to support the NLnet Labs Routinator project.

Usage: gantry help|--help

Component management commands:
       gantry deploy   <COMPONENT> [<COMPONENT>..] [--region <REGION:default=ams3>] 
       gantry docker   <COMPONENT> ..commands..
       gantry exec     <COMPONENT> ..commands..
       gantry ip       <COMPONENT>
       gantry logs     <COMPONENT> [--follow]
       gantry ssh      <COMPONENT> [--host]
       gantry status
       gantry undeploy <COMPONENT> [<COMPONENT>..] [--force]

Docker registry commands:
       gantry registry ls|deploy|publish
       gantry registry rm <repo>/<image>:<tag>

Test suite commands:
       gantry test     <COMPONENT>|all [<SINGLE_PLAYBOOK_YML_FILE_IN_DATA_DIR>]

Wrapper commands:
       gantry shell
       gantry upgrade

Wrapper options:
       gantry --data-dir <PATH/TO/YOUR/DATA/FILES:default=/tmp/gantry>
       gantry --version

Where COMPONENT can be one of: (deploy and undeploy also accept special component 'all')
       COMPONENT            VENDOR
       routinator           NLnet Labs
       vr-csr:16.09.02      Cisco CSR1000v
       vr-sros:16.0.R6      Nokia/Alcatel SROS
       vr-vmx:18.2R1.9      Juniper vMX
```

_Note: The list of COMPONENTs shown is the set for which specific playbooks exist in the `playbooks/` directory. You will need the appropriate virtual router image published in your Docker registry in order to actually deploy one of these routers._

## Upgrading the Routinator version

The Routinator image is pulled from the private Docker registry, NOT from the public registry.

You can upgrade it like so:

```
$ docker pull nlnetlabs/routinator:latest
$ docker tag nlnetlabs/routinator:latest docker-reg.do.nlnetlabs.nl/nlnetlabs/routinator:latest
$ docker push <YOUR_REGISTRY_FQDN>/nlnetlabs/routinator:latest
```

The registry FQDN and login details (you might need to do `docker login` before you can push) can be found in your `gantry.cfg` file.

## Hacking

If you know what you are doing and want to take full control you can dive into the Gantry wrapper container shell prompt:

```
$ ./gantry shell
Entering shell mode..

root@a18e60b24e33:/opt/nlnetlabs/gantry# 
```

## TO DO

Finish this README.
