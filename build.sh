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
# - approximate time on a 2018 i3 NUC running ubuntu 1804 is 15 seconds !
#
# changelog:
#     2021-0910 - vinceskahan@gmail.com - enable/disable signing better, capture return values
#     2021-0909 - vinceskahan@gmail.com - original
#

repo="weewx.git"
remote="https://github.com/weewx/${repo}"

# set your desired upstream branch here
branch="development"

# set to 1 to enable signing, 0 to disable
SIGN=0

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

if [ "x${SIGN}" = "x0" ]
then
    SIGNING="SIGN=0"
fi

# run make in an ephemeral container and capture the return status

docker run -w /mnt/weewx -v `pwd`/weewx.git:/mnt/weewx --rm -it debian11_build_os  make ${SIGNING}  debian-packages
debretval=$?
docker run -w /mnt/weewx -v `pwd`/weewx.git:/mnt/weewx --rm -it centos8_build_os   make ${SIGNING}  redhat-packages
rhretval=$?
docker run -w /mnt/weewx -v `pwd`/weewx.git:/mnt/weewx --rm -it leap_build_os      make ${SIGNING}  suse-packages
suseretval=$?

echo ""
echo "debian return value = ${debretval}"
echo "redhat return value = ${rhretval}"
echo "suse   return value = ${suseretval}"
echo ""



