#!/bin/bash

repo="weewx.git"
remote="https://github.com/weewx/${repo}"
branch="development"

#-----------------------------------------------------------------
#----- clone or pull upstream repo ---
#-----------------------------------------------------------------
#
# # update checked out repo if present
# # or do the initial clone if required
# if [ -d ${repo} ]
# then
#   echo "... updating local copy ..."
#   cd ${repo}
#   git pull
#   cd -
# else
#   echo "... cloning upstream    ..."
#   git clone "${remote}" "${repo}"
# fi
#
# # checkout the desired branch
# cd ./${repo}
# git checkout ${branch}
#

#-----------------------------------------------------------------
#----- build the base os images ----
#----- note the use of --no-cache to force full rebuilds ---
#-----------------------------------------------------------------

#  docker build --no-cache -t debian11_build_os --target debian11_build_os -f ./Dockerfile .
#  docker build --no-cache -t centos8_build_os --target centos8_build_os -f ./Dockerfile .
#  docker build --no-cache -t leap_build_os --target leap_build_os -f ./Dockerfile .

# this one is not needed since deb11 works fine for all debian(ish)
#  docker build --no-cache -t ubuntu2004_build_os --target ubuntu2004_build_os -f ./Dockerfile .

#----- build the actual packages ----
# temporarily disable rpm signing
cd "${repo}" && sed -i .bak 's/SIGN=1/SIGN=0/' makefile && cd -

#docker run -w /mnt/weewx -v `pwd`/weewx.git:/mnt/weewx --rm -it debian11_build_os  make debian-packages
#docker run -w /mnt/weewx -v `pwd`/weewx.git:/mnt/weewx --rm -it centos8_build_os   make redhat-packages
docker run -w /mnt/weewx -v `pwd`/weewx.git:/mnt/weewx --rm -it leap_build_os      make suse-packages

# reenable disable rpm signing
cd "${repo}" && sed -i .bak 's/SIGN=0/SIGN=1/' makefile

