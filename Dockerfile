
#############################################################
# set up the build environments
#############################################################

#---- debian build environment ----
FROM debian:11 as deb11buildos
RUN apt-get update && \
    apt-get install -y make python3 python3-configobj python3-setuptools build-essential debhelper git

#--- centos8 build environment ---
FROM centos:8 as centos8buildos
RUN yum install -y make python3 rpm-build git && \
    update-alternatives --set python /usr/bin/python3

#--- suse build environment ---
FROM opensuse/leap:15.2 as leapbuilder
RUN zypper -n update && \
    zypper -n install make python3 python3-configobj python3-setuptools rpm-build git

#############################################################
# build the packages
#############################################################

#--- build centos packages ---
#  (with signing disabled for now)

FROM centos8buildos as centos8buildenv
RUN git clone https://github.com/weewx/weewx.git /root/weewx && \
    cd /root/weewx && \
    sed -i 's/SIGN=1/SIGN=0/' /root/weewx/makefile && \
    make rpm-package RPMOS=el OSREL=8 && \
    make rpm-package RPMOS=el OSREL=7

#--- build debian packages ---
FROM deb11buildos as deb11buildenv
RUN git clone https://github.com/weewx/weewx.git /root/weewx && \
    cd /root/weewx && make debian-packages 

#--- build suse packages
#  (with signing disabled for now)

FROM leapbuilder as leapbuildenv
RUN git clone https://github.com/weewx/weewx.git /root/weewx && \
    cd /root/weewx && \
    sed -e s/SIGN=1/SIGN=0/ -i makefile && \
    cd /root/weewx && make rpm-package RPMOS=suse OSREL=15 &&  make rpm-package RPMOS=suse OSREL=12

#############################################################
# grab the results
#############################################################

#--- grab the results ---
FROM ubuntu:20.04 as results
COPY --from=deb11buildenv   /root/weewx/dist/* /root/
COPY --from=centos8buildenv /root/weewx/dist/* /root/
COPY --from=leapbuildenv /root/weewx/dist/* /root/

#--- all the results are in /root in the 'results' image
#--- for now, but it's easier to mount a local directory
#--- and just have the RUN commands copy to the mounted
#--- directory if all (future) rpm checks pass
#---
#--- ref: https://github.com/anlutro/fpm-docker-example
#---

