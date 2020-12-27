# Setup the base image. This is where we'll setup
# dependencies necessary for building our project. 

FROM ubuntu:20.04 AS dev-base

RUN apt-get update                             \
    && DEBIAN_FRONTEND=noninteractive          \
    apt-get install --no-install-recommends -y \
    build-essential                            \
    gdb                                        \
    gcc                                        \
    g++                                        \
    cmake                                      \
    libeigen3-dev                              \
    libblas-dev                                \
    libceres-dev                               \
    libgoogle-glog-dev                         \
    && apt-get clean autoclean                 \
    && apt-get autoremove --yes                \
    && rm -rf /var/lib{apt,dpkg,cache,log}

# This is the lean and mean release image. Ideally
# we would use something like alpine instead of 
# Ubuntu but here we are.

FROM ubuntu:20.04 AS release-base

RUN apt-get update                             \
    && DEBIAN_FRONTEND=noninteractive          \
    apt-get install --no-install-recommends -y \
    libblas3                                   \
    libceres1                                  \
    && apt-get clean autoclean                 \
    && apt-get autoremove --yes                \
    && rm -rf /var/lib{apt,dpkg,cache,log}

# The compile step.

FROM dev-base AS compiled

COPY . /code
WORKDIR /code/build
RUN cmake .. && make -j$(nproc --all)

# The release step.

FROM release-base AS release

COPY --from=compiled /code/build/example /usr/local/bin/example
CMD /usr/local/bin/example