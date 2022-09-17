# Base Image Preparation

## Resources
I used the links below to get started.  They were not sufficient alone, but they were a good start:

* [Astrometry.Net documentation](http://astrometry.net/doc/build.html)
* [an old reddit threat](https://www.reddit.com/r/astrophotography/comments/211wcw/installing_astrometrynet_on_centos_65_x8664/)
* [plaidhat](http://plaidhat.com/code/astrometry.php)

## Quirks
I performed most the initial development of this image on OS X.  When I went to deploy the container to other Docker hosts running on linux (CentOS and Ubuntu) I experienced unpredictable results.  The deployment meant pushing to hub.docker.io, pulling the image to the test servers, and starting up.

I solved this by building the image on one of the linux hosts (not OS X).  When built on the Docker engine running on a linux host (not Docker for mac) the build performed identically on all three host environments.  I'm not exactly sure why this is, but I imagine it has something to do with the virtualization used to run Docker on OS X, or my ignorance of what really happens when things are compiled.

I have not tested on Docker for Windows.  (gross...)
