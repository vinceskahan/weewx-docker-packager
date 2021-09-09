

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


