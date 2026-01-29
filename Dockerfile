FROM debian:trixie-slim

RUN apt-get update && \
	apt install -y --no-install-recommends \
		curl ca-certificates git unzip xz-utils zip libglu1-mesa cmake build-essential \
		ninja-build clang pkg-config libgtk-3-dev libwebkit2gtk-4.1-dev libgcrypt20-dev \
		libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev libgstreamer-plugins-bad1.0-dev && \
	apt-get dist-clean
RUN curl --output /tmp/flutter.tar.xz \
	https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.38.8-stable.tar.xz && \
	tar -xf /tmp/flutter.tar.xz -C /usr/local/ && \
	rm /tmp/flutter.tar.xz

ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"

ARG USER=builder
RUN groupadd -g 1000 $USER && \
	useradd -u 1000 -g $USER -s /bin/bash \
		-m -d /home/$USER $USER
USER 1000:1000

WORKDIR /app

RUN flutter --disable-analytics

