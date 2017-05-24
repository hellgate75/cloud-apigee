---
to build: build using reveal-md 
title: Rig build and test process improvements
theme: css/theme/white.css
revealOptions:
    transition: 'fade'
    controls: true
---

# Rig build and test process improvements

---

## My "Build your own rig" exercise

* Process included checkout of 5 git repositories 
* Numerous manual steps to change configuration and pass output of one step as input for the next step
* No defined acceptance criteria
* Failure of self-initialization via AWS cloud-init scripts during first deployment
* I've removed Terraform state files and had to perform manual cleanup!

---

## buildit.tools migration notes

* No defined migration path
    * How to migrate application state?
    * How to migrate AD users?
    * How to switch users to the new rig instance?
* Snowflake setup
    * Hardcoded VPN configuration does not include Convox network routes
    * Application-specific issues (hardcoded environment parameters)
    * Pipeline library is not compatible with the current version of Jenkins

---

## Ways to improve

* Shorten feedback loop during rig components development
    * Ansible playbooks changes
    * Ansible roles changes
    * JobDSL library functions
* Define and automate acceptance tests
* Perform software stack upgrade
* Reduce number of manual steps in installation process

Note:
* All of that items are somehow related to "CI for the rig"

---

## Ways to improve: Shorten feedback loop

* Allow SSH connection to the rig hosts without establishing VPN connection
* Perform playbook development and testing on local mini-rig
* Cover individual Ansible roles with automated tests

----

### Shorten feedback loop: Allow SSH connection to the rig without VPN connection

* Use cases
    * What if VPN is not installed yet?
    * How do I run updated version of role / playbook?
* But it's better not to keep SSH port open by default
* So we need to open ssh port for specific source IPs
    * `knockd` allows to trigger actions on the remote machine by sending specific TCP/UDP packets sequence
    * `knockd` on VPN server host is configured to open ssh for specific IPs with timeout 

Note: 
* [knockd website](http://www.zeroflux.org/projects/knock) 
* Show example of iptables and knockd.conf 

----

### Shorten feedback loop: Local mini-rig

* Vagrant-managed local rig including
    * Name resolution inside VMs and host machine
	* Fully functional OpenVPN server
	* Active Directory Server (samba-ad-dc is used)
* Good enough to build and deploy Ellie's Journey applications
* VM Snapshotting helps a lot during development and experiments
    * Make snapshot of baseline rig (`vagrant save baseline`)
    * Make any changes in the rig
    * Revert your changes (`vagrant restore baseline`)

Note: 
* show running local rig with ellie build

----

### Shorten feedback loop: Cover individual Ansible roles with automated tests

* `molecule` framework is used to run tests of individual Ansible roles
    * Uses Docker or Vagrant to create test environment
    * Performs test playbook execution
    * Checks idempotency by performing a second run of the same playbook
    * Bonus: `ansible-lint` is a part of the test cycle

Note:
* show example of molecule test (gatling and tomcat)

---

## Ways to improve: Define and automate acceptance tests

* Use cases
    * Is new rig installation fully functional?
    * Is new version of pipeline library compatible with existing pipelines?
    * Experiments with new pipeline features
* `digitalrig-acceptance-tests` framework allows
    * Test individual CI environment feature separately
    * Execute tests against remote Jenkins instance
    * Perform application-specific configuration parameter checks

Note:
* [digitalrig-acceptance-tests on githib](https://github.com/buildit/digitalrig-acceptance-tests)
* show test run against local rig

---

## Ways to improve: Perform software stack upgrade

* Migrated to Ansible 2.x
* Migrated to CentOS 7.x and systemd
* Upgraded core component versions (Jenkins, Nexus, Sonar, nvm, rvm, jdk)
* Updated Jenkins pipeline
    * Switched to global pipeline library instead of custom ZIP files + curl
    * Removed legacy functions from pipeline library

---

## Ways to improve: Reduce number of manual steps

* Switched to dynamic EC2 registry
    * Based on generic ec2 inventory script, but uses "Role" tag to place 
* Moved all input parameters into single place
    * Ansible playbook in the only entry point
    * Terraform parameters are generated on the fly
    * Terraform outputs are passed back to Ansible on the fly
    * Terraform is automatically configured to store state on S3

Note:
* show live EC2 inventory output
* show example of command line to build the rig

---

## Possible improvements

* Introduce common rig module format
* Setup regular execution of rig acceptance test pack on the latest version of the rig
* Reduce rig code size

----

### Possible improvements: Common rig module format

* Now there is no option to describe application
    * Required infrastructure (servers)
    * Software dependencies (services and libraries)
    * Delivery pipeline configuration
* Possible solution is to use standard format to describe all types of dependencies

----

### Possible improvements: Setup regular execution of rig acceptance test pack

* Existing rig may build a new version of the rig 
* Execute tests against it
* Migrate users and jobs to the new rig version

----

### Possible improvements: Reduce rig code size 

* Existing rig version includes fixed set of dependencies
    * Ruby, Node, Docker, Java build stacks should be application-level dependencies
* Simple AD should not be required core component
    * Simple AD is not available in the majority of AWS regions
    * Used as a simple user and group management tool
* Windows box should not be required core component
    * May be replaced with web UI (i.e. [LDAP account manager](https://www.ldap-account-manager.org/lamcms/))
* Heart host is not required component anymore

---

## Questions!	