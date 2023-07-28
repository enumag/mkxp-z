FROM ubuntu:jammy

SHELL ["/bin/bash", "-c"]

WORKDIR /app

RUN apt-get update
RUN apt-get install xxd wget git build-essential cmake meson autoconf automake libtool pkg-config ruby bison zlib1g-dev libbz2-dev xorg-dev libgl1-mesa-dev libasound2-dev libpulse-dev -y

RUN git clone https://github.com/enumag/mkxp-z.git

RUN wget https://github.com/AppImage/AppImageKit/releases/download/13/appimagetool-x86_64.AppImage
RUN chmod +x appimagetool-x86_64.AppImage

WORKDIR /app/mkxp-z/linux

RUN make

WORKDIR /app/mkxp-z

RUN apt-get -y install libfuse2

RUN source linux/vars.sh && \
    meson build --bindir=usr/bin --prefix=/app/mkxp-z/build/local -Dappimage=true -Dappimagekit_path=/app/appimagetool-x86_64.AppImage

WORKDIR /app/mkxp-z/build

RUN ninja

# Needs to be run as privileged
# docker run -it --privileged <image id>
# RUN ninja install
