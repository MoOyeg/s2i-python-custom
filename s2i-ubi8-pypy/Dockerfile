# S2I build Image using PyPy
FROM registry.access.redhat.com/ubi8/python-38:1-60

ENV SUMMARY="PyPy Source-to-Image for Python ${PYTHON_VERSION} applications" \
    DESCRIPTION="PyPy Source-to-Image for Python ${PYTHON_VERSION} applications. This toolchain is based on Red Hat UBI8." \
    S2I_NAME="PyPy" \
    IMAGE_VERSION="1.0" \
    MICROPIPENV_NO_LOCKFILE_PRINT=0 \
    MICROPIPENV_NO_LOCKFILE_WRITE=0

LABEL summary="$SUMMARY" \
    description="$DESCRIPTION" \
    io.k8s.description="$DESCRIPTION" \
    io.k8s.display-name="PyPy3.7 UBI8" \
    io.openshift.expose-services="8080:http" \
    io.openshift.tags="python,python38" \
    name="$S2I_NAME" \
    vendor="Personal" \
    authoritative-source-url="https://quay.io/mooyeg/s2i-pypy" \
    version="$IMAGE_VERSION" \
    release="0" \
    maintainer="moyo"

USER 0

# Replace Python Versions with PyPy
RUN wget https://downloads.python.org/pypy/pypy3.7-v7.3.5-linux64.tar.bz2 && \
    tar -xvf pypy3.7-v7.3.5-linux64.tar.bz2 && \
    mv pypy3.7-v7.3.5-linux64 /usr/local/bin && \
    rm pypy3.7-v7.3.5-linux64.tar.bz2 && \
    /usr/local/bin/pypy3.7-v7.3.5-linux64/bin/pypy3.7 -m ensurepip && \
    /usr/local/bin/pypy3.7-v7.3.5-linux64/bin/pypy3.7 -m venv ${APP_ROOT} && \
    rm ${APP_ROOT}/bin/python && ln -s /usr/local/bin/pypy3.7-v7.3.5-linux64/bin/pypy3 ${APP_ROOT}/bin/python && \
    rm ${APP_ROOT}/bin/python3 && ln -s /usr/local/bin/pypy3.7-v7.3.5-linux64/bin/pypy3 ${APP_ROOT}/bin/python3 && \
    rm ${APP_ROOT}/bin/python3.8 && ln -s /usr/local/bin/pypy3.7-v7.3.5-linux64/bin/pypy3 ${APP_ROOT}/bin/python3.8 && \
    ln -s /usr/local/bin/pypy3.7-v7.3.5-linux64/bin/pypy3 ${APP_ROOT}/bin/python3.7

RUN \
    chown -R 1001:0 ${APP_ROOT} && \
    fix-permissions ${APP_ROOT} -P && \
    rpm-file-permissions

USER 1001
