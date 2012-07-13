# enpribus
========

## Summary
Automates and provides complete business infrastructures

##Description
The goal of this project is to provide complete automation of setup and provide infrastructure for businesses from start to finish from bare-metal physical servers to scalable cloud application hosting utilizing the DevOps philosophy.

So many options exist for technologies to use (Eucalyptus, ) so this intends to simplify those choices for users to provide a stable and functional end-to-end system for business.

The intention is that this will cover a complete system for business, provide backups, provide auto-provisioning for development, QA environemnts, accounting and billing, to bug tracking, testing, deployments, to production hosting.

The project is in its infancy but so far, the framework and idea I wish to implement is as follows:

- Based off of Ubuntu, shell scripts are intended to modify the Ubuntu installer. A preseeded .iso Ubuntu installer is created.
- The preseeded .iso is run on a bare-metal machine and installs enprius Suite and installs a Puppet master and git repository  (for puppet configuration) into virtualized machines.
- Alternatively, the preseeded .iso runs separate installations of the Puppet master and the git repository which accomodates existing-infrastructure installation such as existing virtualized environments or elastic computing providers.
- The preseeded .iso is run on a bare-metal machine and installs enprius OpenNebula nodes to increase in-house virtualized capacity/HA, etc.
- DNS configuration would be auto-confgured. Puppet would be able to configure itself, and recreate an entire environment from a backup.
- Resources could be moved from bare-metal virtualized hosts to elastic computing resources in the "cloud".
- A centralized web dashboard would be available for all administration of projects
- PHP projects would be the intended first-supported project type

For the future:
- Implement other supported technologies for projects besides PHP (Tomcat/Ruby/etc)
- Implement other server types (Email/Storage/just about anything)
- Implement Enterprise features such as user and security restrictions, integration with existing directory services, etc.
- Whatever we can imagine, it's almost endless

I plan to use this in my own consulting, setting up environments for customers. In my experience in development and systems engineering, I also see a big gap in tools for bringing together all of the automated tools available.

If you're interested in contributing, send me a note. I want to give back to the community which is why I posted this here instead of keeping it to myself, but I also know this is large enough of a project that I could use the help from the community, especially as it grows and expands into the almost-infinite possibilities that it could entail.

I could also use help in interpreting the open source licensing requirements and notifications I need to include in this project.

Paul Hassinger
hassinger.paul@ipaul.com

## WARNING!!!
The installers wipe the entire hard drive on your system, as it installs Ubuntu without user interaction. Use it on a system where you can wipe data.

## Requirements
- This is intended to be run with Ubuntu 12.04 64-bit
- You will require 3 available servers. One server will be a Puppet master (virtualized OK), another server will be a git puppet configuration repo (Virtualized OK, not yet completed), abd another server will be the OpenNebula (Bare-Metal Virtualization CPU instructions required)

======================================================================

## Latest Status:

### July 13, 2012
At this time, I've commited my work-in progress. WARNING: as it is a work-in-progress, YMMV and things may not work, especially with environmental differences. This is proof-of-concept for me, at this time.

At this time, the files in include/iso directory, when added to an Ubuntu 12.04 server .iso image, will run the start of a puppet master (enprius Puppet) and puppet client (enpribus OpenNebula) when booting and installing said image with such selections. You will have two functional ubuntu instances after that. The enpribus suite is not yet started but is intended to load all virtualizable and management instances on one machine. The git repo instance is not yet started.

Other notes: I currently use DHCP with static IPs in my environment which have DNS names assigned. I acknowledge this will need to change in the future, I'm doing more of proof-of-concept at the moment.
