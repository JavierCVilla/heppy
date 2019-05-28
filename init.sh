#!/bin/bash
#
# This script prepares the environment to use a local installation of Heepy
#
# Assumes the following configuration:
# - compiler: gcc62
# - buildmode: opt (Release)
# - os: based on the local host

# Detect local host OS
TOOLSPATH=/cvmfs/fcc.cern.ch/sw/0.8.3/tools/
OS=`python $TOOLSPATH/hsf_get_platform.py --get os`

source /cvmfs/fcc.cern.ch/sw/views/releases/externals/94.2.0/x86_64-${OS}-gcc62-opt/setup.sh

export HEPPY=$PWD
export PATH=$HEPPY/bin:$PATH
export PYTHONPATH=$PWD:$PYTHONPATH

# need this for heppy's context discovery. TODO: get rid of context discovery in heppy
export FCCEDM="unused"
export PODIO="unused"
export FCCPHYSICS="unused"

