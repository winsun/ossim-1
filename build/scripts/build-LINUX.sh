#!/bin/bash

# Uncomment following line to debug script line by line:
# set -x; trap read debug

SCRIPT_DIR=`dirname $0`
CMAKE_CONFIG_SCRIPT=$SCRIPT_DIR/ossim-cmake-config-LINUX.sh

# Consider whether running in interactive shell or batch for possible 
# prompting on build configuration:
if [ "$(ps -o stat= -p $PPID)" == "Ss" ]; then
  echo
  echo "Select build type:"
  echo "  <1> Release,"
  echo "  <2> Debug,"
  echo "  <3> RelWithDebInfo,"
  echo "  <4> MinSizeRel"
  while 
    read -p "Enter 1-4 [1]: " buildtype
    if [ -z $buildtype ]; then
      buildtype=1
    fi
    [ $buildtype -lt 1 ] || [ $buildtype -gt 4 ] 
  do
    continue
  done
  case $buildtype in
    1) CMAKE_BUILD_TYPE="Release";; 
    2) CMAKE_BUILD_TYPE="Debug";;
    3) CMAKE_BUILD_TYPE="RelWithDebInfo";;
    4) CMAKE_BUILD_TYPE="MinSizeRel";;
  esac
else
  CMAKE_BUILD_TYPE="Release"
fi 

# Try running the CMake config script (sourcing here to capture OSSIM_BUILD_DIR var 
# possibly initialized in cmake config script)
if [ -x $CMAKE_CONFIG_SCRIPT ]; then
  . $CMAKE_CONFIG_SCRIPT $CMAKE_BUILD_TYPE
else
  echo; echo "Error: Cannot locate the cmake config script expected at $CMAKE_CONFIG_SCRIPT. Cannot continue."
  exit 1
fi
if [ $? -ne 0 ]; then
  echo; echo "Error encountered during CMake configuration. Build aborted."
  exit 1
fi

# CMake successful, now run make in the build directory:
pushd $OSSIM_BUILD_DIR
# make -j
make
if [ $? -ne 0 ]; then
  echo; echo "Error encountered during make. Check the console log and correct."
  popd
  exit 1
fi

echo; echo "Build completed successfully. Binaries located in $OSSIM_BUILD_DIR"
popd
exit 0

