#!/usr/bin/env bash

set -x # print commands
set -e # exit on errors

# wait to allow EC2 instance to fully initialize
sleep 30

OPENJPEG_VERSION=2.3.0
GDAL_VERSION=2.3.3
HDF4_VERSION=4.2.13
HDF5_VERSION=1.10.5
JAVA_HOME=/usr/lib/jvm/java-1.8.0
threads=8
yi='sudo yum -y --setopt=skip_missing_names_on_install=False install'

# uninstall Java 7
sudo yum -y remove java-1.7.0-openjdk

# update system packages
sudo yum -y update

# install OpenJDK 8 and configure as default JRE/JVM
${yi} java-1.8.0-openjdk-devel
sudo alternatives --set java /usr/lib/jvm/jre-1.8.0-openjdk.x86_64/bin/java

sudo yum -y group install "Development Tools"

# required to build GDAL and related libraries
${yi} gcc72 gcc72-c++ cmake swig libcurl-devel geos-devel ImageMagick-devel libpng-devel libjpeg-devel

# Install Ant (version in yum repo is too old to work, so manually install)
curl --silent --show-error --location --fail --retry 3 --output apache-ant.tar.gz https://archive.apache.org/dist/ant/binaries/apache-ant-1.10.5-bin.tar.gz
sudo tar zxf apache-ant.tar.gz -C /opt/
sudo ln -s /opt/apache-ant-* /opt/apache-ant
sudo ln -s /opt/apache-ant/bin/ant /usr/bin/ant
rm -rf /tmp/apache-ant.tar.gz

# Install HDF4
wget http://www.hdfgroup.org/ftp/HDF/HDF_Current/src/hdf-${HDF4_VERSION}.tar.gz
tar zxf hdf-${HDF4_VERSION}.tar.gz
cd hdf-${HDF4_VERSION}
./configure \
  --prefix=/usr/local \
  --with-zlib \
  --with-jpeg \
  --enable-shared \
  --disable-netcdf \
  --disable-fortran
make -j${threads}
make check
sudo make install
sudo make install-examples
make installcheck
cd ..
sudo rm -rf hdf-${HDF4_VERSION}.tar.gz hdf-${HDF4_VERSION}

# Install HDF5
wget http://www.hdfgroup.org/ftp/HDF5/current/src/hdf5-${HDF5_VERSION}.tar.gz
tar zxf hdf5-${HDF5_VERSION}.tar.gz
cd hdf5-${HDF5_VERSION}
CFLAGS=-O0 \
./configure \
  --enable-shared \
  --enable-build-all \
  --with-zlib \
  --with-pthread \
  --enable-cxx
make -j${threads}
sudo make install
cd ..
sudo rm -rf hdf5-${HDF5_VERSION}.tar.gz hdf5-${HDF5_VERSION}

# install PROJ
wget http://download.osgeo.org/proj/proj-4.9.1.tar.gz
wget http://download.osgeo.org/proj/proj-datumgrid-1.5.zip
tar zxf proj-4.9.1.tar.gz
cd proj-4.9.1/nad
unzip ../../proj-datumgrid-1.5.zip
cd ..
./configure
make -j${threads}
sudo make install
cd ..
sudo rm -rf proj-*

# install OpenJPEG
wget https://github.com/uclouvain/openjpeg/archive/v${OPENJPEG_VERSION}.tar.gz
tar zxf v${OPENJPEG_VERSION}.tar.gz
cd openjpeg-${OPENJPEG_VERSION}/
mkdir build
cd build
cmake .. -DCMAKE_BUILD_TYPE=Release
make -j${threads}
sudo make install
cd ../..
rm -rf v${OPENJPEG_VERSION}.tar.gz openjpeg*

# Install GDAL with Java bindings
wget http://download.osgeo.org/gdal/${GDAL_VERSION}/gdal-${GDAL_VERSION}.tar.gz
tar zxf gdal-${GDAL_VERSION}.tar.gz
cd gdal-${GDAL_VERSION}
./configure \
  --with-curl \
  --with-hdf4 \
  --with-hdf5 \
  --with-geos \
  --with-geotiff=internal \
  --with-hide-internal-symbols \
  --with-java=${JAVA_HOME} \
  --with-libtiff=internal \
  --with-libz=internal \
  --with-mrf \
  --with-openjpeg \
  --with-threads \
  --without-jp2mrsid \
  --without-netcdf \
  --without-ecw
make -j${threads}
sudo make install
cd swig/java
make -j${threads}
sudo make install
sudo ldconfig
cd ../../..
sudo rm -Rf gdal*
