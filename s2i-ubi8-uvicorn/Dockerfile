# S2I build Image using PyPy
FROM registry.access.redhat.com/ubi7/python-38

ENV SUMMARY="Source-to-Image for Python ${PYTHON_VERSION} applications" \
    DESCRIPTION="Source-to-Image for Python ${PYTHON_VERSION} applications. This toolchain is based on Red Hat UBI8." \
    S2I_NAME="Python-S2I-Uvicorn" \
    IMAGE_VERSION="1.0" \
    MICROPIPENV_NO_LOCKFILE_PRINT=0 \
    MICROPIPENV_NO_LOCKFILE_WRITE=0

LABEL summary="$SUMMARY" \
    description="$DESCRIPTION" \
    io.k8s.description="$DESCRIPTION" \
    io.k8s.display-name="Python-S2I-Uvicorn" \
    io.openshift.expose-services="8080:http" \
    io.openshift.tags="python,python38" \
    name="$S2I_NAME" \
    vendor="Personal" \
    authoritative-source-url="https://quay.io/mooyeg/s2i-uvicorn" \
    version="$IMAGE_VERSION" \
    release="0" \
    maintainer="moyo"

USER 0

#Install Uvicorn 
RUN ${APP_ROOT}/bin/pip install uvicorn 

COPY run /usr/libexec/s2i/

RUN \
    chown -R 1001:0 ${APP_ROOT} && \
    chown -R 1001:0 /usr/libexec/s2i/run && \
    chmod ugo+rwx /usr/libexec/s2i/run && \
    fix-permissions ${APP_ROOT} -P && \
    rpm-file-permissions

USER 1001




