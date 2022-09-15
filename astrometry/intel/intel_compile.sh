#! /bin/bash

export PATH=${PATH}:/usr/local/astrometry/bin

# clone the repo:
git clone --depth=1 https://github.com/dstndstn/astrometry.net.git
cd astrometry.net

# Edit 'makefile.netpbm' to look like this:
# NETPBM_INC ?= -I/usr/include/netpbm
# NETPBM_LIB ?= -L/usr/lib64 -lnetpbm
cd util
sed -i "s/'NETPBM_INC.*'/'NETPBM_INC ?= -I\/usr\/include\/netpbm\/'/g" makefile.netpbm
sed -i "s/'NETPBM_LIB.*'/'NETPBM_LIB ?= -L\/usr\/lib -lnetpbm'/g" makefile.netpbm
cd -

# Build astrometry, but skip cleaning or we'll remove needed build artifacts.
# We need the entire build tree because of how astrometry is structured
make config > /install/config_results
make -j$(nproc) && \
    make -j$(nproc) py && \
    make -j$(nproc) extra && \
    make install INSTALL_DIR=/usr/local #&& \
#    make clean

cd - #&& rm -rf astrometry.net