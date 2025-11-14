# syntax=docker/dockerfile:1

FROM python:3.6-slim-buster

ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    TF_CPP_MIN_LOG_LEVEL=2

# System dependencies (build tools, git-lfs, and runtime libs for OpenCV, rendering, and moviepy)
# Fix EOL apt sources (remove buster-updates/security if present)
RUN set -eux; \
    sed -i -E 's|http://deb.debian.org/debian|http://archive.debian.org/debian|g; s|http://security.debian.org/debian-security|http://archive.debian.org/debian-security|g; s|buster-updates|buster|g' /etc/apt/sources.list || true; \
    echo 'Acquire::Check-Valid-Until "false";' > /etc/apt/apt.conf.d/99no-check-valid-until; \
    apt-get -o Acquire::Check-Valid-Until=false update; \
    apt-get install -y --no-install-recommends \
        git curl ca-certificates \
        build-essential cmake \
        libgl1 libglib2.0-0 libsm6 libxext6 libxrender1 \
        ffmpeg; \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy repository
COPY . /app

# Upgrade pip and core tooling
RUN python -m pip install --no-cache-dir --upgrade pip setuptools wheel

# Install binary OpenCV explicitly (wheel) before other deps
# (baselines/setup.py is patched to not require opencv)
RUN python -m pip install --no-cache-dir opencv-python==4.5.5.64

# Install project without creating/sourcing a venv
# - top-level install
# - gym-collision-avoidance install (prefers local baselines)
RUN bash -lc "./install.sh false false" \
 && bash -lc "./gym-collision-avoidance/install.sh false false" \
 || (echo 'Install scripts failed' && exit 1)

# Default shell; run training with: docker run --gpus=none -it IMAGE ./train.sh TrainPhase1
CMD ["bash"]
