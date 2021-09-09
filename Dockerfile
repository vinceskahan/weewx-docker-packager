
#
# to build just one image and save it, set its tag+target
#     id=ubuntu2004buildos && docker build --tag=${id} --target=${id} .
#     (optionally add --no-cache)
#

#############################################################
# set up the build environments
#############################################################

#---- debian build environment ----
FROM debian:11-slim as debian11_build_os
RUN apt-get update && \
    apt-get install -y make python3 python3-configobj python3-setuptools build-essential debhelper git

##---- ubuntu build environment ----
FROM ubuntu:20.04 as ubuntu2004_build_os
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y tzdata && \
    apt-get install -y make python3 python3-configobj python3-setuptools build-essential debhelper git

#--- centos8 build environment ---
FROM centos:8 as centos8_build_os
RUN yum install -y make python3 rpm-build git && \
    update-alternatives --set python /usr/bin/python3

#--- suse build environment ---
FROM opensuse/leap:15.2 as leap_build_os
RUN zypper -n update && \
    zypper -n install make python3 python3-configobj python3-setuptools rpm-build git

