FROM ubuntu:22.04

ARG BUILD_DEPENDENCY_PACKAGES="build-essential libmariadbd-dev git git-core zlib1g-dev libssl-dev libreadline-dev libyaml-dev libxml2-dev libxslt1-dev libcurl4-openssl-dev software-properties-common libffi-dev"
ARG RUNTIME_PACKAGES="libjemalloc-dev libjemalloc2 tzdata"
ARG OPERATION_PAKAGES="less vim default-mysql-client curl sudo"
ENV DEBCONF_NOWARNINGS="yes" \
  DEBIAN_FRONTEND="noninteractive" \
  LANG="C.UTF-8" \
  TZ="Asia/Tokyo"

# 必要なパッケージをインストールする
RUN apt-get update \
  && apt-get install -y --no-install-recommends ${BUILD_DEPENDENCY_PACKAGES} ${RUNTIME_PACKAGES} ${OPERATION_PAKAGES} \
  && apt-get clean \
  && rm -rf /var/cache/apt/lists/*

RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - && apt-get install -y nodejs
RUN npm install --global yarn

# jemalloc を有効化する
ENV LD_PRELOAD="/usr/lib/x86_64-linux-gnu/libjemalloc.so.2"

# Ruby on Rails の設定をする
ARG APP_NAME=sample
ARG APP_PATH=/app
ARG HOME_PATH=/home
ARG BUNDLE_PATH=${APP_PATH}/vendor/bundle
ARG UID=10001
ARG GID=10001
ENV \
  BUNDLE_PATH=${BUNDLE_PATH}
RUN \
  mkdir -p ${HOME_PATH} && \
  mkdir -p ${HOME_PATH} && \
  groupadd -g ${GID} -o ${APP_NAME} && \
  useradd --no-log-init -d ${HOME_PATH} -g ${GID} -G sudo -o -s /bin/bash -u ${UID} ${APP_NAME} && \
  chown -R ${APP_NAME}: ${HOME_PATH}

WORKDIR ${APP_PATH}
USER ${APP_NAME}

RUN git clone https://github.com/sstephenson/rbenv.git ~/.rbenv && \
    echo 'export PATH="~/.rbenv/bin:$PATH"' >> ~/.bashrc && \
    echo 'eval "$(~/.rbenv/bin/rbenv init -)"' >> ~/.bashrc

ENV PATH="$HOME/.rbenv/bin:$PATH"

RUN git clone https://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build && \
    ~/.rbenv/bin/rbenv install 3.2.2 && \
    ~/.rbenv/bin/rbenv global 3.2.2

RUN ~/.rbenv/bin/rbenv exec gem install bundler -v 2.4.15 && \
    ~/.rbenv/bin/rbenv exec bundle config set path vendor/bundle && \
    ~/.rbenv/bin/rbenv exec bundle config github.https true

ENV RUBYOPT -EUTF-8

