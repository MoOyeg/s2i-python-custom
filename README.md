# s2i-python-custom

## Repository will try and provide sample s2i python images useful for different scenarios

- s2i-ubi8-pypy - RHEL8 Based PyPy image for s2i
- s2i-ubi7-pypy - RHEL7 Based PyPy Image for s2i
- s2i-ubi8-uvicorn - RHEL8 Based Python Image that can run Gunicorn with Uvicorn for ASGI apps.

## How to Build Images

### Sample - Build Image for the [testFlask Application](https://github.com/MoOyeg/testFlask) in namespace apptest

- ``` oc new-project apptest```

- ```oc new-build https://github.com/MoOyeg/s2i-python-custom.git --name=s2i-ubi8-pypy --context-dir=s2i-ubi8-pypy -n apptest```
  
- ```oc new-app s2i-ubi8-pypy~https://github.com/MoOyeg/testFlask.git --name=testflask -l app=testflask \```
  ```--strategy=source --env=APP_CONFIG=gunicorn.conf.py --env=APP_MODULE=testapp:app \```
` ```-n apptest```

### Sample - Create ImageStream and add it to the Openshift Image Catalog

- ```oc new-build https://github.com/MoOyeg/s2i-python-custom.git --name=s2i-ubi8-pypy --context-dir=s2i-ubi8-pypy -n openshift``` 

- ```oc patch is/python -n openshift --patch "$(curl https://raw.githubusercontent.com/MoOyeg/s2i-python-custom/master/s2i-ubi8-pypy/python-builderimage-patch.yaml)"```

- Image should be available as a tag on the list of Python Builder Images.
