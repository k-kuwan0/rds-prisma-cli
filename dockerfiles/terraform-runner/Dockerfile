FROM hashicorp/terraform:1.13

WORKDIR /terraform-runner

# 必要なパッケージのインストール
RUN apk add --no-cache \
    aws-cli

# ツールを使いたいため、Nodeをインストールする
RUN apk add --no-cache \
    nodejs \
    npm \
    bash

# Claude Code のインストール
RUN npm install -g @anthropic-ai/claude-code

ENV SHELL=/bin/bash

# ベースイメージのENTRYPOINTを上書き
ENTRYPOINT []

# bashを起動（tty: trueがあれば起動し続ける）
CMD ["/bin/bash"]
