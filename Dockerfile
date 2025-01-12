
FROM ubuntu

RUN apt-get update && apt-get install -y --no-install-recommends build-essential zlib1g-dev wget python3 python3-requests

WORKDIR /app/

COPY Makefile .
COPY zipper.py .
COPY get_setup_modules.py .
COPY bootlin_toolchain_downloader.py .
COPY sysconfig_filter.py .
COPY configure_cross_flags.py .

ARG ARCH
ARG LIBC
ARG PYTHON_VER=3.9.7

RUN python3 bootlin_toolchain_downloader.py $ARCH $LIBC --extract --make_runner \
    && rm -f *.tar.bz2

RUN apt-get purge -y python3 python3-requests && apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/*

ENV Python_VER=$PYTHON_VER

CMD ./make_runner.sh -j all

