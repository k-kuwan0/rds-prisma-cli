FROM node:22.20.0-alpine

WORKDIR /backend

# Corepackの有効化
RUN corepack enable

# AWS CLIとSSMプラグインのインストール
RUN apk add --no-cache \
  aws-cli \
  bash \
  curl \
  tar \
  gzip

# Session Manager Pluginのインストール
RUN curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/linux_arm64/session-manager-plugin.rpm" -o "session-manager-plugin.rpm" && \
  apk add --no-cache rpm && \
  rpm2cpio session-manager-plugin.rpm | cpio -idmv && \
  mv usr/local/sessionmanagerplugin /usr/local/bin/ && \
  chmod +x /usr/local/bin/sessionmanagerplugin/bin/session-manager-plugin && \
  ln -s /usr/local/bin/sessionmanagerplugin/bin/session-manager-plugin /usr/bin/session-manager-plugin && \
  rm -rf session-manager-plugin.rpm usr

# Claude Code のインストール
RUN npm install -g @anthropic-ai/claude-code

ENV SHELL=/bin/bash
