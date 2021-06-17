#!/bin/bash
#Pre-requisites
#Must be logged in via oc
#Must be using oc user that can get token

HOST=$(oc get route default-route -n openshift-image-registry --template='{{ .spec.host }}')
PF_CLEANUP="false"
IMAGE="registry.access.redhat.com/ubi8/python-38:latest"
SCRIPTS_DIR=$(podman inspect --format='{{ index .Config.Labels "io.openshift.s2i.scripts-url" }}' $IMAGE)
CONTAINERID=$(buildah from $IMAGE)
buildah run --user 0 $CONTAINERID mv /usr/libexec/s2i/assemble /usr/libexec/s2i/assemble-main
buildah copy --chown 1001:0 $CONTAINERID assemble '/usr/libexec/s2i/assemble'
buildah run --user 0 $CONTAINERID wget https://downloads.python.org/pypy/pypy3.7-v7.3.5-linux64.tar.bz2
buildah run --user 0 $CONTAINERID tar -xvf pypy3.7-v7.3.5-linux64.tar.bz2
buildah run --user 0 $CONTAINERID mv pypy3.7-v7.3.5-linux64 /usr/local/bin


#Check if route available
if [ -z $HOST ]
then
    HOST="image-registry.openshift-image-registry.svc"
    
    #If the route is not created we need to port forward and do a bunch of stuff
    echo "start port-forward"
    oc port-forward svc/image-registry -n openshift-image-registry 5000:5000 &> /dev/null &
    PS_PID=$(ps -ef | grep -i "port-forward svc/image-registry" | head -n 1 | awk '{print $2}')
    echo "127.0.0.1   image-registry.openshift-image-registry.svc" >> /etc/hosts  
    PF_CLEANUP=true  
fi

buildah login --tls-verify=false -u $(oc whoami) -p $(oc whoami -t) $HOST:5000
buildah commit $CONTAINERID $HOST/openshift/pypy-3.7
buildah push --tls-verify=false $HOST:5000/openshift/pypy-3.7

if [ $PF_CLEANUP == "true" ]
then
   echo "Trying to end Port Forward"
   sed -i 's/127.0.0.1   image-registry.openshift-image-registry.svc//' /etc/hosts
   kill $PS_PID
fi

buildah rm $CONTAINERID
   

#MOUNTPOINT=$(buildah mount $CONTAINERID)
# buildah commit myecho-working-container containers-storage:myecho2
# buildah umount myecho-working-container
# buildah copy myecho-working-container-2 newecho /usr/local/bin
# buldah rm