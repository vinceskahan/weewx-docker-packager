#!/bin/bash

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

# uncomment to rebuild base images from scratch every time
#    note: opensuse/leap image is 4-5 minutes due to slowness of upstream repo servers
#
# this should typically be commented out
# NOCACHE="--no-cache"

docker build ${NOCACHE} -t debian11_build_os --target debian11_build_os -f ./Dockerfile .
docker build ${NOCACHE} -t centos8_build_os  --target centos8_build_os  -f ./Dockerfile .
docker build ${NOCACHE} -t leap_build_os     --target leap_build_os     -f ./Dockerfile .

# noting here for completeness, although not needed since deb11 packages work fine for all debian(ish) os
#  docker build "${NOCACHE}" -t ubuntu2004_build_os --target ubuntu2004_build_os -f ./Dockerfile .

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
cd "${repo}" && sed -i .bak 's/SIGN=0/SIGN=1/' makefile


