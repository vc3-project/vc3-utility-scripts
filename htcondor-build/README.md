# htcondor builder

E.g:

```
# Compile
./build.sh rhel7 > install_rhel7.log 2>&1

# Untar
cd htcondor_RedHat7
tar xfz condor-8.6.3-x86_64_RedHat7-stripped.tar.gz
CONDOR_LOCATION=$PWD/condor-8.6.3-x86_64_RedHat7-stripped

# Setup condor in the system
# Can be exported in e.g /etc/profile.d or the user environment
export CONDOR_CONFIG=$CONDOR_LOCATION/etc/examples/condor_config
export PATH=$CONDOR_LOCATION/bin:$CONDOR_LOCATION/sbin$PATH
export LD_LIBRARY_PATH=$CONDOR_LOCATION/lib/condor:$LD_LIBRARY_PATH
export PYTHONPATH=$CONDOR_LOCATION/lib/python:$PYTHONPATH
```
