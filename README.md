

## create weewx distribution packages using Docker only

This repo automates building the various os packages and tarball for weewx, using only Docker.

The build.sh script should be reasonably self-evident, but in general it:

* clones the upstream repo to a subdirectory
* checks out desired branch (default = development)
* builds persistent reusable 'build environments' for the various os
* packages weewx up into its various forms

At this time, digital signing is disabled since that requires the secret key.

* It will take a few minutes for docker to pull the upstream base os images.
* It will take about 5 minutes to build the (reusable) build environments
* Subsequent runs will take about 75 seconds or so to make all the packages

Usage is a simple `bash build.sh` which puts the results in the 'dist' subdirectory
within the cloned weewx.git source repo, much as today's make plumbing does.


### testing

To `make test` there is a little editing needed:

```

# start a container based on our deb11 build image
docker run --rm -it debian11_build_os bash

#---
#    The following can be cut+pasted into your bash shell in the container
#    in order to run the tests.  Then ^D out of the container to stop+remove it
#
#    The weewx makefile will prompt you for a mysql root password for the container.
#    Just hit return for it to proceed.
#---

# install additional packages needed for testing
apt-get install -y python3-ephem python3-pymysql mariadb-server python3-pil python3-cheetah rsyslog

# remove one line from rsyslog.conf in order to function under docker
cp /etc/rsyslog.conf /etc/rsyslog.conf.orig
grep -v '^module(load="imklog")' /etc/rsyslog.conf.orig > /etc/rsyslog.conf

# start rsyslogd (required for mariadb)
# then start mariadb
rsyslogd
/etc/init.d/mariadb start

# grab weewx, set up mariadb users for testing, run the test
git clone https://www.github.com/weewx/weewx
cd weewx/
bin/weedb/tests/setup_mysql
make test

```

