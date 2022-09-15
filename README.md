Astrometry.net ready out-of-the-box for local plate solving using Docker.

## Introduction

This is an update to [dm90/astrometry](https://hub.docker.com/r/dm90/astrometry/) with (planned) integrations from the fork [fergusL/astrometry](https://github.com/fergusL/astrometry).

As of 2022-09-11 it builds and solves plates (assuming the necessary index files are downloaded). Download them to `/usr/local/astrometry/data` on your host then build and run like so:

```
docker build -t tmbeck/astrometry:latest .
docker run --name astrometry --rm -p 8000:8000 \
  -v /usr/local/astrometry/data:/usr/local/astrometry/data \
  -v $(pwd)/media/sample.jpg:/sample.jpg \
  tmbeck/astrometry:latest
```

And to test submission:

```
docker exec -it astrometry python /client.py --server http://localhost:8000/api/ -k "XXXXXXX" -u /sample.jpg -w
```

*Note that Raspberry Pi support is not working at this time.*

### Changes

The original containers were built using CentOS7 or later and targeted an out of date version of [dstndstn/astrometry.net](https://github.com/dstndstn/astrometry.net). This new version does the following:

* Migrates to a modern container (`ubuntu:22.04`)
* Adds multistage builds (will eventually allow for much smaller images)

Planned changes:

* Finish multistage build cleanup
* Improve multiarch support (so RPi works again)
* Add ability to watch folders on the host system, a la [fergusL/astrometry](https://github.com/fergusL/astrometry)
* Add support for cr2 handling

### Volatile Data

Other than the fits index images mentioned above, you may wish to persist the following data the astrometry generates.

* `/astrometry.net/net/data`: Contains user uploads and job results.
* `/astrometry.net/net/django.sqlite3`: Contains the website user database. See `astrometry.net/net/settings.py`.

## Overview

(from [dm90/astrometry](https://hub.docker.com/r/dm90/astrometry/) and left here now for posterity)

I wanted to be able to spin up a local plate solver (including web API) and with (almost) zero configuration.  In my case, I use [astrometry.net](http://astrometry.net) (ADN) to assist building mount models for my telescope.  It would be nice to have an ADN server on a laptop, or perhaps a raspberry pi to give me ADN's capability even when I lack access to the interwebs.  This capability is similar to [ansvr](https://adgsoftware.com/ansvr/) on Windows, but will work on any operating system that can run Docker. (I really do not enjoy windows...)

My solution is a Docker image ([dm90/astrometry](https://hub.docker.com/r/dm90/astrometry/)) which:

* Has astrometry.net compiled and ready for use at the command line
* Has astrometry.net python libraries compiled added to the Python path
* Has a preconfigured Nova server (basic settings) that launches with a single command

I tried to provide some documentation of what's happening here.  Check out [base](./base), [astrometry](./astrometry), [nova](./nova), and [index](./index) for docs on each aspect of the build.

## Quick and Dirty

If you're a docker fiend, here you go:

`docker run -p 8000:8000 dm90/astrometry`

## Details

If you are familiar with Docker, usage is pretty straightforward.  If you're not familiar with Docker, do some research.  I'll be a bit verbose below just in case.  If you're running on a raspberry pi (or other ARM device) see [below](#arm_doc))

### Download

Assuming you have Docker installed on your system, run:

`docker pull dm90/astrometry`

This could take a bit to download (I haven't attempted to shrink the image yet)

### Running the Nova Server

#### Using docker run

Can be launched with a single command.  For example:

`docker run --name nova --restart unless-stopped -v /my/index/data:/usr/local/astrometry/data -p 8000:8000 dm90/astrometry`

The command above starts a docker container using the `dm90/astrometry` image and:

* `--name nova` gives the container the name "nova"

* `--restart unless-stopped` restarts the container after errors/reboots

* `-v /my/index/data:/usr/local/astrometry/data` mounts your index files into the astrometry.net data directory

* `-p 8000:8000` exposes the container's web application on port 8000 on the host machine

#### Using docker-compose

The better way is to use docker-compose (see [docker-compose.yml](./docker-compose.yml)).  

Clone the repo, and change into the directory:

```
git clone https://github.com/dam90/astrometry.git nova
cd nova/
```

From that directory (which contains the `docker-compose.yml`) type:

`docker-compose up -d`

##### Compose and Index Data

By default [docker-compose.yml](./docker-compose.yml) looks for a docker volume named "astrometry_index".  If no such volume exists, comment out the line or create an empty one using:

`docker volume create astrometry_index`

See the [index README](./index) for more details.

### Test

Once the Docker container is running go to http://localhost:8000 (or replace "localhost" with your hostname or IP) and you should get the nova homepage:

![screenshot of running nova container](./media/nova_homepage.png)

#### Nova API

The web API also works.  Using api key `XXXXXXXX` (or just an empty string: `""`) hit this endpoint  http://localhost:8000/api. See [ADN docs](http://astrometry.net/doc/net/api.html) for details on the API.

## The Docker image doesn't work!

If the latest docker image isn't working on your host, try building it (slow, lame):

```
git clone https://github.com/dam90/astrometry.git astrometry
cd astrometry/
docker build -t astrometry:mybuild .
```

If the build actually finishes (should take a while) try this to run and view logs:

```
docker run --name nova_test -d -p 8000:8000 astrometry:mybuild
docker logs -f nova_test
```

I'd be interested to know if you have to do this, and what the outcome is.

## Index files

The docker image comes with only one index file for testing, so you'll probably want to add your own. See the [index README](./index) for a description of how to do this.

# <a name="arm_doc">Running on ARM Chipsets (Raspberry Pi)
My first go at this was on an Intel-based CentOS image.  Once I got that working I made a separate set of install scripts for a Raspbian Docker image.  I've modified the docker build process so that when installing dependencies and compiling from source it first checks the chipset.

Assuming you have [docker and docker-compose up and running on your rpi](https://www.raspberrypi.org/blog/docker-comes-to-raspberry-pi/) usage is straightforward.

A raspberry pi compatible image is available using the `arm` tag:

`docker pull dm90/astrometry:arm`

If using docker-compose, set the `NOVA_TAG` environment variable to `arm` before use:

```
export NOVA_TAG=arm
docker-compose pull
docker-compose up
```

If the `$NOVA_TAG` environment variable is set to "arm" (case-insensitive), it will use the `dm90/astrometry:arm` docker image.
