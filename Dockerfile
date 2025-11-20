FROM ubuntu:22.04

# Prerequisites
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    xz-utils \
    zip \
    libglu1-mesa \
    openjdk-21-jdk \
    wget \
    clang \
    cmake \
    ninja-build \
    pkg-config \
    libgtk-3-dev \
    liblzma-dev \
    && rm -rf /var/lib/apt/lists/*

# Set up user
WORKDIR /home/developer

# Install Flutter
ENV FLUTTER_HOME=/usr/local/flutter
ENV PATH=${FLUTTER_HOME}/bin:${PATH}

RUN git clone https://github.com/flutter/flutter.git ${FLUTTER_HOME} && \
    flutter config --no-analytics && \
    flutter doctor

# Install Android SDK
ENV ANDROID_SDK_ROOT=/usr/local/android-sdk
ENV PATH=${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin:${ANDROID_SDK_ROOT}/platform-tools:${PATH}

RUN mkdir -p ${ANDROID_SDK_ROOT}/cmdline-tools && \
    wget -q https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip -O cmdline-tools.zip && \
    unzip cmdline-tools.zip -d ${ANDROID_SDK_ROOT}/cmdline-tools && \
    mv ${ANDROID_SDK_ROOT}/cmdline-tools/cmdline-tools ${ANDROID_SDK_ROOT}/cmdline-tools/latest && \
    rm cmdline-tools.zip

# Accept Android Licenses
RUN yes | sdkmanager --licenses

# Install Android Platform Tools and SDKs
# Adjust versions as needed for your project
RUN sdkmanager "platform-tools" "platforms;android-34" "build-tools;34.0.0"

# Set working directory for the app
WORKDIR /workspace

# Copy project files (optional, usually mounted via DevContainer)
# COPY . .

# Run flutter doctor again to verify Android setup
RUN flutter doctor
