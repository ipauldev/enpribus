enpribus
========

Automates and provides complete business infrastructures

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