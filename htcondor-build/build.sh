#!/bin/bash

# Simple script to build htcondor from docker images
set -x

#####################
# Parameters:
#####################
# To edit:
condor_branch="V8_6_3-branch"
condor_version="8.6.3"

# VC3 Github and docker urls
git_repo="https://github.com/vc3-project/vc3-htcondor"
docker_hub="vc3project/dockerfiles"
# end

case "$1" in
    rhel6)
      osver="RedHat6"; docker_tag="el6"
      ;;
    rhel7)
      osver="RedHat7"; docker_tag="el7"
      ;;
    *)
      echo -e "Usage: $0 [rhel6|rhel7]\n"
      exit 1
      ;;
esac

# Tarball filename
release_name="condor-${condor_version}-x86_64_${osver}-stripped"

# Cleaning
if [ -d htcondor_${osver} ]; then
    rm -rf htcondor_${osver}
fi

mkdir htcondor_${osver}; cd htcondor_${osver}
BINARY_DIR=$PWD

# Clone repository
git clone "$git_repo"
cd htcondor
git checkout $condor_branch

# Compile through docker
run_docker="docker run -u $UID:$UID -v $(pwd):$PWD -w $PWD ${docker_hub}:${docker_tag}"
$run_docker ./configure_uw -D_DEBUG:BOOL=FALSE -DWANT_MAN_PAGES:BOOL=TRUE -DWANT_FULL_DEPLOYMENT:BOOL=ON -DCONDOR_STRIP_PACKAGES:BOOL=ON
$run_docker make
$run_docker make install

# Note: make targz produces bigger (in size) binaries than make package.
# but the latest doesn't copy condor extendarl globus libraries.
# Working that around to match HTCondor tarball releases.

# $run_docker make targz >> $BINARY_DIR/install.log
# mv condor*.gz ${release_name}.tar.gz 
$run_docker cpack --config ./CPackConfig.cmake -D CPACK_PACKAGE_FILE_NAME="$release_name"

# Include extra condor libraries in tarball
INSTALL_DIR="$PWD/_CPack_Packages/LINUX-X86_64/TGZ/$release_name"
cp -Pr release_dir/lib/condor $INSTALL_DIR/lib
cp -P release_dir/libexec/glite/lib $INSTALL_DIR/libexec/glite
cd $(dirname $INSTALL_DIR)
tar czf $release_name.tar.gz --owner=0 --group=0 --numeric-owner $release_name

# Now, move and clean.
mv $release_name.tar.gz $BINARY_DIR

# Delete source code
echo rm -rf $BINARY_DIR/htcondor
# rm -rf $BINARY_DIR/htcondor
