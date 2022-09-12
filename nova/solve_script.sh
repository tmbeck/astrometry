#! /bin/bash
set -e
jobid=$1
AXYFILE=$2

BACKEND="astrometry-engine"

${BACKEND} -v ${AXYFILE}
