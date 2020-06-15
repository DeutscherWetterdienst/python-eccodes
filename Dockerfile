# Slim Docker multi-stage build
# for Magics

# Build image
ARG PYTHON_VERSION=3.7.7
FROM python:${PYTHON_VERSION}-slim-buster as build

RUN set -ex \
    && apt-get update

# Install tools
RUN set -ex \
    && apt-get install --yes --no-install-suggests --no-install-recommends \
        wget \
        git

# Install build tools.
RUN set -ex \
    && apt-get install --yes --no-install-suggests --no-install-recommends \
      bison \
      bzip2 \
      ca-certificates \
      cmake \
      curl \
      file \
      flex \
      g++-8 \
      gcc-8 \
      gfortran-8 \
      git \
      make \
      patch \
      sudo \
      swig \
      xz-utils

RUN set -ex \
    && ln -s /usr/bin/g++-8 /usr/bin/g++ \
    && ln -s /usr/bin/gcc-8 /usr/bin/gcc \
    && ln -s /usr/bin/gfortran-8 /usr/bin/gfortran

# Install build-time dependencies.
RUN set -ex \
    && apt-get install --yes --no-install-suggests --no-install-recommends \
      libarmadillo-dev \
      libatlas-base-dev \
      libboost-dev \
      libbz2-dev \
      libc6-dev \
      libcairo2-dev \
      libcurl4-openssl-dev \
      libeigen3-dev \
      libexpat1-dev \
      libfreetype6-dev \
      libfribidi-dev \
      libgdal-dev \
      libgeos-dev \
      libharfbuzz-dev \
      libhdf5-dev \
      libjpeg-dev \
      liblapack-dev \
      libncurses5-dev \
      libnetcdf-dev \
      libpango1.0-dev \
      libpcre3-dev \
      libpng-dev \
      libreadline6-dev \
      libsqlite3-dev \
      libssl-dev \
      libxml-parser-perl \
      libxml2-dev \
      libxslt1-dev \
      libyaml-dev \
      sqlite3 \
      zlib1g-dev

# Install ecbuild
ARG ECBUILD_VERSION=3.3.2
RUN set -eux \
    && mkdir -p /src/ \
    && cd /src \
    && git clone https://github.com/ecmwf/ecbuild.git \
    && cd ecbuild \
    && git checkout ${ECBUILD_VERSION} \
    && mkdir -p /build/ecbuild \
    && cd /build/ecbuild \
    && cmake /src/ecbuild -DCMAKE_BUILD_TYPE=Release \
    && make -j4 \
    && make install

# Install eccodes
# requires ecbuild
ARG ECCODES_VERSION=2.17.1
RUN set -eux \
    && mkdir -p /src/ \
    && cd /src \
    && git clone https://github.com/ecmwf/eccodes.git \
    && cd eccodes \
    && git checkout ${ECCODES_VERSION} \
    && mkdir -p /build/eccodes \
    && cd /build/eccodes \
    && /usr/local/bin/ecbuild /src/eccodes -DECMWF_GIT=https -DCMAKE_BUILD_TYPE=Release \
    && make -j4 \
    && make install \
    && /sbin/ldconfig

# Install ecCodes
# requires ecBuild
# Install Python run-time dependencies (for eccodes)
RUN set -ex \
    && mkdir -p /src/ \
    && cd /src/ \
    && git clone https://github.com/ecmwf/eccodes-python \
    && cd eccodes-python \
    && pip install -e . \
    && python builder.py

# Remove unneeded files.
RUN set -ex \
    && find /usr/local -name 'lib*.so' | xargs -r -- strip --strip-unneeded || true \
    && find /usr/local/bin | xargs -r -- strip --strip-all || true \
    && find /usr/local/lib -name __pycache__ | xargs -r -- rm -rf

#
# Run-time image.
#
FROM debian:stable-slim

# Install run-time depencencies.
# Delete resources after installation
 RUN set -ex \
     && apt-get update \
     && apt-get install --yes --no-install-suggests --no-install-recommends \
         libopenjp2-7-dev \
     && rm -rf /var/lib/apt/lists/*

# Copy Python run-time and ECMWF softwate.
COPY --from=build /usr/local/share/eccodes/ /usr/local/share/eccodes/
COPY --from=build /usr/local/bin/ /usr/local/bin/
COPY --from=build /usr/local/lib/ /usr/local/lib/
COPY --from=build /usr/local/include/ /usr/local/include/
COPY --from=build /src/eccodes-python/ /src/eccodes-python/
# Ensure shared libs installed by the previous step are available.
RUN set -ex \
    && /sbin/ldconfig

# Configure Python runtime.
ENV \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# Copy sample file

# Run selfcheck
CMD python -m eccodes selfcheck
COPY ./samples /samples

# METADATA
# Build-time metadata as defined at http://label-schema.org
# --build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"`
ARG BUILD_DATE
# --build-arg VCS_REF=`git rev-parse --short HEAD`, e.g. 'c30d602'
ARG VCS_REF
# --build-arg VCS_URL=`git config --get remote.origin.url`, e.g. 'https://github.com/eduardrosert/docker-magics'
ARG VCS_URL
# --build-arg VERSION=`git tag`, e.g. '0.2.1'
ARG VERSION
LABEL org.label-schema.build-date=$BUILD_DATE \
        org.label-schema.name="python-eccodes" \
        org.label-schema.description="ecCodes is a package developed by ECMWF which provides an application programming interface and a set of tools for decoding and encoding messages in the following formats: WMO FM-92 GRIB edition 1 and edition 2, WMO FM-94 BUFR edition 3 and edition 4, WMO GTS abbreviated header (only decoding)" \
        org.label-schema.url="https://confluence.ecmwf.int/display/ECC" \
        org.label-schema.vcs-ref=$VCS_REF \
        org.label-schema.vcs-url=$VCS_URL \
        org.label-schema.vendor="DWD - Deutscher Wetterdienst" \
        org.label-schema.version=$VERSION \
        org.label-schema.schema-version="1.0"