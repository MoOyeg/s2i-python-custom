#!/bin/bash -x
#Pre-requisites
#Must be logged in via oc
#Must be using oc user that can get token

HOST=$(oc get route default-route -n openshift-image-registry --template='{{ .spec.host }}')
PF_CLEANUP="false"
IMAGE="registry.access.redhat.com/ubi8/python-38:latest"
APP_ROOT="/opt/app-root"
SCRIPTS_DIR=$(podman inspect --format='{{ index .Config.Labels "io.openshift.s2i.scripts-url" }}' $IMAGE)
CONTAINERID=$(buildah from $IMAGE)
buildah run --user 0 $CONTAINERID mv /usr/libexec/s2i/assemble /usr/libexec/s2i/assemble-main
buildah copy --chown 1001:0 $CONTAINERID assemble '/usr/libexec/s2i/assemble'
buildah run --user 0 $CONTAINERID wget https://downloads.python.org/pypy/pypy3.7-v7.3.5-linux64.tar.bz2
buildah run --user 0 $CONTAINERID tar -xvf pypy3.7-v7.3.5-linux64.tar.bz2
buildah run --user 0 $CONTAINERID mv pypy3.7-v7.3.5-linux64 /usr/local/bin
buildah run $CONTAINERID /usr/local/bin/pypy3.7-v7.3.5-linux64/bin/pypy3.7 -m ensurepip
buildah run $CONTAINERID /usr/local/bin/pypy3.7-v7.3.5-linux64/bin/pypy3.7 -m pip install -U pip wheel
buildah run $CONTAINERID /usr/local/bin/pypy3.7-v7.3.5-linux64/bin/pypy3.7 -m pip install virtualenv
buildah run $CONTAINERID /usr/local/bin/pypy3.7-v7.3.5-linux64/bin/pypy3.7 -m venv ${APP_ROOT}
buildah run --user 0 $CONTAINERID mv ${APP_ROOT}/bin/python3.8 ${APP_ROOT}/bin/python3.8-bk
buildah run --user 0 $CONTAINERID ln -s ${APP_ROOT}/bin/pypy3 /${APP_ROOT}/bin/python3.8
buildah run --user 0 $CONTAINERID mv ${APP_ROOT}/bin/python ${APP_ROOT}/bin/python-bk
buildah run --user 0 $CONTAINERID ln -s ${APP_ROOT}/bin/pypy3 /${APP_ROOT}/bin/python
buildah copy --chown 1001:0 $CONTAINERID ./python_alias.sh /etc/profile.d/

#Check if route available
# if [ -z $HOST ]
# then
#     HOST="image-registry.openshift-image-registry.svc"
    
#     #If the route is not created we need to port forward and do a bunch of stuff
#     echo "start port-forward"
#     oc port-forward svc/image-registry -n openshift-image-registry 5000:5000 &> /dev/null &
#     PS_PID=$(ps -ef | grep -i "port-forward svc/image-registry" | head -n 1 | awk '{print $2}')
#     echo "127.0.0.1   image-registry.openshift-image-registry.svc" >> /etc/hosts  
#     PF_CLEANUP=true  
# fi

#buildah login --tls-verify=false -u $(oc whoami) -p $(oc whoami -t) $HOST:5000
#buildah commit $CONTAINERID $HOST/openshift/pypy-3.7
#buildah push --tls-verify=false $HOST:5000/openshift/pypy-3.7:latest

buildah login quay.io
buildah commit $CONTAINERID quay.io/mooyeg/pypy-3.7
buildah push quay.io/mooyeg/pypy-3.7:latest
oc tag quay.io/mooyeg/pypy-3.7:latest test3/pypy-3.7:latest

#if [ $PF_CLEANUP == "true" ]
#then
#   echo "Trying to end Port Forward"
#   sed -i 's/127.0.0.1   image-registry.openshift-image-registry.svc//' /etc/hosts
#   kill $PS_PID
#fi

buildah rm $CONTAINERID
   

#MOUNTPOINT=$(buildah mount $CONTAINERID)
# buildah commit myecho-working-container containers-storage:myecho2
# buildah umount myecho-working-container
# buildah copy myecho-working-container-2 newecho /usr/local/bin
# buldah rm
