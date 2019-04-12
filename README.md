# Gantry

> _a structure built on a rocket launch pad to facilitate assembly and servicing_

NLnet Labs Gantry is a tool for deploying and testing network routers in the cloud, built to support the [NLnet Labs Routinator](https://www.nlnetlabs.nl/projects/rpki/routinator/) project.

This project exists to answer the question "Does the Routinator work with real routers?" and to make it easy to keep checking that answer as the Routinator grows and the set of test routers and router versions increases.

## Here be dragons!

Warning: This is very definitely an early work-in-progress, it has bugs, it's incomplete, and running and hacking on it will require effort. This is not yet for the faint of heart.

## Quick Start

Assuming you are running on Ubuntu 18.10 and have Docker, a Digital Ocean account, and a private Docker registry containing one or more supported virtual router images with any necessary licenses, then:

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
TASK [ON ROUTER 134.209.202.139 : WAIT FOR CONNECTION ESTABLISHED TO THE ROUTINATOR] *********
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
## Running your own tests
The mechanism for running your own Ansible based tests is a work-in-progress, but for example you can already do:

```
$ cp tests/* /tmp/gantry/
$ ./gantry deploy vr-sros:16.0.R6   # or the router that you wish to deploy/run tests against
...
TASK [Include user defined tasks] **********************************************************************************************
included: /tmp/gantry/tasks-vr-sros:16.0.R6.yml for vr-sros-16.0.R6

TASK [ON ROUTER 134.209.202.139 : SHOW RPKI DATABASE] ****************************************
ok: [134.209.202.139 ]

TASK [debug] *********************************************************************************
ok: [134.209.202.139 ] => {
    "result.stdout_lines": [
        [
            "===============================================================================",
            "Static and Dynamic VRP Database Summary",
            "===============================================================================",
            "Type                                    IPv4 Routes         IPv6 Routes",
            "-------------------------------------------------------------------------------",
            "134.209.198.136-B                       10641               1944",
            "Static                                  0                   0",
            "==============================================================================="
        ]
    ]
}
```

## Status

The Routinator and the vr-sros-16.0.R6 router can be deployed and automatically setup such that the router populates its RPKI database using the Routinator.

Other routers are a work-in-progress.

No useful tests exist yet to validate how well or not the Routinator works with the routers. As part of creating such tests it would be good to see how much the stock NETCONF protocol can be used or whether origin validation related functions and data are router specific NETCONF extensions (potentially the case for at least the Alcatel/Lucent/Nokia SROS 16.0.R6 VR).

## Architecture

Gantry depends heavily on the [vrnetlab](https://github.com/plajjan/vrnetlab) project which is used to build the virtual router Docker images that are deployed and tested. Currently the vr-sros image build is slightly patched to enable outbound connectivity to the Routinator. With a better understanding of vrnetlab and routers the patch might turn out to be unnecessary, otherwise I would like to see if it is something that makes sense to somehow contribute pack to the vrnetlab project.

Infrastructure is spun up using Docker Machine and Digital Ocean.

Router images are provisioned using Docker Machine, Docker Compose and Ansible.

Terraform is used to deploy a private Docker registry to store the router images. The [reg](https://github.com/genuinetools/reg) tool is used to work with the registry.

Docker, Docker Hub and Bash are used to wrap the project up and make it easy to use. The "simple" Bash wrapper script has already grown beyond the initial expectation and is overdue for a rewrite in Python.

The manner in which different routers with different VM size requirements and post-deployment setup commands is supported will likely evolve, at present it's a bit of an Ansible/Docker Compose/Bash hack.

## Help

For questions, suggestions, and contributions please use GitHub issues and pull requests.

Consulting the Gantry `--help` output is a good way to get a feel for what Gantry can do and how to do it:

```
$ ./gantry --help
Gantry: "a structure built on a rocket launch pad to facilitate assembly and servicing"

NLnet Labs Gantry is a tool for deploying and testing network routers in the cloud, built to support the NLnet Labs Routinator project.

Usage: gantry help|--help

Router management commands:
       gantry deploy   routinator|<ROUTER TYPE> [--region <REGION:default=ams3>] 
       gantry docker   routinator|<ROUTER TYPE> ..docker cli command..
       gantry exec     routinator ..routinator cli command..
       gantry logs     routinator|<ROUTER TYPE> [--follow|--detailed]
       gantry ssh      routinator|<ROUTER TYPE> [--host]
       gantry status
       gantry undeploy routinator|<ROUTER TYPE>|all [--force]

Other commands:
       gantry registry ls|deploy|publish

Where ROUTER TYPE can be one of:
       ROUTER TYPE      ROUTER SERIES
       vr-sros:16.0.R6  Nokia/AlcatelSROS
```

## TO DO

Finish this README.