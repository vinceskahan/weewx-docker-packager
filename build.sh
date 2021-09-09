#!/bin/bash
#
# Docker variant of making the tarball and packages for all os
#
# - this tested on a 16 GB RAM m1 Mac mini running:
#         macOS Big Sur 11.15.2
#         Docker desktop Version 4.0.0 (4.0.0.12)
#
# - approximate runtime on the mini is 75 seconds using pre-built images
#   or about 5 minutes if you rebuild the base os images every time,
#   mainly due to the upstream openSuSE leap repos being very slow
#
# changelog:
#     2021-0909 - vinceskahan@gmail.com - original
#

repo="weewx.git"
remote="https://github.com/weewx/${repo}"

# set your desired upstream branch here
branch="development"

#-----------------------------------------------------------------
#----- clone or pull upstream repo ---
#-----------------------------------------------------------------

# update checked out repo if already present
# or do the initial clone if required
if [ -d ${repo} ]
then
  echo "... updating local copy ..."
  cd ${repo}
  git pull
  cd -
else
  echo "... cloning upstream ${remote} ..."
  git clone "${remote}" "${repo}"
fi

# checkout the desired branch
cd ./${repo}
git checkout ${branch}
cd -

#-----------------------------------------------------------------
#----- build the base os images ----
#-----------------------------------------------------------------

# uncomment the following line to rebuild base images from scratch every time
# NOCACHE="--no-cache"
#
#    note: opensuse/leap image is 4-5 minutes due to slowness of upstream repo servers
#
# on the Mac Docker, having NOCACHE='' or NOCACHE= will cause a syntax error
# so either comment or uncomment the following line to use/not-use cached Docker layers
#

for target in debian11 centos8 leap
do
  docker build ${NOCACHE} -t ${target}_build_os --target ${target}_build_os -f ./Dockerfile .
done

#-----------------------------------------------------------------
#----- build the packages and tarball ----
#-----------------------------------------------------------------

# temporarily disable rpm signing for this POC
cd "${repo}" && sed -i .bak 's/SIGN=1/SIGN=0/' makefile && rm makefile.bak && cd -

# run make in an ephemeral container
docker run -w /mnt/weewx -v `pwd`/weewx.git:/mnt/weewx --rm -it debian11_build_os  make debian-packages
docker run -w /mnt/weewx -v `pwd`/weewx.git:/mnt/weewx --rm -it centos8_build_os   make redhat-packages
docker run -w /mnt/weewx -v `pwd`/weewx.git:/mnt/weewx --rm -it leap_build_os      make suse-packages

# reenable disable rpm signing in makefile
# so a 'git status' of the sources is clean again
cd "${repo}" && sed -i .bak 's/SIGN=0/SIGN=1/' makefile && rm makefile.bak


